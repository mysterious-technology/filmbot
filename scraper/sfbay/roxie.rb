# typed: true
require_relative '../base'

module Scraper
  class Roxie < Base
    BASE_URL = 'https://www.roxie.com'.freeze
    DATE_FORMAT = '%A, %B %e'.freeze
    IGNORE_DATE = ['Today, ', 'Tomorrow, ']

    def initialize
      super(BASE_URL)
      @display_name = 'Roxie Theater'
      @url_name = 'roxie'
    end

    def scrape
      memo = {}
      films = doc.css('div.roxie-showtimes_widget div.roxie-showtimes').map { |day|
        raw_date = day.css('h3').text
        cleaned = IGNORE_DATE.reduce(raw_date) { |m, c| m.gsub(c, '') }
        date = Date.strptime(cleaned, DATE_FORMAT)
        day.css('li').map { |show|
          showtime_node = at_link_like(BASE_URL, show)
          link = showtime_node.attributes['href'].value
          title = showtime_node.text.titleize
          memo[link] = memo[link] || Base.get_doc(link)
          detail = memo[link].css('div.content p').collect(&:text).max_by(&:length)
          Film.new(title, link, [date], detail, nil)
        }
      }.flatten
      {
        :films => films, 
        :errors => [],
      }
    end
  end
end
