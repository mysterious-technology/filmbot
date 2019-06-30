# typed: false
require_relative '../base'

module Scraper

  class FilmForum < Base
    def initialize
      super('https://filmforum.org/now_playing')
    end

    # (super slow) get movie links from calendar page, go to each page
    # lots of movies per week at forum
    # currently way too slow (~2min), need to parallelize
    # leaving out for now
    def scrape
      links = scrape_film_links(doc, "filmforum.org/film")
      links.map { |link|
        puts "scraping #{link}"

        doc = Base.get_doc(link)

        # get title
        title = doc.css("h2.main-title").inner_html.gsub('<br>',' ')

        # get dates: complicated
        # possible formats:
        # "Tuesday, October 31"
        # "Wednesday, November 1 - Tuesday, November 14"
        # "HELD OVER! MUST END THURSDAY!"
        possible_dates = doc.css("h2.main-title+div.details p").map { |e| e.text }

        # sanitize dates and split if hyphenated
        raw_dates = possible_dates.map { |s| s.remove_whitespace.split('-') }.flatten

        # depending on number of dates and format, determine if datestring is:
        # 1. range of dates
        # 2. opening date
        # 3. closing date
        is_range = false
        is_opening = false
        is_closing = false
        dates = []
        raw_dates.each do |s|
          range_formats = [
            "%A,%B%d"
          ]
          range_formats.each do |f|
            if Date._strptime(s, f)
              dates.push(Date.strptime(s, f))
              is_range = true
              next
            end
          end
          opening_formats = %w(Opens%A,%B%d OPENS%A,%B%d Opening%A,%B%d OPENING%A,%B%d)
          opening_formats.each do |f|
            if Date._strptime(s, f)
              dates.push(Date.strptime(s, f))
              is_opening = true
            end
          end
          closing_formats = %w(HELDOVER!MUSTEND%A! MUSTEND%A! MustEnd%A! Mustend%A! ENDING%A! Ending%A! ENDS%A! Ends%A! Through%A,%B%d)
          closing_formats.each do |f|
            if Date._strptime(s, f)
              dates.push(Date.strptime(s, f))
              is_closing = true
            end
          end
        end

        # fill in intermediate dates
        new_dates = []
        # if closing, fill in dates from today
        if is_closing
          date = Date.today
          last_date = dates.first
          while date <= last_date
            new_dates.push(date)
            date += 1
          end
          # if range, fill in dates in-between
        elsif is_range
          date = dates.first
          while date <= dates.last
            new_dates.push(date)
            date += 1
          end
          # if opening, there should only be one date
        elsif is_opening && dates.length == 1
          new_dates = dates
          # date parsing error
        else
          puts "⚠️ Error parsing dates #{raw_dates}"
          next
        end
        dates = new_dates
        puts "found #{dates.length} dates"

        # get blurb
        blurb = doc.css("div.copy p").sort_by { |e|
          e.text.length # choose longest <p> text
        }.last.text

        Film.new(title, link, dates, blurb)
      }.compact
    end
  end
end
