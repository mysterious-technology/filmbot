#! /usr/bin/env ruby

require 'benchmark'
require_relative 'scraper'
require_relative 'theater'

scraper = Scraper.new

films = []
time = Benchmark.realtime {
  films = scraper.filmforum
}
puts "avg:   #{'%.2f' % (time/films.length)}s"
puts "total: #{'%.2f' % time}s"

puts Theater.films_this_week(films)
