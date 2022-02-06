"use strict";

exports.replaceElement = function(element) {
  return function (html) {
    return function() {
      // used: https://stackoverflow.com/a/35385518/1833322
      // alternatively: https://stackoverflow.com/a/494348/1833322
      var template = document.createElement('template');
      html = html.trim(); // Never return a text node of whitespace as the result
      template.innerHTML = html;
      var newElement = template.content.firstChild;

      if (document.body.contains(element)) { // alternatively: if (element.parentNode !== null) {
        // used: https://stackoverflow.com/a/40444300/1833322
        //       https://developer.mozilla.org/en-US/docs/Web/API/Element/replaceWith
        // alternatively: https://stackoverflow.com/a/843681/1833322
        element.replaceWith(newElement);
        // for some reason `element` is still <div> when inspected in console. However it has been replaced on the website
      } else {
        element = newElement;
      }
    }
  };
};
