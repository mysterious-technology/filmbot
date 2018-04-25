class String
  # removes all whitespace and non-ascii characters
  # use when parsing dates with spaces
  def remove_whitespace
    gsub(/[\u0080-\u00ff]/, "")
    gsub(/\s+/, "")
  end
end

