# frozen_string_literal: true

require_relative 'hangman_helpers'
require 'sinatra/base'
require 'sinatra/namespace'


class HangmanApp < Sinatra::Base
  register Sinatra::Namespace

  configure do
    enable :logging
    set :words, load_words
    set :games, {}
  end

  namespace '/hangman/api/v1' do

    before do
      content_type 'application/json'
    end

    helpers HangmanHelpers

    post '/games' do
      game = Game.new(SecureRandom.uuid,
                      settings.words[SecureRandom.random_number(settings.words.length)])

      logger.info 'Starting game ' + game.uuid + ': ' + game.secret_word

      settings.games[game.uuid] = game

      response.headers['Location'] = "#{base_url}/api/v1/games/#{game.uuid}"
      status 201
    end

    get '/games/:uuid' do |uuid|
      halt_if_game_not_found!
      serialize(game)
    end

    delete '/games/:uuid' do |uuid|
      halt_if_game_not_found!
      settings.games.delete(game.uuid)
      status 200
    end

    patch '/games/:uuid' do |uuid|
      halt_if_game_not_found!

      halt(412, { message: 'Word is ​completely revealed' }.to_json) if game.is_word_revealed?
      halt(412, { message: 'Reached maximum guesses' }.to_json) if !game.can_guess?

      letter = json_params['letter']
      halt(424, { message: 'Guess is missing' }.to_json) if !letter || letter.strip.empty?
      halt(424, { message: 'Guess is too long' }.to_json) if letter.length > 1

      status 201 if game.turn(letter)

      serialize(game)
    end

  end
end

HangmanApp.run!