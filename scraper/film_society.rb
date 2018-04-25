require_relative 'base'

module Scraper

  class FilmSociety < Base
    def initialize
      super('https://www.filmlinc.org/calendar/')
    end

    # (slow, 1.9s) get movie links from calendar page, go to each page
    def scrape
      scrape_film_links(doc, "filmlinc.org/films").map { |link|
        puts "scraping #{link}"
        child_doc = get_doc(link)
        title = child_doc.css("title").first.text.titleize
        date_strings = child_doc.css("div.day-showtimes h4").map { |e|
          e.text
        }
        dates = date_strings.uniq.map { |s|
          # format: Thursday, October 26
          Date.strptime(s.remove_whitespace, "%A,%B%d")
        }
        if dates.length == 0
          puts "⚠️ no dates found"
          next
        end
        puts "found #{dates.length} dates"

        # get blurb
        blurb = child_doc.css("div.post-content").first.text.strip!

        Film.new(title, dates, link, blurb)
      }.compact
    end
  end
end