#! /usr/bin/env ruby

require 'dotenv'
require 'mailgun-ruby'
require_relative 'scraper'

class Theater
  attr_accessor :name, :link, :films
  @films = []
end

def markdown
  renderer = Redcarpet::Render::StripDown
  markdown = Redcarpet::Markdown.new(renderer, {})
  markdown.new(yield).to_html
end

scraper = Scraper.new

metrograph = Theater.new
metrograph.name = 'Metrograph'
metrograph.link = 'http://metrograph.com'
# metrograph.films = scraper.metrograph
#
ifc = Theater.new
ifc.name = 'IFC'
ifc.link = 'http://www.ifccenter.com'
# ifc.films = scrape_ifc
#
quad = Theater.new
quad.name = 'Quad'
quad.link = 'https://quadcinema.com'
# quad.films = scrape_quad
#
angelika = Theater.new
angelika.name = 'Angelika'
angelika.link = 'https://www.angelikafilmcenter.com/nyc'
# angelika.films = scraper.angelika
#
filmlinc = Theater.new
filmlinc.name = 'Film Society'
filmlinc.link = 'https://www.filmlinc.org'
# filmlinc.films = scraper.filmlinc

forum = Theater.new
forum.name = 'Film Forum'
forum.link = 'https://filmforum.org'
forum.films = scraper.filmforum
forum.films.each { |f|
  puts f.inspect
}



theaters = [
  metrograph,
  # forum,
]
template = File.read('email.erb')
result = ERB.new(template).result


File.write('email.html', result)

Dotenv.load
# puts ENV['MAILGUN_API_KEY']
