class Film
  attr_accessor :title, :link, :dates, :blurb

  def blurb
    # truncate to 280 chars
    @blurb.slice(0..280)
  end
end