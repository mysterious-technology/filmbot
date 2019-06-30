# typed: true
class Film
  attr_accessor :title, :link, :dates, :blurb, :error
  DAYS = %w(Su M T W Th F S).freeze
  DIRECTOR_RE = /[dD]irected by (?<full_name>([A-Z][\wáéíóú]+ ?)+)/

  def initialize(title, link, dates, blurb, error)
    self.title = title
    self.link = link
    self.dates = dates
    self.blurb = blurb
    self.error = error
  end

  def blurb
    # truncate to 280 chars
    @blurb.slice(0..280)
  end

  def blurb_html
    director = DIRECTOR_RE.match(blurb)
    if director && director[:full_name]
      director[:full_name]
      blurb.gsub(director[:full_name], "<strong>#{director[:full_name]}</strong>")
    else
      blurb
    end
  end

  def week_overview
    overview
  end

  def week_overview_tomorrow
    overview(1)
  end

  def week2_overview
    overview(7)
  end

  private def overview(day_offset = 0)
    spacer = '-'
    overview = (0..6).map { |i| Date.today + i + day_offset }.map { |date|
      @dates.include?(date) ? DAYS[Integer(date.strftime('%w'))] : spacer
    }
    overview.uniq == [spacer] ? nil : overview.join(' ')
  end
end
