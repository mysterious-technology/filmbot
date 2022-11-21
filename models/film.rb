# typed: true
class Film
  attr_accessor :title, :link, :dates, :blurb, :error
  DAYS = %w(Su M T W Th F S).freeze
  DIRECTOR_RE = /[dD]irected by:?\s(?<full_name>([A-Z][\wáéíóú-]+ ?){1,3})/
  DIRECTOR_RE_2 = /[dD]irector:?\s(?<full_name>([A-Z][\wáéíóú-]+ ?){1,3})/

  def initialize(title, link, dates, blurb, error)
    self.title = title
    self.link = link
    self.dates = dates
    self.blurb = blurb
    self.error = error
  end

  def blurb
    @blurb.slice(0..280)
  end

  def blurb_html
    director = DIRECTOR_RE.match(blurb)
    unless director
      director = DIRECTOR_RE_2.match(blurb)
    end
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
    now = Time.now.utc
    now_pst = now + Time.zone_offset("PDT")
    today = now_pst.to_date
    overview = (0..6).map { |i| today - 1 + i + day_offset }.map { |date|
      @dates.include?(date) ? DAYS[Integer(date.strftime('%w'))] : spacer
    }
    overview.uniq == [spacer] ? nil : overview.join(' ')
  end
end
