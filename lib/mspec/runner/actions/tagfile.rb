require 'mspec/runner/actions/filter'

class TagFileAction
  def initialize(action, outcome, tag)
    @action = action
    @outcome = outcome
    @tag = tag
    @report = []
    @ignore = false
    @count = 0
    @exception = nil
  end
  
  def before(state)
    @ignore = true
  end

  def after(exception)
    @ignore = false
  end

  def exception(exception)
    @count += 1
    @exception = @count unless @ignore
  end

  # Returns true if the result of evaluating the protect matches
  # the _outcome_ registered for this tag action. See +TagAction+
  # for a description of the _outcome_ types.
  def outcome?
    @outcome == :all or
        (@outcome == :pass and not exception?) or
        (@outcome == :fail and exception?)
  end

  # Returns true if an exception was raised while evaluating the
  # current file
  def exception?
    @exception
  end

  def load
    @exception = nil
  end

  def unload
    if outcome?
      tag = FileTag.new(@tag)

      case @action
      when :add
        changed = MSpec.write_tag tag
      when :del
        changed = MSpec.delete_tag tag
      end

      @report << (@exception ? "#{@exception}) " : "") + MSpec.retrieve(:file) if changed
    end
  end

  def report
    @report.join("\n") + "\n"
  end
  private :report

  # Callback for the MSpec :finish event. Prints the actions
  # performed while evaluating the examples.
  def finish
    case @action
    when :add
      if @report.empty?
        print "\nTagFileAction: no files were tagged with '#{@tag}'\n"
      else
        print "\nTagFileAction: files tagged with '#{@tag}':\n\n"
        print report
      end
    when :del
      if @report.empty?
        print "\nTagFileAction: no tags '#{@tag}' were deleted\n"
      else
        print "\nTagFileAction: tag '#{@tag}' deleted for files:\n\n"
        print report
      end
    end
  end

  def register
    MSpec.register :unload, self
    MSpec.register :before,    self
    MSpec.register :after,     self
    MSpec.register :exception, self
    MSpec.register :finish,    self
  end

  def unregister
    MSpec.unregister :unload, self
    MSpec.unregister :before,    self
    MSpec.unregister :after,     self
    MSpec.unregister :exception, self
    MSpec.unregister :finish,    self
  end
end
