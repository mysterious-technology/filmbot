#! /usr/bin/env ruby

require 'httparty'
require 'json'
require 'nokogiri'
require 'date'
require 'cgi'
require 'titleize'

class Film
  attr_accessor :title, :link, :dates, :blurb

  def blurb
    # truncate to 280 chars
    @blurb.slice(0..280)
  end
end

=begin
other theaters:
bam: uses javascript, how do you scrape?
village east: iterate over url for week
nitehawk: iterate over url for week
lincoln plaza: no info to scrape
spectacle: hard to scrape
alamo: too mainstream

CSS selectors:
descendant selector (space)
child selector (>)
adjacent sibling selector (+)
general sibling selector (~)
=end

class Scraper

  # url -> Nokogiri doc
  def get_doc(url)
    page = HTTParty.get(url)
    Nokogiri::HTML(page) { |c| c.noblanks }
  end
  private :get_doc

  # removes all whitespace and non-ascii characters
  # important for parsing dates with spaces
  def sanitize(string)
    string = string.gsub(/[\u0080-\u00ff]/, "")
    string = string.gsub(/\s+/, "")
    string
  end
  private :sanitize

  # scrapes unique links matching the pattern, stripping anchors
  # base_url will be prefixed to links if given
  def scrape_film_links(doc, matching, base_url = nil)
    links = doc.css(" a[href*=\"#{matching}\"]").map { |element|
      link = element["href"]
      link = link.split("#").first # remove anchor
      link = link.gsub("https", "http")
      link = link.chomp("/")
      if base_url
        link = base_url + link
      end
      link
    }.uniq
    puts "found #{links.length} film links"
    links
  end

  # scrapes showtime links, returning an array of dates
  def scrape_showtime_links(doc, matching, container=nil)
    selector = "a[href*=\"#{matching}\"]"
    if container
      selector = "#{container} #{selector}"
    end

    dates = []
    formats = [
      "%Y-%m-%d",
      "%m-%d-%Y",
    ]
    doc.css(selector).each do |l|
      link = l['href']
      query_string = link.split('?').last
      query_params = CGI::parse(query_string)
      query_params.keys.each do |key|
        if key.include?('date')
          date_string = query_params[key].first
          formats.each do |format|
            if Date._strptime(date_string, format)
              date = Date.strptime(date_string, format)
              dates.push(date)
              next
            end
          end
        end
      end
    end
    dates = dates.uniq
    if dates.length == 0
      puts "⚠️ no dates found"
    end
    puts "found #{dates.length} showtimes"
    dates
  end

  # (fast, 1.2s) everything on one page
  def metrograph
    doc = get_doc('http://metrograph.com/film')

    film_els = doc.css('h4.title.narrow a')
    puts "found #{film_els.count} films"

    films = film_els.map { |e|

      link = e["href"]
      puts "parsing #{link}"

      # get title
      title = e.text.titleize

      # get dates
      selector = doc.css("a[href=\"#{link}\"]~div.text select.date")
      # get links for first and last date, links end with date
      dates = selector.children.map { |e|
        e['value'].split('/').last
      }.uniq.map { |s|
        # format: YYYY-MM-DD
        Date.strptime(s, "%Y-%m-%d")
      }
      if dates.length == 0
        puts "⚠️ no dates found"
        next
      end
      puts "found #{dates.length} dates"

      # get blurb
      blurb = doc.css("a[href=\"#{link}\"]~div.text div.summary").text.strip!

      film = Film.new
      film.title = title
      film.link = link
      film.dates = dates
      film.blurb = blurb
      film
    }
    films
  end

  # (slow, 12s) get movie links, go to each page
  def ifc
    doc = get_doc('http://www.ifccenter.com')

    links = scrape_film_links(doc, "ifccenter.com/films")

    films = []
    links.each do |link|
      puts "scraping #{link}"
      doc = get_doc(link)

      # get title
      title = doc.css("h1.title").text.titleize

      # get dates
      dates = scrape_showtime_links(doc, "movietickets.com/pre_purchase", "ul.schedule-list")

      # get blurb
      twitter_desc = doc.css("meta[name=\"twitter:description\"]").first['content']

      film = Film.new
      film.title = title
      film.link = link
      film.dates = dates
      film.blurb = twitter_desc
      films.push(film)
    end
    films
  end

  # (slow, 7s) get movie links, go to each page
  def quad
    doc = get_doc('https://quadcinema.com')

    links = scrape_film_links(doc, "quadcinema.com/film")

    films = []
    links.each do |link|
      puts "scraping #{link}"
      doc = get_doc(link)

      # get title
      title = doc.css("h1.film-title").first.text.titleize

      # get dates
      dates = scrape_showtime_links(doc, "fandango.com/quadcinema")

      # get blurb
      blurb = doc.css("div[class*=\"synopsis\"] p").first.text

      film = Film.new
      film.title = title
      film.dates = dates
      film.link = link
      film.blurb = blurb
      films.push(film)
    end
    films
  end

  # (slow, 6.8s) get movie links from calendar page, go to each page
  def angelika
    doc = get_doc('https://www.angelikafilmcenter.com/nyc/showtimes-and-tickets/now-playing')

    links = scrape_film_links(doc, "nyc/film", "https://www.angelikafilmcenter.com")

    films = []
    links.each do |link|
      puts "scraping #{link}"
      doc = get_doc(link)

      # get title
      title = doc.css("div.page-title h1").first.text.titleize

      # get dates
      dates = doc.css("select.form-select option").map { |e|
        e['value']
      }.uniq.map { |s|
        Date.strptime(s, "%Y-%m-%d")
      }
      if dates.length == 0
        puts "⚠️ no dates found"
        next
      end
      puts "found #{dates.length} dates"

      # get blurb
      meta_el = doc.css("meta[name=description]").first
      blurb = meta_el["content"].strip

      film = Film.new
      film.title = title
      film.dates = dates
      film.link = link
      film.blurb = blurb
      films.push(film)
    end
    films
  end

  # (slow, 1.9s) get movie links from calendar page, go to each page
  def filmlinc
    doc = get_doc('https://www.filmlinc.org/calendar/')

    links = scrape_film_links(doc, "filmlinc.org/films")

    films = []
    links.each do |link|
      puts "scraping #{link}"

      doc = get_doc(link)

      # get title
      title = doc.css("title").first.text.titleize

      # get dates
      dates = doc.css("div.day-showtimes h4").map { |e|
        e.text
      }.uniq.map { |s|
        # format: Thursday, October 26
        sanitized = sanitize(s)
        Date.strptime(sanitized, "%A,%B%d")
      }
      if dates.length == 0
        puts "⚠️ no dates found"
        next
      end
      puts "found #{dates.length} dates"

      # get blurb
      blurb = doc.css("div.post-content").first.text.strip!

      film = Film.new
      film.title = title
      film.dates = dates
      film.link = link
      film.blurb = blurb
      films.push(film)
    end
    films
  end

  # (super slow) get movie links from calendar page, go to each page
  # lots of movies per week at forum
  # currently way too slow (~2min), need to parallelize
  # leaving out for now
  def filmforum
    doc = get_doc('https://filmforum.org/now_playing')

    links = scrape_film_links(doc, "filmforum.org/film")

    films = []
    for link in links
      puts "scraping #{link}"

      doc = get_doc(link)

      # get title
      title = doc.css("h1.main-title").first.text.titleize

      # get dates: complicated
      # possible formats:
      # "Tuesday, October 31"
      # "Wednesday, November 1 - Tuesday, November 14"
      # "HELD OVER! MUST END THURSDAY!"
      possible_dates = doc.css("h1.main-title+div.details p").map { |e|
        e.text
      }

      # sanitize dates and split if hyphenated
      raw_dates = possible_dates.map { |s|
        s = sanitize(s).split('-')
      }.flatten

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
        opening_formats = [
          "Opens%A,%B%d",
          "OPENS%A,%B%d",
          "Opening%A,%B%d",
          "OPENING%A,%B%d",
        ]
        opening_formats.each do |f|
          if Date._strptime(s, f)
            dates.push(Date.strptime(s, f))
            is_opening = true
          end
        end
        closing_formats = [
          "HELDOVER!MUSTEND%A!",
          "MUSTEND%A!",
          "MustEnd%A!",
          "Mustend%A!",
          "ENDING%A!",
          "Ending%A!",
          "ENDS%A!",
          "Ends%A!",
        ]
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

      film = Film.new
      film.title = title
      film.dates = dates
      film.link = link
      film.blurb = blurb
      films.push(film)
    end
    films
  end

end
