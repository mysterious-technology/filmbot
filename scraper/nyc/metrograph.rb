# typed: true
require_relative '../base'


module Scraper
  class MetroGraph < Base
    BASE_URL = "http://metrograph.com".freeze
    # Thursday October 6
    DATE_FORMAT = '%A %B %d'.freeze

    # Mon October 6
    DATE_FORMAT_ALT = '%a %B %d'.freeze
    def initialize
      super(BASE_URL + '/calendar')
      @display_name = 'MetroGraph'
      @url_name = 'metrograph'
    end

    # everything on one page, fast
    def scrape
      day_elems = doc.css('div.calendar-list-day')
      puts "found #{day_elems.count} days on the calendar"
      errors = []
      films_by_id = {}
      day_elems.each { |e|
        day_text = e.css('.date').text
        if day_text.strip.empty?
          next
        end
        puts "parsing #{day_text}"
        begin
          date = Date.strptime(day_text, DATE_FORMAT)
        rescue ArgumentError
          date = Date.strptime(day_text, DATE_FORMAT_ALT)
        end
        e.css('.group .items .item').each { |item|
          t = item.css('a.title').first
          title = t.text.titleize
          link = t["href"]
          if films_by_id[link]
            films_by_id[link].dates << date
          else
            full_url = (link =~ /^\//).nil? ? link : "#{BASE_URL}#{link}"
            films_by_id[link] = Film.new(title, full_url, [date], "", nil)
          end
        }
      }
      # get blurbs one by one - slow
      films_by_id.values.each { |f|
        begin
          doc = Base.get_doc(f.link)
          dir_info = doc.css('h5').find { |t| t.text.include?("Director:") }
          blurb = doc.css("div.movie-info p").text
          if dir_info
            blurb = "#{dir_info}\n#{blurb}"
          end
        rescue
          blurb = ""
        end
        f.blurb = blurb
      }
      {
        :films => films_by_id.values,
        :errors => errors,
      }
    end
  end
end
