var request = require('../util/Request'), 
    fs = require('fs'), 
    zlib = require('zlib'),
    Iterator = require('../iterators/Iterator');

var Logger = require('../util/Logger');

function SPARQLEndpointClient(options) {
    if (!(this instanceof SPARQLEndpointClient))
        return new SPARQLEndpointClient(options);
    this._endpointUrl = options.endpointUrl;
    this._request = request;
    this._queue = [];
    this._activeRequests = 0;
    this._maxActiveRequests = options.concurrentRequests || 10;
    this._logger = options.logger || Logger('SPARQLEndpointClient');
    this._numberOfSPARQLEndpointCalls = 0;
    console.log('In SPARQLEndpointClient constructor, this._endpointUrl: '+this._endpointUrl);
}

SPARQLEndpointClient.prototype.evaluate = function (query) {
  var responseIterator = new Iterator.PassthroughIterator(true), self = this;

  function performRequest() {
    self._logger.info('Requesting', query);
    self._activeRequests++;
    self._numberOfSPARQLEndpointCalls++;

    var url = self._endpointUrl + encodeURIComponent(query);
    // Create the request
    var acceptHeaders = { 'Accept': 'application/sparql-results+json', 'accept-encoding': 'gzip,deflate'  };
    var requestOptions = {
      url: url,
      headers: acceptHeaders,
      timeout: 600000,
    }, request, startTime = new Date();
    try { request = self._request(requestOptions); }
    catch (error) { return setImmediate(emitError, error), responseIterator; }
    function emitError(error) { responseIterator._error(error); }

    // React to a possible response
    request.on('response', function (response) {
      var statusCode = response.statusCode, headers = response.headers,
          responseTime = new Date() - startTime, encoding, contentType, nextRequest;
      // Start a possible pending request
      self._activeRequests--;
      (nextRequest = self._queue.shift()) && nextRequest();

      // Decompress the response when necessary
      switch (encoding = headers['content-encoding'] || '') {
      case 'gzip':
        response.pipe(response = zlib.createGunzip());
        break;
      case 'deflate':
        response.pipe(response = zlib.createInflate());
        break;
      case '':
        break;
      default:
        return responseIterator._error(new Error('Unsupported encoding: ' + encoding));
      }
      response.on('error', emitError);

      // Redirect output to the iterator
      response.setEncoding && response.setEncoding('utf8');
      response.pause && response.pause();
      responseIterator.setSource(response);
      // Responses _must_ be entirely consumed,
      // or they can lead to out-of-memory errors (http://nodejs.org/api/http.html)
      responseIterator._bufferAll();

      // Emit the metadata
      contentType = (headers['content-type'] || '').replace(/\s*(?:;.*)?$/, '');
      responseIterator.setProperty('statusCode', statusCode);
      responseIterator.setProperty('contentType', contentType);
      responseIterator.setProperty('responseTime', responseTime);
    })
    .on('error', emitError);
  }

  // Start or enqueue the request
  console.log('SPARQLEndpointClient:82, evaluate, this._activeRequests: '+this._activeRequests+', this._maxActiveRequests: '+this._maxActiveRequests);
  if (this._activeRequests < this._maxActiveRequests)
    performRequest();
  else
    this._queue.push(performRequest);

  return responseIterator;
};


SPARQLEndpointClient.prototype.evaluate1 = function (query) {
    console.log('Evaluating query: '+query);

    var url = this._endpointUrl + encodeURIComponent(query);
    var mediaType = 'application/sparql-results+json';
    console.log('Executing query: ' + url);
    var options = {
        url : url,
        headers : {
            'Accept' : mediaType
        }
    };

    request(options, function(error, response, body) {
        if (error) {
            console.log(query + "could not be parsed!")
        } else if (response.statusCode != 200) {
            console.log(JSON.stringify(response));
        } else {
            console.log(JSON.parse(body).results.bindings);
        }
    });
    console.log("done");
}

SPARQLEndpointClient.prototype.evaluate2 = function (query, outputFile) {
    console.log('Evaluating query: '+query);
    //var query = 'SELECT * WHERE { ' + bgp + ' }\n';
    self = this;
    

    self.executeSelectQuery(query, function(results) {
        console.log('Evaluation completed; results: ' + results.length);
        if (results.length > 0) {
            //results.forEach(function(res) {
                fs.appendFile(outputFile, JSON.stringify(results), function(err) {
                    if (err) {
                        console.log(err);
                    }
                
                });
            //});
        }
    });
}

SPARQLEndpointClient.prototype.executeSelectQuery = function(query, callback) {
    this.executeQuery(query, 'application/sparql-results+json', function(body) {
        var result = JSON.parse(body);
        //console.log(query + ' - ' + result.results.bindings.length + ' results');
        callback(result.results.bindings)
    });
}

SPARQLEndpointClient.prototype.executeQuery = function(query, mediaType, success) {
    var url = this._endpointUrl + encodeURIComponent(query);
    console.log('Executing query: ' + url);
    var options = {
        url : url,
        headers : {
            'Accept' : mediaType
        }
    };

    request(options, function(error, response, body) {
        if (error) {
            console.log(query + "could not be parsed!")
        } else if (response.statusCode != 200) {
            console.log(JSON.stringify(response));
        } else {
            success(body);
        }
    });
}

module.exports = SPARQLEndpointClient;

/*
endpointUrl = 'http://172.19.2.100:8891/sparql?default-graph-uri=http%3A%2F%2Fdbpedia&query=';
//outputFile = '/home/roott/tmp/outputFile';
inputFile = '/home/roott/tmp/inputFile';
query = fs.readFileSync(inputFile, 'utf8')
var options = { endpointUrl : endpointUrl };

var client = new SPARQLEndpointClient(options);

var iter = client.evaluate(query);

iter.on('data', function(data) {
    console.log("data: "+data);
});

iter.on('end', function() {
    console.log("done");
});
*/
