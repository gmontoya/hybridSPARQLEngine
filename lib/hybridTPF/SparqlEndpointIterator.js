/*! @license ©2014 Ruben Verborgh - Multimedia Lab / iMinds / Ghent University */
/** A FirstTriplePatternIterator builds bindings by reading matches for a triple pattern. */

var MultiTransformIterator = require('../iterators/MultiTransformIterator'),
    rdf = require('../util/RdfUtil'),
    Logger = require('../util/ExecutionLogger')('SparqlEndpointIterator');

// Creates a new SparqlEndpointIterator
function SparqlEndpointIterator(parent, bgp, chunkSize, options) {
  if (!(this instanceof SparqlEndpointIterator))
    return new SparqlEndpointIterator(parent, bgp, chunkSize, options);
  MultiTransformIterator.call(this, parent, options);

  this._pattern = bgp; // it needs to be called _pattern to be usable by the logger
  this._chunkSize = chunkSize;
  this._sparqlEndpointClient = this._options.fragmentsClient._sparqlEndpointClient;
  this._incompleteChunk = [];
  this._completeChunkCnt = 0;
  //this._tripleFilter = rdf.tripleFilter(tp);
  //this._client = this._options.fragmentsClient;
}
MultiTransformIterator.inherits(SparqlEndpointIterator);

// Creates a fragment with triples that match the binding of the iterator's triple pattern
SparqlEndpointIterator.prototype._createTransformer = function (solMap, options) {
  // Apply the bindings to the iterator's triple pattern
  var bgp = rdf.applyBindings(solMap, this._pattern);

  var query = makeQuery(bgp);
  var iter = this._sparqlEndpointClient.evaluate(query);
  return iter;

  // very simple method to obtain a query string from the bgp
  function makeQuery(bgp) {
    var str = bgp.reduce((queryStr, triple, index, array) => {
      queryStr = queryStr + rdf.toQuickString(triple);
      if (index === array.length-1) {
         queryStr = queryStr + '}';
      }
      return queryStr;
    }, 'SELECT * WHERE { ');
    return str;
  }
  // Retrieve the fragment that corresponds to the resulting pattern
  //var fragment = this._client.getFragmentByPatternAndSolMaps(tp, null); // no solution mappings in this case!
  //Logger.logFragment(this, fragment, solMap);
  //fragment.on('error', function (error) { Logger.warning(error.message); });
  //return fragment;
};

// Reads a binding from the given fragment
SparqlEndpointIterator.prototype._readTransformer = function (iter, iterBindings) {
  // Read until we fill up the current chunk of solution mappings
  var otherSolMap;
  while (otherSolMap = iter.read()) {
    try {      
      // Add the triple's bindings to the solution mapping used to retrieve the fragment
      var solMap = rdf.extendBindings(iterBindings, otherSolMap);
      solMap = rdf.addBinding(solMap, '__d__', true); // mappings produced by the SparqlEndpoint are done, no need to continue evaluation with other triple patterns
      // Add the resulting solution mapping to the current chunk
      this._incompleteChunk.push(solMap);
      // If the current chunk is complete now, return it
      if ( this._incompleteChunk.length == this._chunkSize ) {
        var completeChunk = this._incompleteChunk;
        this._incompleteChunk = [];
// console.log("== FirstTriplePatternIterator for (" + rdf.toQuickString(this._pattern) + ") is returning a complete chunk (" + ++this._completeChunkCnt + ") ==");
        this._client._numberOfTTFromSPARQLEndpoint += this._chunkSize
        return completeChunk;
      }
    }
    catch (bindingError) { /* the current triple either doesn't match the TP or is not compatible with the input sol.mapping */ }
  }
  // Not enough matching triples read from the fragment yet to fill up the current chunk
  return null;
};

SparqlEndpointIterator.prototype._end = function () {
  // Return the incomplete chunk of collected sol.mappings if it is not empty
  if ( this._incompleteChunk.length > 0 ) {
    var returnChunk = this._incompleteChunk;
    this._incompleteChunk = [];
// console.log("== FirstTriplePatternIterator for (" + rdf.toQuickString(this._pattern) + ") is returning the last chunk (size: " + returnChunk.length + ") ==");
    this._client._numberOfTTFromSPARQLEndpoint += returnChunk.length
    this._push(returnChunk);
  }
// console.log("== FirstTriplePatternIterator for (" + rdf.toQuickString(this._pattern) + ") is exhausted ==");
  // Call superclass method
  MultiTransformIterator.prototype._end.call(this);
};

// Generates a textual representation of the iterator
SparqlEndpointIterator.prototype.toString = function () {
  return '[' + this.constructor.name +
         ' {' + rdf.toQuickString(this._pattern) + ')}' +
         '\n  <= ' + this.getSourceString();
};

module.exports = SparqlEndpointIterator;
