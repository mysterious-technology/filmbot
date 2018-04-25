require_relative 'base'

module Scraper

  class IFC < Base
    def initialize
      super('http://www.ifccenter.com')
    end

    # (slow, 12s) get movie links, go to each page
    def scrape
      links = scrape_film_links(doc, "ifccenter.com/films")
      links.map do |link|
        puts "scraping #{link}"
        child_doc = get_doc(link)
        title = child_doc.css("h1.title").text.titleize
        dates = scrape_showtime_links(child_doc, "movietickets.com/pre_purchase", "ul.schedule-list")
        twitter_desc = child_doc.css("meta[name=\"twitter:description\"]").first['content']
        Film.new(title, link, dates, twitter_desc)
      end
    end
  end
end