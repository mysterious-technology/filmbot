#! /usr/bin/env ruby

require_relative 'scraper'

class Theater
  attr_accessor :name, :link, :films

  def initialize(name, link)
    @name = name
    @link = link
  end

  # dedupe films
  def self.dedupe(films)
    deduped = []
    films.each do |film|
      matching = deduped.select { |f|
        f.title == film.title
      }
      if matching.length > 0
        match = matching.first
        match.dates = (match.dates + film.dates).uniq
      else
        deduped.push(film)
      end
    end
    deduped
  end

  def films_this_week
    Theater.films_this_week(@films)
  end

  def self.films_this_week(films)
    dedupe(films).select { |f|
      f.week_overview
    }.sort_by { |f| # alphabetize
      f.title
    }.each_slice(2).to_a # create a 2-column grid
  end

  def films_this_or_next_week
    Theater.films_this_or_next_week(@films)
  end

  def self.films_this_or_next_week(films)
    films.select { |f|
      f.week_overview || f.week2_overview
    }.sort_by { |f| # alphabetize
      f.title
    }.each_slice(2).to_a # create a 2-column grid
  end

end

class Film
  attr_accessor :week_dates

  def week2_overview
    week_dates = [0, 1, 2, 3, 4, 5, 6].map { |days|
      Date.today + days + 7
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

  def week_overview_tomorrow
    week_dates = [0, 1, 2, 3, 4, 5, 6].map { |days|
      Date.today + days + 1
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
