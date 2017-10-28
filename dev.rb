#! /usr/bin/env ruby

require 'benchmark'
require_relative 'scraper'
require_relative 'theater'

scraper = Scraper.new

films = []
time = Benchmark.realtime {
  films = scraper.ifc
}
puts "avg:   #{'%.2f' % (time/films.length)}s"
puts "total: #{'%.2f' % time}s"

theater = Theater.new
theater.films = films
columbus = theater.films_this_week[0][1]
puts columbus.week_overview
