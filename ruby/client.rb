require 'codenjoy_connection'
require_relative 'player'

host_ip = '127.0.0.1' # ip of host with running tetris-server
port = '8080' # this port is used for communication between your client and tetris-server
user = 'dml' # your username, use the same for registration on tetris-server

opts = { username: user, host: host_ip, port: port, game_url: 'ws?' }

player = Player.new
CodenjoyConnection.play(player, opts)

