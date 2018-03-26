/*! @license ©2014 Ruben Verborgh - Multimedia Lab / iMinds / Ghent University */
/** A ArrayInputTriplePatternIterator builds bindings by reading matches for a triple pattern. */

var MultiTransformIterator = require('../iterators/MultiTransformIterator'),
    rdf = require('../util/RdfUtil'),
    Logger = require('../util/ExecutionLogger')('ArrayInputTriplePatternIteratorPlus'),
    SparqlEndpointIterator = require('./SparqlEndpointIterator'),
    UnionIterator = require('../iterators/UnionIterator');

// Creates a new ArrayInputTriplePatternIterator
function ArrayInputTriplePatternIteratorPlus(parent, bgp, chunkSize, options) {
  if (!(this instanceof ArrayInputTriplePatternIteratorPlus))
    return new ArrayInputTriplePatternIteratorPlus(parent, bgp, chunkSize, options);
  MultiTransformIterator.call(this, parent, options);

  this._pattern = bgp; // it needs to be called _pattern to be usable by the logger
  this._chunkSize = chunkSize;
  this._tmpChunk = [];
  this._tripleFilter = rdf.tripleFilter(bgp[0]);
  this._client = this._options.fragmentsClient;
  //console.log('ArrayInputTriplePatternIteratorPlus:19, constructor, bgp: '+JSON.stringify(bgp));
}

MultiTransformIterator.inherits(ArrayInputTriplePatternIteratorPlus);

// Creates a fragment with triples that match the iterator's triple pattern
// and are compatible with at least on of the given solution mappings
ArrayInputTriplePatternIteratorPlus.prototype._createTransformer = function (solMapSet, options) {
  function divideMaps(maps) {
    var toDo = [], done = [];
    maps.forEach(function(m, index) {
        if (m['?__d__']) {
            done.push(m);
        } else {
            toDo.push(m);
        }
    }, this);
    return [done, toDo];    
  }
  //console.log('ArrayInputTriplePatternIteratorPlus:40,  _createTransformer, solMapSet: '+JSON.stringify(solMapSet));
  var solMapSetFinished, solMapSetToFinish;
  var aux = divideMaps(solMapSet);
  solMapSetFinished = aux[0];
  solMapSetToFinish = aux[1];
  //console.log('ArrayInputTriplePatternIteratorPlus:45, _createTransformer, solMapSetFinished: '+JSON.stringify(solMapSetFinished)+'. solMapSetToFinish: '+JSON.stringify(solMapSetToFinish));
  //var done = (Array.isArray(solMapSet) && solMapSet.length > 0 && solMapSet[0]['?__d__']);
  var pipeline = new Iterator.PassthroughIterator(true);
  var self = this;
  //pipeline.isDone = done;
  //console.log('ArrayInputTriplePatternIteratorPlus:31, _createTransformer, done: '+done);
  var pipelineDone = new Iterator.PassthroughIterator(true);
  var pipelineToDo = new Iterator.PassthroughIterator(true);
  if (solMapSetFinished.length>0) {
       //console.log('ArrayInputTriplePatternIteratorPlus:54, set source of pipeline done');
       pipelineDone.setSource(new Iterator.SingleIterator(solMapSetFinished));
       pipelineDone.isDone = true;
       //return pipeline;
  }
  if (solMapSetFinished.length<=0 || solMapSetToFinish.length>0) {
    var triplePattern = this._pattern[0];
    var fragment = this._client.getFragmentByPatternAndSolMaps(triplePattern, solMapSetToFinish);
    Logger.logFragment(this, fragment, solMapSetToFinish);
    fragment.on('error', function (error) { /*console.log('ArrayInputTriplePatternIteratorPlus:62, triplePattern: '+JSON.stringify(triplePattern)+', solMapSet: '+JSON.stringify(solMapSetToFinish));*/ Logger.warning(error.message); });

    fragment.getProperty('metadata', function (metadata) {
      // We don't need more data from the fragment
      //fragment.close();
      // If there are no matches, the entire BGP has no matches
      //console.log('ArrayInputTriplePatternIteratorPlus:68, _createTransformer, metadata.totalTriples: '+metadata.totalTriples+', self._options.threshold: '+self._options.threshold+'JSON.stringify(this._pattern): '+JSON.stringify(this._pattern));
      if (metadata.totalTriples > self._options.threshold) {
        var startIterator = Iterator.single(solMapSetToFinish);
        var sei = new SparqlEndpointIterator(startIterator, self._pattern, self._chunkSize, self._options);
        sei.on('error', emitError); //
        pipelineToDo.setSource(sei); //new SparqlEndpointIterator(bgp, solMapSet);
        pipelineToDo.isDone = true;
      } else {
        pipelineToDo.setSource(fragment);
      }
    }, this);
    function emitError(error) { this._error(error); }
  }
  if (solMapSetFinished.length<=0) {
    pipelineDone.close();
    pipelineDone = null;
  }
  if (solMapSetToFinish.length<=0) {
    pipelineToDo.close();
    pipelineToDo = null;
  }
  if (pipelineDone && pipelineToDo) {
      pipeline.setSource(new UnionIterator([pipelineDone, pipelineToDo], options));
      //console.log('ArrayInputTriplePatternIteratorPlus:92, _createTransformer');
  } else if (pipelineDone) {
      pipeline.setSource(pipelineDone);
  } else if (pipelineToDo) {
      pipeline.setSource(pipelineToDo);
  } else {
      pipeline.close();
  }
  return pipeline;
};

