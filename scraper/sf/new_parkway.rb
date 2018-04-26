require_relative '../base'

module Scraper
  class NewParkway < Base
    DATE_FORMAT = '%A, %B %e, %Y'.freeze
    TICKET_URL = 'https://ticketing.us.veezi.com/purchase'.freeze

    def initialize
      super('http://www.thenewparkway.com/?page_id=14')
    end

    # (slow, 12s) get movie links, go to each page
    def scrape
      doc.css('div.eventDay').map { |event_day|
        date_string = event_day.css('span.date h4').text
        next unless Date._strptime(date_string, DATE_FORMAT)
        dates = [Date.strptime(date_string, DATE_FORMAT)]
        event_day.xpath(".//a[starts-with(@href, '#{TICKET_URL}')]/../..").map { |event|
          title = event.css('span.summary').text
          link = event.at_css("a[href*=\"#{TICKET_URL}\"]").attributes['href'].value
        }

        # Film.new(title, link, dates, twitter_desc)
      }.compact
    end
  end
end