#! /usr/bin/env ruby

require 'httparty'
require 'json'
require 'nokogiri'

class Film
  attr_accessor :title, :link, :dates, :blurb
end

@metrograph = []
@ifc = []
@quad = []

# html is pretty clean and easy to query
def scrape_metrograph
  page = HTTParty.get('http://metrograph.com/film')
  doc = Nokogiri::HTML(page) { |c| c.noblanks }

  @metrograph = doc.css('h4.title.narrow a').map { |link|
    # get the date selector element
    selector = doc.css("a[href=\"#{link['href']}\"]~div.text select.date")
    # get links for first and last date, links end with YYYY-MM-DD
    dates = selector.children.map { |e|
      e['value'].split('/').last
    }
    # get the summary
    summary_el = doc.css("a[href=\"#{link['href']}\"]~div.text div.summary")

    film = Film.new
    film.title = link.text
    film.link = link['href']
    film.dates = dates
    film.blurb = summary_el.text.strip!
    film
  }
end

# html is messy, need to go to each page
def scrape_ifc
  page = HTTParty.get('http://www.ifccenter.com')
  doc = Nokogiri::HTML(page) { |c| c.noblanks }

  links = doc.css("div.details a[href*=\"ifccenter.com/films\"]").map { |l|
    l['href']
  }.uniq

  # navigate to each film page
  for link in links
    page = HTTParty.get(link)
    doc = Nokogiri::HTML(page) { |c| c.noblanks }

    # get the title
    title = doc.css("h1.title").text

    # get links with dates
    # dumb parsing right now, assuming date is the last element
    # TODO: parse query string
    # https://www.movietickets.com/pre_purchase.asp?house_id=9598&movie_id=249296&rdate=10-25-2017
    dates = doc.css("ul.schedule-list a[href*=\"movietickets.com/pre_purchase.asp\"]").map { |l|
      link = l['href']
      link.split('=').last
    }.uniq

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
    @ifc.push(film)
  end
end

# scrape_metrograph
# puts @metrograph.map { |f| f.inspect }

# scrape_ifc
# puts @ifc.map { |f| f.inspect }

scrape_quad
puts @quad.map { |f| f.inspect }

=begin
CSS selectors:
descendant selector (space)
child selector (>)
adjacent sibling selector (+)
general sibling selector (~)
=end

# FilmLinc has a JSON object on https://www.filmlinc.org/now-playing/ with showing info
# will need deduping

=begin METROGRAPH
# pretty straightforward to parse
<div class="film">

<a href="http://metrograph.com/film/film/1072/stand-by-me" class="image"><img src="/uploads/films/sm5-1504625651-600x310.jpg" width="600" height="310" alt="STAND BY ME " /></a>

<div class="text">

<select class="date" disabled="disabled">
<option value="http://metrograph.com/film/film/times/1072/2017-10-27">Friday October 27</option>
<option value="http://metrograph.com/film/film/times/1072/2017-10-28">Saturday October 28</option>
<option value="http://metrograph.com/film/film/times/1072/2017-10-29">Sunday October 29</option>
</select>

<h4 class="title narrow"><a href="http://metrograph.com/film/film/1072/stand-by-me">STAND BY ME </a></h4>

<div class="showtimes">
<a href="https://t.metrograph.com/Ticketing/visSelectTickets.aspx?cinemacode=9999&txtSessionId=6092">10:30pm</a>						<noscript>
<div class="nojs"><a href="/calendar?film=1072">All dates &amp; times&hellip;</a></div>
</noscript>
</div>

<div class="details">
DIRECTOR: ROB REINER <br />						<span class="specs">1986 / 89min / DCP</span>
</div>
<div class="summary">
Adapting King’s novella “The Body,” Reiner created this rightly beloved, clear-eyed evocation of 1950s America, starring River Phoenix, Wil Wheaton, Corey Feldman, and Jerry O’Connell as a group of adolescent friends in small-town Oregon who set out to find a missing boy who is believed dead. 					</div>
<div class="more">
<a href="http://metrograph.com/film/film/1072/stand-by-me">MORE&hellip;</a>
</div>
</div>
</div>
=end
