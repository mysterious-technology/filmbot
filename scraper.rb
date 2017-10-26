#! /usr/bin/env ruby

require 'httparty'
require 'json'
require 'nokogiri'

class Film
  attr_accessor :title, :link, :dates, :blurb
end

=begin
bam: uses javascript, hard to scrape
village east: need to iterate over url to get week of dates
nitehawk: need to iterate over url to get week of dates
lincoln plaza: very minimal website
spectacle: too hipster, hard to scrape
alamo: too mainstream

CSS selectors:
descendant selector (space)
child selector (>)
adjacent sibling selector (+)
general sibling selector (~)
=end

# TODO
# replace dumb date parsing with query string parsing
# create actual date objects
# emailer
# optimize: parallel gets
class Scraper

  def get_doc(url)
    page = HTTParty.get(url)
    Nokogiri::HTML(page) { |c| c.noblanks }
  end
  private :get_doc

  # (fast) everything on one page :)
  def metrograph
    doc = get_doc('http://metrograph.com/film')

    films = doc.css('h4.title.narrow a').map { |link|
      # get the date selector element
      selector = doc.css("a[href=\"#{link['href']}\"]~div.text select.date")
      # get links for first and last date, links end with YYYY-MM-DD
      dates = selector.children.map { |e|
        e['value'].split('/').last
      }.uniq.map { |s|
        Date.strptime(s, "%Y-%m-%d")
      }
      # get the summary
      blurb = doc.css("a[href=\"#{link['href']}\"]~div.text div.summary").text.strip!

      film = Film.new
      film.title = link.text
      film.link = link['href']
      film.dates = dates
      film.blurb = blurb
      film
    }
    films
  end

  # (slow) get movie links, go to each page
  def ifc
    doc = get_doc('http://www.ifccenter.com')

    links = doc.css("div.details a[href*=\"ifccenter.com/films\"]").map { |l|
      l['href']
    }.uniq

    films = []
    for link in links
      doc = get_doc(link)

      # get the title
      title = doc.css("h1.title").text

      # get dates from movietickets links
      # https://www.movietickets.com/pre_purchase.asp?house_id=9598&movie_id=249296&rdate=10-25-2017
      dates = doc.css("ul.schedule-list a[href*=\"movietickets.com/pre_purchase.asp\"]").map { |l|
        link = l['href']
        link.split('=').last
      }.uniq.map { |s|
        Date.strptime(s, "%Y-%m-%d")
      }

      if dates.length == 0
        # films that are coming soon don't have dates
        next
      end

      # get twitter description
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

  # (slow) get movie links, go to each page
  def quad
    doc = get_doc('https://quadcinema.com')

    links = doc.css("a[href*=\"quadcinema.com/film\"]").map { |l|
      l['href']
    }.uniq

    films = []
    for link in links
      doc = get_doc(link)

      # get the title
      title = doc.css("h1.film-title").first.text

      # get dates from fandango links
      # http://www.fandango.com/quadcinema_aaefp/theaterpage?date=2017-10-31
      dates = doc.css("a[href*=\"fandango.com/quadcinema\"]").map { |l|
        link = l['href']
        link.split('=').last
      }.uniq.map { |s|
        Date.strptime(s, "%Y-%m-%d")
      }

      # blurb is the first p in the synopsis div
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

  # (slow) get movie links from calendar page, go to each page
  def filmlinc
    doc = get_doc('https://www.filmlinc.org/calendar/')

    links = doc.css("a[href*=\"filmlinc.org/films\"]").map { |l|
      l['href']
    }.uniq

    films = []
    for link in links
      doc = get_doc(link)

      # title is in the <title> tag
      title = doc.css("title").first.text

      # get dates (h4 in showtimes div)
      # format: Thursday, October 26
      dates = doc.css("div.day-showtimes h4").map { |e|
        e.text
      }.uniq.map { |s|
        Date.strptime(s, "%A, %B %d")
      }

      # blurb is the first p in the synopsis div
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

  # (slow) get movie links from calendar page, go to each page
  def angelika
    doc = get_doc('https://www.angelikafilmcenter.com/nyc/showtimes-and-tickets/now-playing')

    links = doc.css("a[href*=\"nyc/film\"]").map { |l|
      'https://www.angelikafilmcenter.com/' + l['href']
    }.uniq

    films = []
    for link in links
      doc = get_doc(link)

      # title is in the <title> tag
      title = doc.css("div.page-title h1").first.text

      # get dates, format: YYYY-MM-DD
      dates = doc.css("select.form-select option").map { |c|
        c['value']
      }.uniq.map { |s|
        Date.strptime(s, "%Y-%m-%d")
      }

      # blurb is in a meta tag
      blurb = doc.css("meta[name=description]").first["content"].strip!

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
  def filmforum
    doc = get_doc('https://filmforum.org/now_playing')

    links = doc.css("a[href*=\"filmforum.org/film\"]").map { |l|
      link = l['href']
      link = link.chomp("#trailer")
      link
    }.uniq

    films = []
    # for link in links
    link = links.first
      doc = get_doc(link)

      # title has class main-title
      title = doc.css("h1.main-title").first.text

      # get dates
      # formats:
      # "Tuesday, October 31"
      # "Wednesday, November 1 - Tuesday, November 14"
      # "HELD OVER! MUST END THURSDAY!"
      raw_date = doc.css("h1.main-title+div.details p").last.text
      dates = raw_date.split('-').map { |s|
        s.strip!
        format1 = "%A, %B %d"
        format2 = "HELD OVER! MUST END %A!"
        if Date._strptime(s, format1)
          return Date.strptime(s, format1)
        elsif Date._strptime(s, format2)
          return Date.strptime(s, format2)
        else
          return nil
        end
      }.reject! { |d|
        d.nil? || d.empty?
      }

      puts dates

      # get blurb
      blurb = doc.css("div.copy p").first.text

      film = Film.new
      film.title = title
      film.dates = dates
      film.link = link
      film.blurb = blurb
      films.push(film)
    # end
    films
  end

end
