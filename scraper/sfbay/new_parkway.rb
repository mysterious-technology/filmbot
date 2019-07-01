# typed: true
require_relative '../base'

module Scraper
  class NewParkway < Base
    # MondayJuly1
    DATE_FORMAT = '%A%B%e'.freeze
    TICKET_URL = 'https://ticketing.us.veezi.com/purchase'.freeze

    def initialize
      super('http://www.thenewparkway.com/upcomingevents/calendar')
      @display_name = 'New Parkway'
      @url_name = 'new_parkway'
    end

    def scrape
      # NB limit to 30 because they put like a hundred days at a time
      links = scrape_film_links(doc, TICKET_URL).take(30)
      errors = []
      films = links.map { |link|
        puts "scraping #{link}"

        doc = Base.get_doc(link)

        title_attr = doc.css("img.poster").attr("alt")
        if title_attr.nil?
          next
        end
        title = title_attr.text

        blurb = doc.css("section[id=\"session-overview\"] p").text

        date_string = doc.css("span.showTime").text
        current_year = "#{Date.today.year}"
        date_string = date_string.split(current_year).first.remove_whitespace
        
        date = Date.strptime(date_string, DATE_FORMAT)        
        Film.new(title, link, [date], blurb, nil)
      }.compact
      {
        :films => films,
        :errors => errors,
      }
    end
  end
end