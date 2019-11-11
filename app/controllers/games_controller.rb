require 'json'
require 'open-uri'
require 'date'

class GamesController < ApplicationController
  def new
    @init_time = Time.now
    @results = []
    10.times { @results << ('A'..'Z').to_a.sample }
  end

  def score
    time = Time.now - DateTime.parse(params['time']).to_time
    url = "https://wagon-dictionary.herokuapp.com/#{params['guess']}"
    answer = open(url).read
    answer_exists = JSON.parse(answer)['found'] == true
    letters = params['letters'].split(/\W/).select { |l| l.match(/\w/) }.map { |l| l.downcase }
    test_array = true
    word_array = params['guess'].split('')
    word_array.each do |letter|
      test_array &&= (word_array.select{ |l| l.downcase == letter }.size <= letters.select{ |l| l.downcase == letter }.size)
    end
    if test_array && answer_exists
      @message = "Your score is #{(1 / time).round(2) + word_array.length}"
      session['score'] = session["score"].nil? ? ((1 / time).round(2) + word_array.length) : session["score"] + (1 / time).round(2) + word_array.length
      session['attemps'] = session['attemps'].nil? ? 1 : session['attemps'] + 1
    elsif !test_array
      @message = "Sorry, #{params['guess']} cannot be built from #{letters.join(",")} try again!"
      session['attemps'] = 0 if session['attemps'].nil?
      session['score'] = 0 if session['score'].nil?
    else
      @message = "Sorry, this is not a valid English word, try again!"
      session['score'] = 0 if session['score'].nil?
    end
  end
end
