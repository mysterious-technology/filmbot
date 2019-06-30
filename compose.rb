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

@stats = {}
@stats['start_utc'] = Time.now.utc.iso8601
files = Dir.glob("./scraper/#{city}/#{matching}.rb")
scrapers = load_and_new(files).select { |s| s.is_a? Scraper::Base }
scrapers = scrapers.take(limit) if limit

abort "filmbot does not know about #{city}" unless scrapers.count > 0

theater_names = scrapers.map { |s| s.theater_name }

puts "~ scraping ~"
total_s = Benchmark.realtime {
  forks = []
  while scrapers.size > 0
    scraper = scrapers.shift
    forks << Process.fork do
      print_header(scraper)
      @theater_name = scraper.theater_name
      @scraper_stats = {}
      time = Benchmark.realtime { @films = scraper.scrape }
      scraper_stats = {}
      scraper_total_s =  "#{'%.2f' % time}s"
      scraper_avg_s = "#{'%.2f' % (time / @films.size)}s"
      @scraper_stats['total_s'] = scraper_total_s
      @scraper_stats['avg_s'] = scraper_avg_s
      theater_template = File.read('theater.erb')
      theater_html = ERB.new(theater_template).result
      filename = "#{city}_#{@theater_name}.html"
      File.write(filename, theater_html)
      puts "=========================="
      puts "wrote #{filename}: #{@films.size} films in #{scraper_total_s}"
      puts "=========================="
    end
  end
  Process.waitall
}

puts "~ done scraping ~"
total_s_str = "#{'%.2f' % total_s}s"
puts "#{total_s_str}"

puts "~ combining results ~"
@stats['total_s'] = total_s_str
@stats['end_utc'] = Time.now.utc.iso8601
@today_string = Date.today.strftime('%e %b %Y')
@htmls = []
theater_names.each do |theater_name|
  theater_filename = "#{city}_#{theater_name}.html"
  @htmls << File.read(theater_filename)
  `rm '#{theater_filename}'`
end
template = File.read('index.erb')
result = ERB.new(template).result
File.write('index.html', result)

`open index.html`
