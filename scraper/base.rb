# typed: false
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
reference CSS selectors:
descendant (space)
child (>)
adjacent sibling (+)
general sibling (~)
=end

DATE_FORMATS = %w(%Y-%m-%d %m-%d-%Y).freeze

module Scraper
  class Base
    attr_accessor :url, :display_name, :url_name

    def initialize(url)
      @url = url
      class_name = self.class.name.split('::').last || ''
      @display_name = class_name.gsub(/[A-Z]/, ' \0').titleize
      @url_name = class_name.downcase
    end

    public def doc
      @doc = @doc || Base.get_doc(@url)
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

    public def to_s
      "[#{@url}]<#{@display_name}>"
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

    public_class_method def self.get_doc(url)
      raise 'no url' unless url && url.length > 0
      Nokogiri::HTML(HTTParty.get(url, timeout: 2)) { |c| c.noblanks }
    end
  end
end
