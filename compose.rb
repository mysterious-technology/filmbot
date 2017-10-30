#! /usr/bin/env ruby

require 'benchmark'
require 'date'
require_relative 'scraper'
require_relative 'theater'

@total_time = 0

def print_header(theater)
  puts "☛ #{theater.name}"
end

def print_stats(time, theater)
  puts "=========================="
  puts "scraped #{theater.films.length} films in #{'%.2f' % time}s"
  puts "avg: #{'%.2f' % (time/theater.films.length)}s"
  puts "=========================="
  @total_time += time
end

scraper = Scraper.new
theaters = []

puts "~ i am filmbot ~"

theater = Theater.new
theater.name = 'Metrograph'
theater.link = 'http://metrograph.com'
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.metrograph
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new
theater.name = 'IFC'
theater.link = 'http://www.ifccenter.com'
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.ifc
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new
theater.name = 'Quad Cinema'
theater.link = 'https://quadcinema.com'
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.quad
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new
theater.name = 'Angelika'
theater.link = 'https://www.angelikafilmcenter.com/nyc'
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.angelika
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new
theater.name = 'Film Society'
theater.link = 'https://www.filmlinc.org'
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.filmsociety
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new
theater.name = 'Film Forum'
theater.link = 'https://filmforum.org'
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.filmforum
}
theaters.push(theater)
print_stats(time, theater)

puts "~ done scraping ~"
puts "scraped #{theaters.length} theaters in #{'%.2f' % @total_time}s"
puts "avg: #{'%.2f' % (@total_time/theaters.length)}s"

puts "~ writing email ~"
template = File.read('email.erb')
result = ERB.new(template).result
File.write('email.html', result)

`open email.html`
