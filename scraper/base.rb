require 'httparty'
require 'json'
require 'nokogiri'
require 'date'
require 'cgi'
require 'titleize'
require 'opengraph_parser'
require_relative '../helpers'
require_relative '../models/film'

=begin
other theaters:
bam: uses javascript, how do you scrape?
village east: iterate over url for week
nitehawk: iterate over url for week
lincoln plaza: no info to scrape
spectacle: hard to scrape
alamo: too mainstream

CSS selectors:
descendant selector (space)
child selector (>)
adjacent sibling selector (+)
general sibling selector (~)
=end

DATE_FORMATS = %w(%Y-%m-%d %m-%d-%Y).freeze

module Scraper
  class Base
    attr_accessor :url, :theater_name

    def initialize(url)
      @url = url
      class_name = self.class.name.split('::').last || ''
      @theater_name = class_name.gsub(/[A-Z]/, ' \0').titleize
    end

    public def doc
      @doc = @doc || get_doc(@url)
    end

    public def get_doc(url)
      raise 'no url' unless @url && @url.length > 0
      Nokogiri::HTML(HTTParty.get(url)) { |c| c.noblanks }
    end

    # scrapes unique links matching the pattern, stripping anchors
    # base_url will be prefixed to links if given
    public def scrape_film_links(doc, matching, base_url = nil)
      links = doc.css(" a[href*=\"#{matching}\"]").map { |element|
        link = element["href"].split("#").first.gsub("https", "http").chomp("/")
        if base_url
          link = base_url + link
        end
        link
      }.uniq

      puts "found #{links.length} film links"

      links
    end

    # scrapes showtime links, returning an array of dates
    public def scrape_showtime_links(doc, matching, container = nil)
      selector = "a[href*=\"#{matching}\"]"
      selector = "#{container} #{selector}" if container
      dates = doc.css(selector).map { |l|
        link = l['href']
        query_string = link.split('?').last
        query_params = CGI::parse(query_string)
        query_params.keys
          .select { |k| k.include?('date') }
          .each { |key|
            date_string = query_params[key].first
            DATE_FORMATS.each { |format|
              if Date._strptime(date_string, format)
                next Date.strptime(date_string, format)
              end
            }
          }
      }.uniq

      puts dates.length == 0 ? "⚠️ no dates found" : "found #{dates.length} showtimes"
      dates
    end

    public def to_s
      "[#{@url}]<#{@theater_name}>"
    end

    public def hash
      to_s.hash
    end

    public def ==(o)
      o.class == self.class && o.hash == hash
    end

    # abstract
    public def scrape
      raise 'unimplemented'
    end

    alias_method :eql?, :==

    public_class_method def self.dedupe(films)
      deduped = []
      films.each { |film|
        matching = deduped.select { |f| f.title.downcase == film.title.downcase }
        if matching.length > 0
          match = matching.first
          match.dates = (match.dates + film.dates).uniq
        else
          deduped.push(film)
        end
      }
      deduped
    end

    public_class_method def self.films_this_week(films)
      dedupe(films)
        .select { |f| f.week_overview_tomorrow }
        .sort_by { |f| f.title }
        .each_slice(2)
        .to_a
    end
  end
end
