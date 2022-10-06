# typed: true
require_relative '../base'

module Scraper

  class Syndicated < Base
    DATE_FORMAT = '%A %d, %B'.freeze
    def initialize
      super('https://ticketing.useast.veezi.com/sessions/?siteToken=dxdq5wzbef6bz2sjqt83ytzn1c')
      @display_name = 'Syndicated'
      @url_name = 'syndicated'
    end

    # get movie links from calendar page, go to each page
    def scrape
      errors = []
      films = []
      blurbs_by_name = {}
      doc.css('div.date').each do |d|
        date_string = d.css(".date-title").first.text
        date = Date.strptime(date_string, DATE_FORMAT)
        d.css(".film").each { |f| 
          title = f.css(".title").first.text
          link = f.css(".session-times li a").first['href']
          if blurbs_by_name[title]
            blurb = blurbs_by_name[title]
          else
            detail = Base.get_doc(link)
            blurb = detail.css(".synopsis p").first&.text
            blurbs_by_name[title] = blurb
          end
          films << Film.new(title, link, [date], blurb, nil)
        }
      end
      
      {
        :films => films, 
        :errors => errors
      }
    end
  end
end
