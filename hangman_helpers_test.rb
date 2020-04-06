require 'rest-client'
require_relative 'hangman_helpers'

game = Game.new('126079c5-9d33-44aa-ac89-be5c26af479b', 'abandoner')

puts 'Starting game: ' + GameSerializer.new(game).to_json

['a', 'w', 'a', 'b', 'r', 'n', 'd', 'o', 'e'].each do |letter|
  puts 'Guessing letter"' + letter + '": ' + game.turn(letter).to_s + ' : ' + GameSerializer.new(game).to_json
end

results = {}
base_url = 'http://localhost:4567/hangman/api/v1/games'

# create game
response = RestClient.post(base_url, headers = {})
puts response.code
fail if response.code != 201

game_url = response.headers[:location]

puts "Testing game: " + game_url

# get game
response = RestClient.get(game_url, headers = {})
puts response.code
puts response.body
fail if response.code != 200

# get unknown game
begin
  response = RestClient.get(game_url + "12003", headers = {})
rescue RestClient::ExceptionWithResponse => err
  response = err.response
end
puts response.code
fail if response.code != 404

# wrong input
['{}', '{"letter": ""}', '{"letter": "aaaa"}', '{"letter":}'].each do |payload|
  begin
    response = RestClient.patch(game_url, payload, headers = {})
  rescue RestClient::ExceptionWithResponse => err
    response = err.response
  end

  puts response.code
  puts response.body
  fail if response.code != 424 && response.code != 400
end

# turns
['a', 'w', 'b', 'r', 'n', 'd', 'o', 'e', 'y', 'z'].each do |letter|
  begin
    response = RestClient.patch(game_url, payload = '{"letter": "' + letter + '"}', headers = {})
  rescue RestClient::ExceptionWithResponse => err
    response = err.response
  end

  puts response.code
  puts response.body
  fail if response.code != 200 && response.code != 201
end

# out of turns
['{"letter": "1"}'].each do |payload|
  begin
    response = RestClient.patch(game_url, payload, headers = {})
  rescue RestClient::ExceptionWithResponse => err
    response = err.response
  end

  puts response.code
  puts response.body
  fail if response.code != 412
end

# delete game
response = RestClient.delete(game_url, headers = {})
puts response.code
puts response.body
fail if response.code != 200




