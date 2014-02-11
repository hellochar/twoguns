(function() {
  require(['jquery', 'underscore', 'dat.gui', 'settings'], function($, _, dat, settings) {
    var addControlsObject, gui, sendSettings;
    $("<script src='http://" + window.location.hostname + ":35729/livereload.js'></scr" + "ipt>").appendTo("head");
    sendSettings = function(settings) {
      return $.ajax({
        url: "/settings.json",
        type: "POST",
        contentType: "application/json",
        data: JSON.stringify(settings),
        success: function(data, textStatus, jqXHR) {
          if (textStatus !== "success") {
            return alert(textStatus);
          } else {
            return $("<pre>").text(JSON.stringify(data)).appendTo("body");
          }
        }
      });
    };
    window.settings = settings;
    gui = new dat.GUI();
    addControlsObject = function(gui, obj, name) {
      var controller, folder, value, _results;
      _results = [];
      for (name in obj) {
        value = obj[name];
        if (_.isObject(value)) {
          folder = gui.addFolder(name);
          addControlsObject(folder, value, name);
          _results.push(folder.open());
        } else {
          controller = gui.add(obj, name);
          _results.push(controller.onFinishChange(function(value) {
            return sendSettings(settings);
          }));
        }
      }
      return _results;
    };
    return addControlsObject(gui, settings);
  });

}).call(this);
