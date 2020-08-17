require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def generate_grid(grid_size)
    grid_size.times.map { ('A'..'Z').to_a.sample }
  end

  def run_game(attempt, grid, start_time, end_time)
    url_info = open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    obj = JSON.parse(url_info)
    if valid_word?(attempt, grid)
      obj['found'] ? word_found(attempt, start_time, end_time) : word_not_found(attempt, start_time, end_time)
    else
      word_not_in_grid(attempt, start_time, end_time)
    end
  end

  def valid_word?(attempt, grid)
    attempt.upcase.chars.each do |char|
      if grid.include?(char)
        grid.delete_at(grid.index(char))
      else
        return false
      end
    end
    true
  end

  def word_found(attempt, start_time, end_time)
    { time: end_time - start_time, score: (attempt.size * 10) - (end_time - start_time), message: 'Well done!' }
  end

  def word_not_found(attempt, start_time, end_time)
    { time: end_time - start_time, score: 0, message: "#{attempt} is not an english word" }
  end

  def word_not_in_grid(attempt, start_time, end_time)
    { time: end_time - start_time, score: 0, message: "\"#{attempt}\" is not in the grid" }
  end

  def new
    @letters = generate_grid(9)
    @start_time = Time.now
  end

  def score
    @start_time = params[:start_time].to_datetime
    @end_time = Time.now
    @attempt = params[:play]
    @letters = params[:letters].split
    @results = run_game(@attempt, @letters, @start_time, @end_time)
  end
end
