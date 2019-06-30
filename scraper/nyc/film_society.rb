# typed: true
require_relative '../base'

module Scraper

  class FilmSociety < Base
    def initialize
      super('https://www.filmlinc.org/calendar/')
      @display_name = 'Film Society'
      @url_name = 'film_society'
    end

    # get movie links from calendar page, go to each page
    def scrape
      errors = []
      films = scrape_film_links(doc, "filmlinc.org/films").map { |link|
        puts "scraping #{link}"
        child_doc = Base.get_doc(link)
        title = child_doc.css("title").first.text.titleize
        blurb = child_doc.css("div.post-content").first.text.strip!

        date_strings = child_doc.css("div.day-showtimes h4").map { |e|
          e.text
        }
        dates = date_strings.uniq.map { |s|
          # format: Thursday, October 26
          Date.strptime(s.remove_whitespace, "%A,%B%d")
        }
        if dates.length == 0
          error = "No dates: #{date_strings}"
          puts "⚠️ #{error}"
          errors << Film.new(title, link, dates, blurb, error)
          next
        end
        puts "found #{dates.length} dates"

        Film.new(title, link, dates, blurb, nil)
      }.compact
      {
        :films => films, 
        :errors => errors
      }
    end
  end
end