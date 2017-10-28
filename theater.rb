#! /usr/bin/env ruby

require_relative 'scraper'

class Theater
  attr_accessor :name, :link, :films
  def films
    @films || []
  end

  def films_this_week
    films.select { |f|
      f.week_overview
    }.sort_by { |f| # alphabetize
      f.title
    }.each_slice(2).to_a # create a 2-column grid
  end
end

class Film
  attr_accessor :week_dates

  def week_overview
    week_dates = [0, 1, 2, 3, 4, 5, 6].map { |days|
      Date.today + days
    }
    spacer = '-'
    day_strings = ['Su', 'M', 'T', 'W', 'Th', 'F', 'S']
    overview = week_dates.map { |date|
      if @dates.include?(date)
        day_index = Integer(date.strftime('%w'))
        day_strings[day_index]
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
