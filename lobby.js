function Lobby() {
    this.players = {};
    this.host = undefined;
    this.properties = {
        scoreLimit: 2,
        mapWidth: 20,
        mapHeight: 10,
        randomSeed: 0,
    }
}

Lobby.prototype.serialize = function() {
    return {
        players: this.players,
        host: this.host,
        properties: this.properties,
    };
}

module.exports = Lobby;
