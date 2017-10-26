#! /usr/bin/env ruby

require 'benchmark'
require 'date'
require_relative 'scraper'

class Theater
  attr_accessor :name, :link, :films
  def films
    @films || []
  end

  def films_this_week
    films.select { |f|
      !f.week_overview.nil?
    }.sort_by { |f|
      f.title
    }.each_slice(2).to_a # create a 2-width grid
  end
end

class Film
  # TODO: optimize this
  def week_overview
    this_week = [0, 1, 2, 3, 4, 5, 6].map { |days|
      Date.today + days
    }
    spacer = '-'
    weekdays = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su']
    overview = this_week.map { |date|
      if @dates.include?(date)
        day_index = Integer(date.strftime('%w'))
        weekdays[day_index]
      else
        spacer
      end
    }
    # return nil if the film is not showing this week
    if overview.uniq == [spacer]
      nil
    else
      overview.join(" ")
    end
  end
end

scraper = Scraper.new

metrograph = Theater.new
metrograph.name = 'Metrograph'
metrograph.link = 'http://metrograph.com'
puts "scraping #{metrograph.name}"
puts Benchmark.realtime {
  metrograph.films = scraper.metrograph
}

ifc = Theater.new
ifc.name = 'IFC'
ifc.link = 'http://www.ifccenter.com'
puts "scraping #{ifc.name}"
puts Benchmark.realtime {
  ifc.films = scraper.ifc
}

quad = Theater.new
quad.name = 'Quad Cinema'
quad.link = 'https://quadcinema.com'
puts "scraping #{quad.name}"
puts Benchmark.realtime {
  quad.films = scraper.quad
}

angelika = Theater.new
angelika.name = 'Angelika'
angelika.link = 'https://www.angelikafilmcenter.com/nyc'
puts "scraping #{angelika.name}"
puts Benchmark.realtime {
  angelika.films = scraper.angelika
}

filmlinc = Theater.new
filmlinc.name = 'Film Society'
filmlinc.link = 'https://www.filmlinc.org'
puts "scraping #{filmlinc.name}"
puts Benchmark.realtime {
  filmlinc.films = scraper.filmlinc
}

# film forum is too slow (~2min)
# leave out for now
=begin
forum = Theater.new
forum.name = 'Film Forum'
forum.link = 'https://filmforum.org'
puts "scraping #{forum.name}"
puts Benchmark.realtime {
  forum.films = scraper.filmforum
}
=end

theaters = [
  metrograph,
  ifc,
  quad,
  angelika,
  filmlinc,
  # forum,
]

template = File.read('email.erb')
result = ERB.new(template).result
File.write('email.html', result)
