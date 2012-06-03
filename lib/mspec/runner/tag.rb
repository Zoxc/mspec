class Tag
  attr_accessor :tag

  def initialize(tag)
    @tag = tag
  end

  def self.parse(string)
    klass, *args = eval string
    klass.new(*args)
  end

  def data
    []
  end

  def to_s
    [self.class, @tag, *data].inspect
  end

  def ==(o)
    self.class == o.class && @tag == o.tag
  end
end
