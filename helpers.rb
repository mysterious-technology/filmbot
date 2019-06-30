# typed: false
class String
  # removes all whitespace and non-ascii characters
  # use when parsing dates with spaces
  def remove_whitespace
    gsub(/[\u0080-\u00ff]/, "")
    gsub(/\s+/, "")
  end
end

def load_and_new(files)
  before = ObjectSpace.each_object(Class).to_a
  files.each { |file| require file }
  diff = ObjectSpace.each_object(Class).to_a - before
  diff.map { |klass| klass.new }
end

def at_link_like(match, doc)
  doc.at_css("a[href*=\"#{match}\"]")
end
