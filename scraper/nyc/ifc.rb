require_relative '../base'

module Scraper

  class IFC < Base
    DATE_FMT = '%a %b %d'
    TIME_FMT = '%l:%M %P'

    def initialize
      super('http://www.ifccenter.com')
    end

    # (slow, 12s) get movie links, go to each page
    def scrape
      links = scrape_film_links(doc, "ifccenter.com/films")
      links.map do |link|
        puts "scraping #{link}"
        child_doc = Base.get_doc(link)
        title = child_doc.css("h1.title").text.titleize
        dates = _get_dates(child_doc)
        twitter_desc = child_doc.css("meta[name=\"twitter:description\"]").first['content']
        Film.new(title, link, dates, twitter_desc)
      end
    end

    def _get_dates(doc)
      dates = []
      doc.css("ul.schedule-list div.details").map do |detail|
        date = detail.css('p strong')&.text
        if date && Date._strptime(date, DATE_FMT)
          times = detail.css('ul.times span')
          if times
            dates.concat(
              times.map(&:text).compact.select { |t| Date._strptime(t, TIME_FMT) }.map { |t| "#{date} #{t}" }
            )
          end
        end
      end
      dates = dates.uniq.map { |s| Date.strptime(s, "#{DATE_FMT} #{TIME_FMT}") }
      puts dates.length == 0 ? "⚠️ no dates found" : "found #{dates.length} showtimes"
      dates
    end
  end
end
