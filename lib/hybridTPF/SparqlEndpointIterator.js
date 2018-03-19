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
  //console.log('In SparqlEndpointIterator constructor')
}
MultiTransformIterator.inherits(SparqlEndpointIterator);

// Creates a fragment with triples that match the binding of the iterator's triple pattern
SparqlEndpointIterator.prototype._createTransformer = function (solMap, options) {
  // Apply the bindings to the iterator's triple pattern
  //var bgp = rdf.applyBindings(solMap, this._pattern);
  //console.log('SparqlEndpointIterator:29, _createTransformer, typeof solMap: '+(typeof solMap)+'. solMap: '+JSON.stringify(solMap)+'\n this._pattern:'+JSON.stringify(this._pattern));
  var query = makeQuery(solMap, this._pattern);
  //console.log('query: '+query);
  var iter = this._sparqlEndpointClient.evaluate(query);
  return iter;

  // very simple method to obtain a query string from the bgp
  function makeQuery(solMap, bgp) {
    var variables;
    if (solMap && Array.isArray(solMap) && solMap.length > 0) {
    var values = solMap.reduce((mappingsStr, mapping, index, array) => {
       if (! variables || (variables.length === 0)) {
           variables = Object.keys(mapping);
           //console.log('variables: '+variables);
           //console.log('typeof variables: '+(typeof variables));
           variables = extractVariablesB(variables, bgp);
           //console.log('(relevant) variables: '+variables);
       }
       var tmpStr = '(';
       for (var i = 0; i < variables.length; i++) {
           //console.log('w: '+variables[w]);
           var w = variables[i];
           //console.log('w: '+w);
           var value = mapping[w];
           //console.log('value(b): '+value);
           if (value['value']) { //!value && (w.charAt(0) === '?') ) {
              value = value['value']; //mapping[w.slice(1)]['value'];
           }
           //console.log('value(a): '+value);
           tmpStr = tmpStr+convertToString(value)+' ';
       }
       //console.log('mapping: '+JSON.stringify(mapping));
       tmpStr = tmpStr+')';
       mappingsStr = mappingsStr + ' ' +tmpStr;
       if (index === array.length-1) {
           //console.log('variables(e): '+variables);
           var variablesStr = variables.reduce((varsStr, v) => { 
               //console.log('x:65, varsStr: '+varsStr+', v: '+v);
               if (v.charAt(0) !== '?') {
                   v = '?'+v;
               }
               //console.log('x:69, v: '+v);
               varsStr = varsStr + v + ' ';
               return varsStr;
           }, '');
           //console.log('variablesStr: '+variablesStr);
           if (!variablesStr) {
               variablesStr = extractVariables(variables, bgp);
           }
           mappingsStr = 'VALUES ('+variablesStr+') { '+mappingsStr+' }';
       }
       return mappingsStr;
    }, '');
    } else {
        var values = "";
    }
    var str = bgp.reduce((queryStr, triple, index, array) => {
      queryStr = queryStr + convertToString(triple) + " \n";
      if (index === array.length-1) {
         queryStr = 'SELECT * WHERE { '+values+' '+queryStr + ' }';
      }
      return queryStr;
    }, '');
    return str;
  }

  function extractVariables(variables, bgp) {
      var vars = [];
      for (var i = 0; i < bgp.length; i++) {
          var t = bgp[i];
          vars = vars.concat(rdf.getVariables(t));
      }
      var str = "";
      variables.forEach(function(item) {
          //console.log("item: "+item);
          var aux = '?'+item;
          if (vars.includes(aux)) {
              str = str + aux + ' ';
          }
      });
      
      return str;
  }

  function extractVariablesB(variables, bgp) {
      var vars = [];
      for (var i = 0; i < bgp.length; i++) {
          var t = bgp[i];
          vars = vars.concat(rdf.getVariables(t));
      }
      var vs = [];
      variables.forEach(function(item) {
          //console.log("item: "+item);
          var aux = '?'+item;
          if (vars.includes(aux) || vars.includes(item)) {
              vs.push(item);
          }
      });

      return vs;
  }
/*
  function included(v, bgp) {
    var i = bgp.reduce((iAcc, triple) => {
       var s = triple.subject;
       var p = triple.predicate;
       var o = triple.object;
       var x = (rdf.isVariable(s) && (v === s)) || (rdf.isVariable(p) && (v === p)) || (rdf.isVariable(o) && (v === o));
       iAcc = iAcc || x;
     }, false);
    console.log('included: '+i);
    return i;
  }
*/
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
    //console.log('SparqlEndpointIterator:103, _readTransformer, typeof otherSolMap: '+(typeof otherSolMap));

    //console.log('SparqlEndpointIterator:105, _readTransformer, otherSolMap: '+otherSolMap);
    otherSolMap = JSON.parse(otherSolMap)["results"]["bindings"];
    //console.log('SparqlEndpointIterator:107, _readTransformer, JSON.stringify(otherSolMap): '+JSON.stringify(otherSolMap));
    try {      
      // Add the triple's bindings to the solution mapping used to retrieve the fragment
      var solMap = []; //otherSolMap; //rdf.extendBindingsBindings(iterBindings, otherSolMap);
      //console.log('SparqlEndpointIterator:111, _readTransformer, solMap: '+JSON.stringify(solMap));
      for (var i = 0; i < otherSolMap.length; i++) {
          var oneMap = {}; 
          var otherMap = otherSolMap[i];
          var keys = Object.keys(otherMap); 
          for (var j = 0; j < keys.length; j++) {
              oneMap['?'+keys[j]] = otherMap[keys[j]]['value'];
          }
          solMap.push(rdf.addBinding(oneMap,  '?__d__', 'true'));
      //solMap = rdf.addBinding(solMap, '?__d__', 'true'); // mappings produced by the SparqlEndpoint are done, no need to continue evaluation with other triple patterns
      }
      //console.log('SparqlEndpointIterator:113, _readTransformer, solMap after adding ?__d__: '+JSON.stringify(solMap));
      // Add the resulting solution mapping to the current chunk
      this._incompleteChunk = this._incompleteChunk.concat(solMap);
      // If the current chunk is complete now, return it
      if ( this._incompleteChunk.length == this._chunkSize ) {
        var completeChunk = this._incompleteChunk;
        this._incompleteChunk = [];
// console.log("== FirstTriplePatternIterator for (" + rdf.toQuickString(this._pattern) + ") is returning a complete chunk (" + ++this._completeChunkCnt + ") ==");
        this._sparqlEndpointClient._numberOfTTFromSPARQLEndpoint += this._chunkSize
        return completeChunk;
      }
    }
    catch (bindingError) { console.log(bindingError.stack); /* the current triple either doesn't match the TP or is not compatible with the input sol.mapping */ }
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
    this._sparqlEndpointClient._numberOfTTFromSPARQLEndpoint += returnChunk.length
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
