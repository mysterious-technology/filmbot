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

theater = Theater.new('Metrograph', 'http://metrograph.com')
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.metrograph
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new('IFC', 'http://www.ifccenter.com')
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.ifc
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new('Quad Cinema', 'https://quadcinema.com')
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.quad
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new('Angelika', 'https://www.angelikafilmcenter.com/nyc')
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.angelika
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new('Film Society', 'https://www.filmlinc.org')
print_header(theater)
time = Benchmark.realtime {
  theater.films = scraper.filmsociety
}
theaters.push(theater)
print_stats(time, theater)

theater = Theater.new('Film Forum', 'https://filmforum.org')
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
today_string = Date.today.strftime('%b %e, %Y')
timestamp = DateTime.now.strftime('%Y%m%dT%H%M')
template = File.read('email.erb')
result = ERB.new(template).result
File.write('email.html', result)

`open email.html`
