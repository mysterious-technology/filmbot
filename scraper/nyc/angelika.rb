# typed: true
require_relative '../base'

module Scraper

  class Angelika < Base
    def initialize
      super('https://www.angelikafilmcenter.com/nyc/showtimes-and-tickets/now-playing')
      @display_name = 'Angelika'
      @url_name = 'angelika'
    end

    # (slow, 6.8s) get movie links from calendar page, go to each page
    def scrape
      links = scrape_film_links(doc, "nyc/film", "https://www.angelikafilmcenter.com")
      errors = []
      films = links.map do |link|
        puts "scraping #{link}"
        child_doc = Base.get_doc(link)

        # get title
        title = child_doc.css("div.page-title h1").first.text.titleize

        # get blurb
        meta_el = child_doc.at_xpath("//article[contains(@aria-label, 'Synopsis')]/p[1]")
        dir_el = child_doc.at_xpath("//article[contains(@aria-label, 'Director')]/p[1]")
        blurb = meta_el.text
        if dir_el&.text
          blurb = "<h5>Directed by: #{dir_el.text}.</h5>\n#{blurb}"
        end

        # get dates
        dates = child_doc.css("select.form-select option").map { |e|
          e['value']
        }.uniq.map { |s|
          Date.strptime(s, "%Y-%m-%d")
        }
        if dates.length == 0
          error = "No dates"
          puts "⚠️ #{error}" 
          errors << Film.new(title, link, [], blurb, error)
          next
        end
        puts "found #{dates.length} dates"

        Film.new(title, link, dates, blurb, nil)
      end.compact
      {
        :films => films, 
        :errors => errors,
      }
    end
  end
end