// Reads from the given fragment until we have a complete chunk of solution mappings
ArrayInputTriplePatternIteratorPlus.prototype._readTransformer = function (fragment, fragmentBindings) {
  //console.log('ArrayInputTriplePatternIteratorPlus:62, _readTransformer,  fragmentBindings: '+ JSON.stringify(fragmentBindings));
  // If the current chunk is over size (which might happen by a previous read
  // from the fragment), extract a properly sized chunk and return that
  if ( this._tmpChunk.length >= this._chunkSize )
    return this._extractChunk();
  // Read until we filled up the current chunk
  var triple;
  while (triple = fragment.read()) {
    // Join the triple's bindings with any compatible solution mapping from
    // the set of solution mappings used to retrieve the fragment, and
    // add the resulting (joined) solution mappings to the current chunk
    //console.log('ArrayInputTriplePatternIteratorPlus:116, _readTransformer, triple: '+JSON.stringify(triple));
    try {
        var done = (Array.isArray(triple) && triple.length > 0 && triple[0]['?__d__']);
        if (done) {
            var anotherSolMap = triple; // actually it is a solution mapping that comes from SPARQL Endpoint evaluation
            var newBinding = anotherSolMap; //rdf.extendBindingsBindings(solMap, anotherSolMap);
            //console.log('ArrayInputTriplePatternIteratorPlus:121, _readTransformer, newBinding: '+JSON.stringify(newBinding));
            this._tmpChunk = this._tmpChunk.concat( newBinding );
        } else {
            var triplePattern = this._pattern[0];
            //console.log('Array*Plus:125, triplePattern: '+JSON.stringify(triplePattern)+', triple: '+JSON.stringify(triple));
            fragmentBindings.forEach( function (solMap, index) {
                //console.log('Array*Plus:127, solMap: '+JSON.stringify(solMap));
                try {
                  var extendedBindings = rdf.extendBindings(solMap, triplePattern, triple); 
                  //console.log('ArrayInputTriplePatternIteratorPlus:130, pushing '+JSON.stringify(extendedBindings));
                  this._tmpChunk.push( extendedBindings );
                }
                catch (bindingError) { /*console.log(bindingError.stack);*/ /* bindings weren't compatible */ }
            }, this);
        }
    } catch (bindingError) { /*console.log(bindingError.stack);*/ /* bindings weren't compatible */ }

/*    fragmentBindings.forEach( function (solMap, index) {
      console.log('ArrayInputTriplePatternIteratorPlus:76, _readTransformer, solMap: '+JSON.stringify(solMap));
      try {
        if (fragment.isDone) {
            var anotherSolMap = triple; // actually it is a solution mapping that comes from SPARQL Endpoint evaluation
            var newBinding =  rdf.extendBindingsBindings(solMap, anotherSolMap);
            console.log('ArrayInputTriplePatternIteratorPlus:80, _readTransformer, newBinding: '+newBinding);
            this._tmpChunk.push( newBinding );
        } else {
            this._tmpChunk.push( rdf.extendBindings(solMap, this._pattern, triple) );
        }
      }
      catch (bindingError) { /* bindings weren't compatible */ //}
    //}, this);
    // If the current chunk is filled sufficiently, extract a properly sized chunk and return that
    if ( this._tmpChunk.length >= this._chunkSize )
      return this._extractChunk();
  }
  // Not enough matching triples read from the fragment yet to fill up the current chunk
  return null;
};

