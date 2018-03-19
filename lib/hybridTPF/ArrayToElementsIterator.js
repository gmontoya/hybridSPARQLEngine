/** An ArrayToElementsIterator consumes arrays of elements and returns the elements separately. */

var TransformIterator = require('../iterators/Iterator').TransformIterator;

// Creates a new ArrayToElementsIterator
function ArrayToElementsIterator(source, options) {
  if (!(this instanceof ArrayToElementsIterator))
    return new ArrayToElementsIterator(options);
  TransformIterator.call(this, source, options);
  //console.log('ArrayToElementsIterator:10, constructor');
}
TransformIterator.inherits(ArrayToElementsIterator);

// Reads the items in the arrays read from the source
ArrayToElementsIterator.prototype._read = function () {
  var source = this._source;
  if (source) {
    var arr = source.read();
    if ( arr !== null ) {
// console.log("== ArrayToElementsIterator chunk of size " + arr.length + " read from the source iterator ==");
      arr.forEach( function (item, index) {
        //console.log('ArrayToElementsIterator:22, _read, item: '+JSON.stringify(item));
        delete item['?__d__']; // deleting marker of done mapping
        //console.log('ArrayToElementsIterator:24, _read, item: '+JSON.stringify(item));
        this._push(item);
      }, this);
	 }
  }
};

module.exports = ArrayToElementsIterator;
