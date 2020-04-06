# frozen_string_literal: true

require 'securerandom'
require 'json'
require "set"

class Game
  attr_reader :uuid, :secret_word, :max_guesses, :guesses

  def initialize(uuid, secret_word)
    @uuid = uuid
    @secret_word = secret_word
    @max_guesses = 10
    @guesses = {}
  end

  def can_guess?
    @guesses.length < @max_guesses
  end

  def is_word_revealed?

    revealed_chars = 0
    @guesses.each { |k, v| revealed_chars += v.length }

    revealed_chars == @secret_word.length
  end

  def turn(letter)

    found = false

    # todo: through error instead and validate guess
    return if !can_guess? || @guesses.has_key?(letter) || is_word_revealed?

    @secret_word.each_char.with_index do |char, index|
      if letter.casecmp?(char)
        @guesses[letter] = @guesses.fetch(letter, Set[]).add(index)
        found = true
      end
    end

    @guesses[letter] = Set[] unless found

    found
  end
end

class GameSerializer
  def initialize(game)
    @game = game
  end

  def as_json(options={})
    data = { uuid: @game.uuid,
             revealed: @game.is_word_revealed?,
             guesses_left: @game.max_guesses - @game.guesses.length,
             guesses: {} }

    @game.guesses.each { |k, v| data[:guesses][k] = v.to_a }
    data
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

end

def load_words
  words = []
  File.open('words.txt').each { |word| words << word }
  words
end

module HangmanHelpers
  def base_url
    @base_url ||= 'http://localhost:4567/hangman'
  end

  def json_params

    JSON.parse(request.body.read)
  rescue StandardError
    halt 400, { message: 'Invalid JSON' }.to_json

  end

  def serialize(game)
    GameSerializer.new(game).to_json
  end

  def game
    @game ||= settings.games[params[:uuid]]
  end

  def halt_if_game_not_found!
    halt(404, { message: 'Game Not Found' }.to_json) unless game
  end
end
