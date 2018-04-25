class Film
  attr_accessor :title, :link, :dates, :blurb
  DAYS = %w(Su M T W Th F S).freeze

  def initialize(title, link, dates, blurb)
    self.title = title
    self.link = link
    self.dates = dates
    self.blurb = blurb
  end

  def blurb
    # truncate to 280 chars
    @blurb.slice(0..280)
  end

  def week_overview_tomorrow
    overview(1)
  end

  def week_overview
    overview
  end

  def week2_overview
    overview(7)
  end

  def overview(day_offset = 0)
    spacer = '-'
    overview = (0..6).map { |i| Date.today + i + day_offset }.map { |date|
      @dates.include?(date) ? DAYS[Integer(date.strftime('%w'))] : spacer
    }
    overview.uniq == [spacer] ? nil : overview.join(' ')
  end
end