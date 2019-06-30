# typed: true
require_relative '../base'

module Scraper
  class MetroGraph < Base
    def initialize
      super('http://metrograph.com/film')
      @display_name = 'MetroGraph'
      @url_name = 'metrograph'
    end

    # everything on one page, fast
    def scrape
      film_els = doc.css('h4.title.narrow a')
      puts "found #{film_els.count} films"

      errors = []
      films = film_els.map { |e|
        link = e["href"]
        puts "parsing #{link}"
        title = e.text.titleize
        selector = doc.css("a[href=\"#{link}\"]~div.text select.date")
        # get links for first and last date, links end with date
        dates = selector.children.map { |e|
          e['value'].split('/').last
        }.uniq.map { |s|
          Date.strptime(s, "%Y-%m-%d")
        }
        if dates.length == 0
          error = "No dates"
          puts "⚠️ #{error}"
          errors << Film.new(title, link, dates, blurb, error)
          next
        end
        puts "found #{dates.length} dates"

        # get blurb
        blurb = doc.css("a[href=\"#{link}\"]~div.text div.summary").text.strip!

        Film.new(title, link, dates, blurb, nil)
      }.compact
      {
        :films => films,
        :errors => errors,
      }
    end
  end
end
