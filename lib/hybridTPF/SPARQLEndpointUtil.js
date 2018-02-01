var request = require('request'), fs = require('fs'), n3 = require('n3');

function SPARQLEndpointUtil(endpointUrl) {
    if (!(this instanceof SPARQLEndpointUtil))
        return new SPARQLEndpointUtil(endpointUrl);
    this._endpointUrl = endpointUrl;
}

SPARQLEndpointUtil.prototype.evaluate = function (query, outputFile) {
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

SPARQLEndpointUtil.prototype.executeSelectQuery = function(query, callback) {
    this.executeQuery(query, 'application/sparql-results+json', function(body) {
        var result = JSON.parse(body);
        //console.log(query + ' - ' + result.results.bindings.length + ' results');
        callback(result.results.bindings)
    });
}

SPARQLEndpointUtil.prototype.executeQuery = function(query, mediaType, success) {
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

module.exports = SPARQLEndpointUtil;

endpointUrl = 'http://172.19.2.100:8891/sparql?default-graph-uri=http%3A%2F%2Fdbpedia&query=';
outputFile = '/home/roott/tmp/outputFile';
inputFile = '/home/roott/tmp/inputFile';
query = fs.readFileSync(inputFile, 'utf8')
var util = new SPARQLEndpointUtil(endpointUrl);

util.evaluate(query, outputFile);

