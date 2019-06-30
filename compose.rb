#! /usr/bin/env ruby
# typed: true

require 'benchmark'
require 'pry'
require 'date'
require 'slop'
require_relative 'scraper/base'
require_relative 'helpers'

opts = Slop.parse { |o|
  o.string '-c', '--city', 'city to scrape'
  o.integer '-l', '--limit', 'limit to n theaters'
  o.string '-m', '--matching', 'custom matcher to only run over a subset glob of scrapers'
}

@total_time = 0

def print_header(scraper)
  puts "☛ #{scraper.theater_name}"
end

###############################
# start
###############################

city = opts[:city]
limit = opts[:limit]
matching = opts[:matching] || '*'
results = {}
stats = {}

puts "~ i am filmbot ~"
abort 'feed me a city' unless city

stats['global'] = {}
stats['global']['start_utc'] = Time.now.utc.iso8601
files = Dir.glob("./scraper/#{city}/#{matching}.rb")
scrapers = load_and_new(files).select { |s| s.is_a? Scraper::Base }
scrapers = scrapers.take(limit) if limit

abort "filmbot does not know about #{city}" unless scrapers.count > 0

total_s = Benchmark.realtime {
  scrapers.each { |scraper|
    print_header(scraper)
    time = Benchmark.realtime { results[scraper] = scraper.scrape }
    stats[scraper] = {}
    scraper_total_s =  "#{'%.2f' % time}s"
    scraper_avg_s = "#{'%.2f' % (time / results[scraper].length)}s"
    puts "=========================="
    puts "scraped #{results[scraper].length} films in #{scraper_total_s}"
    puts "avg: #{scraper_avg_s}"
    puts "=========================="
    stats[scraper]['total_s'] = scraper_total_s
    stats[scraper]['avg_s'] = scraper_avg_s
  }
}

puts "~ done scraping ~"

puts "~ writing email ~"
stats['global']['total_s'] = "#{'%.2f' % total_s}s"
stats['global']['end_utc'] = Time.now.utc.iso8601
today_string = Date.today.strftime('%e %b %Y')
template = File.read('email.erb')
result = ERB.new(template).result
File.write('email.html', result)

`open email.html`
