require [
  'jquery'
  'underscore'
  'dat.gui'
  'settings'
], ($, _, dat, settings) ->

  $("<script src='http://" + window.location.hostname + ":35729/livereload.js'></scr" + "ipt>").appendTo("head")

  sendSettings = (settings) ->
    $.ajax(
      url: "/settings.json"
      type: "POST"
      contentType: "application/json"
      data: JSON.stringify(settings)
      success: (data, textStatus, jqXHR) ->
        if textStatus isnt "success"
          alert(textStatus)
        else
          $("<pre>").text(JSON.stringify(data)).appendTo("body")
    )

  window.settings = settings
  gui = new dat.GUI()

  # mutates gui to have a folder for the obj
  addControlsObject = (gui, obj, name) ->
    for name, value of obj
      if _.isObject(value)
        folder = gui.addFolder(name)
        addControlsObject(folder, value, name)
        folder.open()
      else
        controller = gui.add(obj, name)
        controller.onFinishChange( (value) ->
          sendSettings(settings)
        )

  addControlsObject(gui, settings)
