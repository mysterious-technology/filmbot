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
  puts "☛ #{scraper.display_name}"
end

###############################
# start
###############################

@city = opts[:city]
limit = opts[:limit]
matching = opts[:matching] || '*'
results = {}
stats = {}

puts "~ i am filmbot ~"
abort 'feed me a city' unless @city

@stats = {}
@stats['start_utc'] = Time.now.utc.iso8601
files = Dir.glob("./scraper/#{@city}/#{matching}.rb")
@scrapers = load_and_new(files).select { |s| s.is_a? Scraper::Base }
@scrapers = @scrapers.take(limit) if limit

abort "filmbot does not know about #{@city}" unless @scrapers.count > 0

puts "~ scraping ~"
total_s = Benchmark.realtime {
  forks = []
  @scrapers.each do |scraper|
    forks << Process.fork do
      print_header(scraper)
      @theater_name = scraper.display_name
      @scraper_name = scraper.url_name
      @source = "https://github.com/benzguo/filmbot/tree/master/scraper/#{@city}/#{@scraper_name}.rb"
      @scraper_stats = {}
      time = Benchmark.realtime { @result = scraper.scrape }
      @films = @result[:films]
      @errors = @result[:errors]
      scraper_stats = {}
      scraper_total_s =  "#{'%.2f' % time}s"
      scraper_each_film_avg_s = "#{'%.2f' % (time / @films.size)}s"
      @scraper_stats['total_s'] = scraper_total_s
      @scraper_stats['each_film_avg_s'] = scraper_each_film_avg_s
      theater_template = File.read('theater.erb')
      theater_html = ERB.new(theater_template).result
      filename = "#{@city}_#{@scraper_name}.html"
      File.write(filename, theater_html)
      puts "=========================="
      puts "wrote #{filename}: #{@films.size} films in #{scraper_total_s}, #{@errors.size} errors"
      puts "=========================="
    end
  end
  Process.waitall
}

puts "~ done scraping ~"
total_s_str = "#{'%.2f' % total_s}s"

puts "~ combining results ~"
@stats['total_s'] = total_s_str
@stats['end_utc'] = Time.now.utc.iso8601
@today_string = Date.today.strftime('%e %b %Y')
@htmls = []
@scrapers.sort_by(&:url_name).each do |s|
  scraper_filename = "#{@city}_#{s.url_name}.html"
  @htmls << File.read(scraper_filename)
  `rm '#{scraper_filename}'`
end
template = File.read('index.erb')
result = ERB.new(template).result
File.write('index.html', result)

`open index.html`
