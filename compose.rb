#! /usr/bin/env ruby

require 'benchmark'
require 'pry'
require 'date'
require 'slop'
require_relative 'scraper/base'
require_relative 'helpers'

opts = Slop.parse { |o| o.string '-c', '--city', 'city to scrape' }

@total_time = 0

def print_header(scraper)
  puts "☛ #{scraper.theater_name}"
end

def print_stats(time, films)
  puts "=========================="
  puts "scraped #{films.length} films in #{'%.2f' % time}s"
  puts "avg: #{'%.2f' % (time / films.length)}s"
  puts "=========================="
  @total_time += time
end

###############################
# 🎥 🤖 start filmbot 🎥 🤖
###############################

city = opts[:city]
results = {}

puts "~ i am filmbot ~"
abort 'feed me a city' unless city

files = Dir.glob("./scraper/#{city}/*.rb")
scrapers = load_and_new(files).select { |s| s.is_a? Scraper::Base }

abort "filmbot does not know about #{city}" unless scrapers.count > 0

scrapers.each { |scraper|
  print_header(scraper)
  time = Benchmark.realtime { results[scraper] = scraper.scrape }
  print_stats(time, results[scraper])
}

puts "~ done scraping ~"
puts "scraped #{results.length} theaters in #{'%.2f' % @total_time}s"
puts "avg: #{'%.2f' % (@total_time / results.length)}s"

puts "~ writing email ~"
today_string = Date.today.strftime('%b %e, %Y')
timestamp = DateTime.now.strftime('%Y%m%dT%H%M')
template = File.read('email.erb')
result = ERB.new(template).result
File.write('email.html', result)

`open email.html`
