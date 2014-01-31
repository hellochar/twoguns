(function() {
  require(['jquery', 'underscore'], function($, _) {
    var gamelistTemplate, updateLobbyList;
    $("<script src='http://" + window.location.hostname + ":35729/livereload.js'></scr" + "ipt>").appendTo("head");
    gamelistTemplate = _.template("    <h2> <%= _.size(lobbies) %> Currently Open Lobbies</h2>    <% _.each(lobbies, function(lobby, lobbyId) { %>      <div class='lobby'>        <a href=\" <%= lobbyId %> \"> <%= lobbyId %> </a>        <div><%= _.map(lobby.players, function(player) { return player.name; }).join(', ') %></div>        <div><%= lobby.properties.scoreLimit %> to win</div>        <div><%= lobby.properties.mapWidth %> x <%= lobby.properties.mapHeight %></div>        <div>Seed: <%= lobby.properties.randomSeed %> </div>      </div>    <% }); %>    ");
    updateLobbyList = function() {
      return $.getJSON("/lobby_list.json", function(data, textStatus, jqXHR) {
        var string;
        window.data = data;
        string = gamelistTemplate(data).trim();
        return $("#lobby_list").empty().append($(string));
      });
    };
    $("<div/>").attr("id", "lobby_list").appendTo("body");
    updateLobbyList();
    return setInterval(updateLobbyList, 3000);
  });

}).call(this);
