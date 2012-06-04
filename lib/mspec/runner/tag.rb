class Tag
  attr_accessor :tag
  
  ClassMap = {}

  def self.inherited(subclass)
    ClassMap[subclass.to_s] = subclass
  end

  def initialize(tag)
    @tag = tag
  end

  def self.parse(string)
    klass, *args = string.split(':').map { |c| unescape(c) }
    ClassMap[klass].new(*args)
  end

  def data
    []
  end
  
  def self.unescape(str)
    i = 0
    result = ""
    
    while i < str.size do
      c = str[i]
      i += 1
      if c == ?\\
        if str[i] == ?\\
          result << '\\'
          i += 1
        else
          result << str[i, 4].to_i(16).chr
          i += 4
        end
      else
        result << c
      end
    end
    
    result
  end

  def self.escape(str)
    result = ""
    str.each_char do |c|
      ord = c.ord
      case ord
        when 32..57, 59..91, 93..126
          result << c
        when 58
          result << '\\003A'
        when 92
          result << '\\\\'
        when 93..126
          result << c
        else
          result << '\\' << ord.to_s(16).rjust(4, "0")
      end
    end
    result
  end

  def to_s
    [self.class, @tag, *data].map { |c| Tag.escape(c.to_s) }.join(':')
  end

  def ==(o)
    self.class == o.class && @tag == o.tag
  end
end
