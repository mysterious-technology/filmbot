require_relative '../base'

module Scraper
  class NewParkway < Base
    DATE_FORMAT = '%A, %B %e, %Y'.freeze
    TICKET_URL = 'https://ticketing.us.veezi.com/purchase'.freeze
    IMDB_URL = 'www.imdb.com'.freeze

    def initialize
      super('http://www.thenewparkway.com/?page_id=14')
    end

    def scrape
      doc.css('div.eventDay').take(9).map { |event_day|
        date_string = event_day.css('span.date h4').text
        next unless Date._strptime(date_string, DATE_FORMAT)
        dates = [Date.strptime(date_string, DATE_FORMAT)]
        event_day.xpath(".//a[starts-with(@href, '#{TICKET_URL}')]/../..").map { |event|
          purchase_node = event.at_css("a[href*=\"#{TICKET_URL}\"]")
          imdb = event.at_css("a[href*=\"#{IMDB_URL}\"]")
          next unless purchase_node && imdb

          graph = OpenGraph.new(imdb.attributes['href'].value)
          link = purchase_node.attributes['href'].value

          Film.new(graph.title, link, dates, graph.description)
        }.compact
      }.compact.flatten
    end
  end
end