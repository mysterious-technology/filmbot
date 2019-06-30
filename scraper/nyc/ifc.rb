# typed: true
require_relative '../base'

module Scraper

  class IFC < Base
    DATE_FMT = '%a %b %d'
    TIME_FMT = '%l:%M %P'

    def initialize
      super('http://www.ifccenter.com')
      @display_name = 'IFC'
      @url_name = 'ifc'
    end

    # (slow, 12s) get movie links, go to each page
    def scrape
      links = scrape_film_links(doc, "ifccenter.com/films")
      errors = []
      films = links.map do |link|
        puts "scraping #{link}"
        child_doc = Base.get_doc(link)
        title = child_doc.css("h1.title").text.titleize
        twitter_desc = child_doc.css("meta[name=\"twitter:description\"]").first['content']
        result = parse_dates(child_doc)
        dates = result[:dates]
        if dates.length == 0 
          error = result[:error]
          puts "⚠️ #{error}" 
          errors << Film.new(title, link, dates, twitter_desc, error)
          next
        end
        puts "found #{dates.length} showtimes"
        Film.new(title, link, dates, twitter_desc, nil)
      end.compact
      {
        :films => films,
        :errors => errors,
      }
    end

    def parse_dates(doc)
      dates = []
      date_strings = []
      doc.css("ul.schedule-list div.details").map do |detail|
        date_string = detail.css('p strong')&.text
        date_strings << date_string
        if date_string && Date._strptime(date_string, DATE_FMT)
          times = detail.css('ul.times span')
          if times
            dates.concat(
              times.map(&:text).compact.select { |t| Date._strptime(t, TIME_FMT) }.map { |t| "#{date_string} #{t}" }
            )
          end
        end
      end
      dates = dates.uniq.map { |s| 
        Date.strptime(s, "#{DATE_FMT} #{TIME_FMT}") 
      }
      date_display = doc.css("p.date-time")&.text
      {
        :dates => dates,
        :error => "No dates: \"#{date_display}\""
      }
    end
  end
end
