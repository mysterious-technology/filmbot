require_relative '../base'

module Scraper
  class NewParkway < Base
    def initialize
      super('http://www.thenewparkway.com/?page_id=14')
    end

    # (slow, 12s) get movie links, go to each page
    def scrape
      doc.css('div.eventDay').map { |e|
        date = e.css('span.date h4')
        events = e.at_css('div.event span.summary').content
      }

      links = scrape_film_links(all_events_doc, 'ticketing.us.veezi.com/purchase')
    end
  end
end