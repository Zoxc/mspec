require 'mspec/runner/tag'

class SpecTag < Tag
  attr_accessor :comment, :description

  def initialize(tag, comment, description)
    super tag
    @comment = comment.to_s
    @description = description.to_s
  end

  def data
    [@comment, @description]
  end

  def ==(o)
    super and @comment == o.comment and @description == o.description
  end
end
