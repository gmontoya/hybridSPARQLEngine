/*! @license ©2014 Ruben Verborgh - Multimedia Lab / iMinds / Ghent University */
/** A GraphPatternIterator builds bindings by reading matches for a basic graph pattern. */

var Iterator = require('../iterators/Iterator'),
    MultiTransformIterator = require('../iterators/MultiTransformIterator'),
    rdf = require('../util/RdfUtil'),
    _ = require('lodash');

var OriginalTriplePatternIterator = require('../triple-pattern-fragments/TriplePatternIterator');
var FirstTriplePatternIterator = require('./FirstTriplePatternIterator');
var ArrayInputTriplePatternIteratorPlus = require('./ArrayInputTriplePatternIteratorPlus');
var ArrayToElementsIterator = require('./ArrayToElementsIterator');
var SparqlEndpointIterator = require('./SparqlEndpointIterator');

// Creates a new StaticBGPIterator
function StaticBGPIterator(parent, bgp, options) {
  // Empty patterns have no effect; return a pass-through iterator
  if (!bgp || !bgp.length)
    return new Iterator.passthrough(parent, options);
  // A singleton BGP can be solved by a triple pattern iterator
  if (bgp.length === 1)
    return new OriginalTriplePatternIterator(parent, bgp[0], options);
  // For length two or more, construct a StaticBGPIterator
  if (!(this instanceof StaticBGPIterator))
    return new StaticBGPIterator(parent, bgp, options);
  MultiTransformIterator.call(this, parent, options);

  this._bgp = bgp;
  this._chunkSize = this._options.maxNumberOfMappings;
  this._client = this._options.fragmentsClient;
}
MultiTransformIterator.inherits(StaticBGPIterator);

