#! /usr/bin/env ruby

require 'pry'
require 'benchmark'
require_relative 'scraper/film_forum'

scraper = Scraper::FilmForum.new

films = []
time = Benchmark.realtime {
  films = scraper.scrape
}
puts "avg:   #{'%.2f' % (time/films.length)}s"
puts "total: #{'%.2f' % time}s"

puts Scraper::Base.films_this_week(films)
