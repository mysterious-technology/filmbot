require_relative '../base'

module Scraper

  class Angelika < Base
    def initialize
      super('https://www.angelikafilmcenter.com/nyc/showtimes-and-tickets/now-playing')
    end

    # (slow, 6.8s) get movie links from calendar page, go to each page
    def scrape
      links = scrape_film_links(doc, "nyc/film", "https://www.angelikafilmcenter.com")
      links.map do |link|
        puts "scraping #{link}"
        child_doc = get_doc(link)

        # get title
        title = child_doc.css("div.page-title h1").first.text.titleize

        # get dates
        dates = child_doc.css("select.form-select option").map { |e|
          e['value']
        }.uniq.map { |s|
          Date.strptime(s, "%Y-%m-%d")
        }
        if dates.length == 0
          puts "⚠️ no dates found"
          next
        end
        puts "found #{dates.length} dates"

        # get blurb
        meta_el = child_doc.css("meta[name=description]").first
        blurb = meta_el["content"].strip

        Film.new(title, link, dates, blurb)
      end.compact
    end
  end
end