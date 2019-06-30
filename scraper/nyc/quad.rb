# typed: true
require_relative '../base'

module Scraper

  class Quad < Base
    def initialize
      super('https://quadcinema.com')
      @display_name = 'Quad Cinema'
      @url_name = 'quad'
    end

    # get movie links, go to each page, scrape fandango links
    def scrape
      errors = []
      links = scrape_film_links(doc, "quadcinema.com/film")
      films = links.map do |link|
        puts "scraping #{link}"
        child_doc = Base.get_doc(link)

        # get title
        title = child_doc.css("h1.film-title").first.text.titleize

        # get blurb
        blurb = ""
        synopsis_el = child_doc.css("div[class*=\"synopsis\"] p").first
        unless synopsis_el.nil?
          blurb = synopsis_el.text
        end

        # get dates
        dates = scrape_showtime_links(child_doc, "fandango.com/quadcinema")
        if dates.length == 0
          error = "No dates"
          puts "⚠️ #{error}"
          errors << Film.new(title, link, [], blurb, error)
          next
        end

        puts "found #{dates.length} showtimes"
        Film.new(title, link, dates, blurb, nil)
      end.compact
      {
        :films => films,
        :errors => errors, 
      }
    end

    # scrapes links matching a format
    # e.g. all showtimes on page are listed on fandango
    # returns an array of dates
    def scrape_showtime_links(doc, matching, container = nil)
      selector = "a[href*=\"#{matching}\"]"
      selector = "#{container} #{selector}" if container
      dates = doc.css(selector).map { |l|
        link = l['href']
        query_string = link.split('?').last
        query_params = CGI::parse(query_string)
        query_params.keys
          .select { |k| k.include?('date') }
          .map { |key|
            date_string = query_params[key].first
            DATE_FORMATS.map { |format|
              if Date._strptime(date_string, format)
                next Date.strptime(date_string, format)
              end
            }
          }.flatten.compact
      }.flatten.uniq

      dates
    end
  end

end
