# typed: true
require_relative '../base'

module Scraper
  class Castro < Base
    BASE_URL = 'https://www.castrotheatre.com/p-list.html'.freeze
    # Jul 2
    DATE_FORMAT = '%b %d'.freeze

    def initialize
      super(BASE_URL)
      @display_name = 'Castro Theater'
      @url_name = 'castro'
    end

    def scrape
      links = scrape_film_links(doc, "https://prod3.agileticketing.net")
      errors = []
      films = links.map { |link|
        # link = links[0]
        puts "scraping #{link}"

        doc = Base.get_doc(link)

        title = doc.css("h1[class^=\"BigBoldText\"]").first.text.titleize
        blurb = doc.css("div.Description").first.text
        date_strings = doc.css("span.Date").map { |e|
          e.text
        }
        dates = date_strings.uniq.map { |s|
          Date.strptime(s, DATE_FORMAT)
        }
        if dates.length == 0
          error = "No dates: #{date_strings}"
          puts "⚠️ #{error}"
          errors << Film.new(title, link, dates, blurb, error)
          next
        end
        Film.new(title, link, dates, blurb, nil)
      }.compact
      {
        :films => films,
        :errors => errors,
      }
    end
  end
end