// Creates a pipeline with triples matching the binding of the iterator's BGP
StaticBGPIterator.prototype._createTransformer = function (solMap, options) {
  // Apply the context bindings to the BGP of this iterator
  var bgp = rdf.applyBindings(solMap, this._bgp);
  var chunkSize = this._chunkSize;

  // If the BGP has only one triple pattern, use that triple pattern to create the pipeline
  if (bgp.length === 1)
    return createPipeline( bgp.pop(), this._chunkSize );

  // Otherwise, we must first find the best triple pattern to start the pipeline
  var pipeline = new Iterator.PassthroughIterator(true);
  // Retrieve and inspect the triple patterns' metadata to decide which has least matches
  var bestIndex = 0, minMatches = Infinity, patternsChecked = 0;
  var bgpTotalTriples = [];
  bgp.forEach(function (triplePattern, index) {
    var fragment = this._client.getFragmentByPattern(triplePattern); // no solution mappings in this case
    fragment.getProperty('metadata', function (metadata) {
      // We don't need more data from the fragment
      fragment.close();
      // If there are no matches, the entire BGP has no matches
      if (metadata.totalTriples === 0)
        return pipeline._end();
      // Record the number of matching triples for later
      bgpTotalTriples.push(metadata.totalTriples);
      // This triple pattern is the best if it has the lowest number of matches
      if (metadata.totalTriples < minMatches) {
        bestIndex = index;
        minMatches = metadata.totalTriples;
      }
      // After all patterns were checked, create the pipeline from the best pattern
      if (++patternsChecked === bgp.length) {
        var nts = bgpTotalTriples.splice(bestIndex,1);
        pipeline.setSource( createPipeline(bgp.splice(bestIndex,1)[0], nts, chunkSize) );
      }
    });
  }, this);
  // After all patterns were checked, create the pipeline from the best pattern
  return pipeline;

  // Creates the pipeline of iterators for the bound BGP,
  // starting with a TriplePatternIterator for the triple pattern,
  // then a sequence of ArrayInputTriplePatternIterators for the remainder of
  // the BGP.
  function createPipeline( firstTP, firstTPSize, chunkSize ) {
    // Create the iterator for the given first triple pattern
    var startIterator = Iterator.single(solMap);
    var pipeline = new Iterator.PassthroughIterator(true); //new FirstTriplePatternIterator(startIterator, firstTP, chunkSize, options); ////new Iterator.PassthroughIterator(true);
    //console.log('Static*:82, (firstTPSize <= options.threshold): '+(firstTPSize <= options.threshold));
    if (firstTPSize <= options.threshold) {
    pipeline.setSource(new FirstTriplePatternIterator(startIterator, firstTP, chunkSize, options));
    var varsCovered = {};
    if ( rdf.isVariable(firstTP.subject) )   varsCovered[firstTP.subject] = 1;
    if ( rdf.isVariable(firstTP.predicate) ) varsCovered[firstTP.predicate] = 1;
    if ( rdf.isVariable(firstTP.object) )    varsCovered[firstTP.object] = 1;
    // If the BGP has more triple patterns, create iterators for them and add them to the pipeline
    // (order them by minimizing the number of unbound variables)
    while ( bgp.length > 0 ) {
      var bestIndex =
//              selectNextTP_MinNumOfVarsUnbound( bgp, varsCovered );
              selectNextTP_MaxNumOfVarsBound( bgp, varsCovered );
//              selectNextTP_MinMatches( bgp, bgpTotalTriples );
//              selectNextTP_MinMatchesAfterMaxNumOfVarsBound( bgp, varsCovered, bgpTotalTriples );
//              selectNextTP_MinMatchesAfterMinNumOfVarsUnboundAfterMaxNumOfVarsBound( bgp, varsCovered, bgpTotalTriples );

      bgpTotalTriples.splice(bestIndex,1);
      var bestTP = bgp.splice(bestIndex,1)[0];
      if ( rdf.isVariable(bestTP.subject) )   varsCovered[bestTP.subject] = 1;
      if ( rdf.isVariable(bestTP.predicate) ) varsCovered[bestTP.predicate] = 1;
      if ( rdf.isVariable(bestTP.object) )    varsCovered[bestTP.object] = 1;
      var bgpCopy = [ bestTP ];
      bgpCopy = bgpCopy.concat(bgp);
      pipeline = new ArrayInputTriplePatternIteratorPlus(pipeline, bgpCopy, chunkSize, options);
    }
    } else {
      var bgpCopy = [ firstTP ];
      bgpCopy = bgpCopy.concat(bgp);
      //console.log('StaticBGPIterator:110, bgpCopy: '+JSON.stringify(bgpCopy));
      //pipeline = new Iterator.PassthroughIterator(true);
      var sei = new SparqlEndpointIterator(startIterator, bgpCopy, chunkSize, options);
      //sei.on('error', emitError); //
      pipeline.setSource( sei ); //new SparqlEndpointIterator(bgp, solMapSet);
      //pipeline.isDone = true;
      //console.log('StaticBGPIterator:116, done');
    }
    return new ArrayToElementsIterator(pipeline, options);
  }
  function emitError(error) { this._error(error); }

  function selectNextTP_MinNumOfVarsUnbound( bgp, varsCovered ) {
    var bestIndex = 0;
    var minNumOfVarsUnbound = computeNumOfVarsUnbound( bgp[0], varsCovered );
    for ( var i = 1; i < bgp.length; i++ ) {
      var numOfVarsUnbound = computeNumOfVarsUnbound( bgp[i], varsCovered );
      if ( numOfVarsUnbound < minNumOfVarsUnbound ) {
        bestIndex = i;
        minNumOfVarsUnbound = numOfVarsUnbound;
      }
    }
    return bestIndex;
  }

  function computeNumOfVarsUnbound( tp, vars ) {
    var i = 0;
    if ( rdf.isVariable(tp.subject) && ! tp.subject in vars ) ++i;
    if ( rdf.isVariable(tp.predicate) && ! tp.predicate in vars ) ++i;
    if ( rdf.isVariable(tp.object) && ! tp.object in vars ) ++i;
    return i;
  }

  function selectNextTP_MaxNumOfVarsBound( bgp, varsCovered ) {
    var bestIndex = 0;
    var maxNumOfVarsBound = computeNumOfVarsBound( bgp[0], varsCovered );
    for ( var i = 1; i < bgp.length; i++ ) {
      var numOfVarsBound = computeNumOfVarsBound( bgp[i], varsCovered );
      if ( numOfVarsBound > maxNumOfVarsBound ) {
        bestIndex = i;
        maxNumOfVarsBound = numOfVarsBound;
      }
    }
    return bestIndex;
  }

  function computeNumOfVarsBound( tp, vars ) {
    var i = 0;
    if ( rdf.isVariable(tp.subject) && tp.subject in vars ) ++i;
    if ( rdf.isVariable(tp.predicate) && tp.predicate in vars ) ++i;
    if ( rdf.isVariable(tp.object) && tp.object in vars ) ++i;
    return i;
  }

  function selectNextTP_MinMatches( bgp, bgpTotalTriples ) {
    var bestIndex = 0;
    var minMatches = bgpTotalTriples[0];
    for ( var i = 1; i < bgp.length; i++ ) {
      if ( bgpTotalTriples[i] < minMatches ) {
        bestIndex = i;
        minMatches = bgpTotalTriples[i];
      }
    }
    return bestIndex;
  }

  function selectNextTP_MinMatchesAfterMaxNumOfVarsBound( bgp, varsCovered, bgpTotalTriples ) {
    var candidates = [ 0 ];
    var maxNumOfVarsBound = computeNumOfVarsBound( bgp[0], varsCovered );
    for ( var i = 1; i < bgp.length; i++ ) {
      var numOfVarsBound = computeNumOfVarsBound( bgp[i], varsCovered );
      if ( numOfVarsBound = maxNumOfVarsBound ) {
        candidates.push( i );
      }
      else if ( numOfVarsBound > maxNumOfVarsBound ) {
        candidates = [ i ];
        maxNumOfVarsBound = numOfVarsBound;
      }
    }

    if ( candidates.length == 1 )
      return candidates[0];

    var bestIndex = candidates[0];
    var minMatches = bgpTotalTriples[bestIndex];
    for ( var j = 1; j < candidates.length; j++ ) {
      var candidateIndex = candidates[j];
      if ( bgpTotalTriples[candidateIndex] < minMatches ) {
        bestIndex = candidateIndex;
        minMatches = bgpTotalTriples[candidateIndex];
      }
    }
    return bestIndex;
  }

  function selectNextTP_MinMatchesAfterMinNumOfVarsUnboundAfterMaxNumOfVarsBound( bgp, varsCovered, bgpTotalTriples ) {
    var candidates1 = [ 0 ];
    var maxNumOfVarsBound = computeNumOfVarsBound( bgp[0], varsCovered );
    for ( var i = 1; i < bgp.length; i++ ) {
      var numOfVarsBound = computeNumOfVarsBound( bgp[i], varsCovered );
      if ( numOfVarsBound = maxNumOfVarsBound ) {
        candidates1.push( i );
      }
      else if ( numOfVarsBound > maxNumOfVarsBound ) {
        candidates1 = [ i ];
        maxNumOfVarsBound = numOfVarsBound;
      }
    }

    if ( candidates1.length == 1 )
      return candidates1[0];

    var candidates2 = [ 0 ];
    var minNumOfVarsUnbound = computeNumOfVarsUnbound( bgp[candidates1[0]], varsCovered );
    for ( var i = 1; i < candidates1.length; i++ ) {
      var candidateIndex = candidates1[i];
      var numOfVarsUnbound = computeNumOfVarsUnbound( bgp[candidateIndex], varsCovered );
      if ( numOfVarsUnbound < minNumOfVarsUnbound ) {
        bestIndex = candidateIndex;
        minNumOfVarsUnbound = numOfVarsUnbound;
      }
    }

    if ( candidates2.length == 1 )
        return candidates2[0];

    var bestIndex = candidates2[0];
    var minMatches = bgpTotalTriples[bestIndex];
    for ( var j = 1; j < candidates2.length; j++ ) {
      var candidateIndex = candidates2[j];
      if ( bgpTotalTriples[candidateIndex] < minMatches ) {
        bestIndex = candidateIndex;
        minMatches = bgpTotalTriples[candidateIndex];
      }
    }
    return bestIndex;
  }

};

// Generates a textual representation of the iterator
StaticBGPIterator.prototype.toString = function () {
  return '[' + this.constructor.name +
         ' {' + this._bgp.map(rdf.toQuickString).join(' ') + '}]' +
         '\n  <= ' + this.getSourceString();
};

module.exports = StaticBGPIterator;
