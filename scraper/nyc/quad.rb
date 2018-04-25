require_relative '../base'

module Scraper

  class Quad < Base
    def initialize
      super('https://quadcinema.com')
    end

    # (slow, 7s) get movie links, go to each page
    def scrape
      links = scrape_film_links(doc, "quadcinema.com/film")
      links.map do |link|
        puts "scraping #{link}"
        child_doc = get_doc(link)

        # get title
        title = child_doc.css("h1.film-title").first.text.titleize

        # get dates
        dates = scrape_showtime_links(child_doc, "fandango.com/quadcinema")

        # get blurb
        blurb = ""
        synopsis_el = child_doc.css("div[class*=\"synopsis\"] p").first
        unless synopsis_el.nil?
          blurb = synopsis_el.text
        end

        Film.new(title, link, dates, blurb)
      end
    end
  end
end