require 'mspec/runner/filters/match'
require 'mspec/runner/filetag'

class FileFilter
  def initialize(*tags)
    @tags = tags
  end

  def ===(file)
    !MSpec.read_tags(@tags, FileTag).reject { |t| !@tags.include?(t.tag) }.empty?
  end

  def register
    MSpec.register :filter_file, self
  end

  def unregister
    MSpec.unregister :filter_file, self
  end
end
