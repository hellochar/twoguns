(function() {
  define(['jquery', 'underscore'], function($, _) {
    var Overlay;
    return Overlay = (function() {
      function Overlay() {}

      Overlay.div = $("#overlay");

      Overlay.show = function(text, fadeTime) {
        Overlay.text(text);
        return Overlay.div.fadeIn(fadeTime || 100);
      };

      Overlay.text = function(text) {
        return Overlay.div.find(".text").text(text);
      };

      Overlay.hide = function(fadeTime) {
        return Overlay.div.fadeOut(fadeTime || 100);
      };

      return Overlay;

    }).call(this);
  });

}).call(this);
