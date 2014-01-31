(function() {
  define([], function() {
    var ImageCache, mapping;
    mapping = {};
    ImageCache = {
      get: function(url) {
        var img;
        if (!(url in mapping)) {
          img = new Image();
          img.src = url;
          mapping[url] = img;
        }
        return mapping[url];
      }
    };
    return ImageCache;
  });

}).call(this);
