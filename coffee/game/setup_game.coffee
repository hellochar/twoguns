require ['jquery', 'socket.io', 'game/framework'], ($, io, framework) ->

  window.framework = framework

  socket = io.connect('http://localhost')
  socket.on('news', (data) ->
    console.log(data)
    socket.emit('my other event', { my: 'data' })
  )

  $(() -> framework.setup("han"))