// Extracts a properly sized chunk from the current chunk
// (assumes that the current chunk is over size)
ArrayInputTriplePatternIteratorPlus.prototype._extractChunk = function () {
  var completeChunk = this._tmpChunk.slice( 0, this._chunkSize );
  this._tmpChunk = this._tmpChunk.slice( this._chunkSize );
    /*var str = this._pattern.reduce((queryStr, triple, index, array) => {
      queryStr = queryStr + convertToString(triple) + " ";
      return queryStr;
    }, '')*/
 //console.log("== ArrayInputTriplePatternIteratorPlus for (" + str + ") is extracting a chunk of size " + completeChunk.length + " (the remaining chunk has a size of " + this._tmpChunk.length + ") ==");
  this._client._overallNumberOfMatchingTriples += this._chunkSize
  return completeChunk;
};

var cnt = 0;

ArrayInputTriplePatternIteratorPlus.prototype._end = function () {
    /*var str = this._pattern.reduce((queryStr, triple, index, array) => {
      queryStr = queryStr + convertToString(triple) + " \n";
      return queryStr;
    }, '');*/
  // Return the incomplete chunk of collected sol.mappings if it is not empty
  if ( this._tmpChunk.length > 0 ) {
    var returnChunk = this._tmpChunk;
    this._tmpChunk = [];
 //console.log("== ArrayInputTriplePatternIteratorPlus for (" + str + ") is returning the last chunk (size: " + returnChunk.length + ") ==");
    this._client._overallNumberOfMatchingTriples += returnChunk.length
    this._push(returnChunk);
  }
  //console.log("== ArrayInputTriplePatternIteratorPlus for (" + str + ") is exhausted (" + ++cnt + ") ==");
  // Call superclass method
  MultiTransformIterator.prototype._end.call(this);
};

// Generates a textual representation of the iterator
ArrayInputTriplePatternIteratorPlus.prototype.toString = function () {
  return '[' + this.constructor.name +
         ' {' + rdf.toQuickString(this._pattern) + ')}' +
         '\n  <= ' + this.getSourceString();
};

/*
// adapted from method toQuickString at lib/util/RdfUtil.js
function convertToString(triple) {

    if (!triple)
      return '';
    // Convert a triple component by abbreviating it
    if (typeof triple === 'string') {
      if (rdf.isVariable(triple))
        return triple;
      if (rdf.isLiteral(triple))
        return '"' + rdf.getLiteralValue(triple) + '"';
      if (rdf.isIRI(triple)) {
        return '<'+triple+'>';
      }
      var match = triple.match(/([a-zA-Z\(\)_\.,'0-9]+)[^a-zAZ]*?$/);
      return match ? match[1] : triple;
    }
    // Convert a triple by converting its components
    return convertToString(triple.subject) + ' ' +
           convertToString(triple.predicate) + ' ' +
           convertToString(triple.object) + '.';
}*/

module.exports = ArrayInputTriplePatternIteratorPlus;
