require [
  'jquery'
  'underscore'
], ($, _) ->
  $("<script src='http://" + window.location.hostname + ":35729/livereload.js'></scr" + "ipt>").appendTo("head")
  gamelistTemplate = _.template("
    <h2> <%= _.size(lobbies) %> Currently Open Lobbies</h2>
    <h3><a href='/new'>Create new game</a></h3>
    <% _.each(lobbies, function(lobby, lobbyId) { %>
      <div class='lobby'>
        <a href=\" <%= lobbyId %> \"> <%= lobbyId %> </a>
        <div><%= _.map(lobby.players, function(player) { return player.name; }).join(', ') %></div>
        <div><%= lobby.properties.scoreLimit %> to win</div>
        <div><%= lobby.properties.mapWidth %> x <%= lobby.properties.mapHeight %></div>
        <div>Seed: <%= lobby.properties.randomSeed %> </div>
      </div>
    <% }); %>
    ")

  updateLobbyList = () ->
    # data is {
    #   lobbies: {
    #     id: lobby
    #   }
    # }
    #
    # where lobby is: {
    #   players: {
    #     pid: name,
    #     pid: name,
    #   }
    #   host: pid
    #   properties: {
    #     scoreLimit: 5,
    #     mapWidth: 5,
    #     ...
    #   }
    # }
    $.getJSON("/lobby_list.json", (data, textStatus, jqXHR) ->
      window.data = data
      string = gamelistTemplate(data).trim()
      $("#lobby_list").empty().append( $(string) )
    )

  $("<div/>").attr("id", "lobby_list").appendTo("body")

  updateLobbyList()
  setInterval(updateLobbyList, 3000)
