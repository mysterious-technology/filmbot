# typed: true
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
      memo = {}
      # NB limit to 9 because they put like a hundred days at a time
      doc.css('div.eventDay').take(9).map { |event_day|
        date_string = event_day.css('span.date h4').text
        next unless Date._strptime(date_string, DATE_FORMAT)
        dates = [Date.strptime(date_string, DATE_FORMAT)]
        event_day.xpath(".//a[starts-with(@href, '#{TICKET_URL}')]/../..").map { |event|
          purchase_node = at_link_like(TICKET_URL, event)
          imdb = at_link_like(IMDB_URL, event)

          next unless purchase_node && imdb

          imdb_url = imdb.attributes['href'].value
          memo[imdb_url] = graph = memo[imdb_url] || OpenGraph.new(imdb_url)
          link = purchase_node.attributes['href'].value

          Film.new(graph.title, link, dates, graph.description)
        }.compact
      }.compact.flatten
    end
  end
end