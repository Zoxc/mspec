require 'mspec/runner/actions/filter'

class TagProtectAction
  def initialize(action, outcome, tag)
    @action = action
    @outcome = outcome
    @tag = tag
    @report = []
    @ignore = false
    @count = 0
  end
  
  def before(state)
    @ignore = true
  end

  def after(exception)
    @ignore = false
  end

  # Returns true if the result of evaluating the protect matches
  # the _outcome_ registered for this tag action. See +TagAction+
  # for a description of the _outcome_ types.
  def outcome?(exception)
    @outcome == :all or
        (@outcome == :pass and not exception) or
        (@outcome == :fail and exception)
  end

  def done(exception)
    return if @ignore
    
    if outcome?(exception)
      tag = FileTag.new(@tag)

      case @action
      when :add
        changed = MSpec.write_tag tag
      when :del
        changed = MSpec.delete_tag tag
      end

      @report << "#{@count}) #{MSpec.retrieve(:file)}" if changed
    end
  end

  def no_exception
    done nil
  end

  def exception(exception)
    @count += 1
    done exception
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
        print "\nTagProtectAction: no files were tagged with '#{@tag}'\n"
      else
        print "\nTagProtectAction: files tagged with '#{@tag}':\n\n"
        print report
      end
    when :del
      if @report.empty?
        print "\nTagProtectAction: no tags '#{@tag}' were deleted\n"
      else
        print "\nTagProtectAction: tag '#{@tag}' deleted for files:\n\n"
        print report
      end
    end
  end

  def register
    MSpec.register :before,    self
    MSpec.register :after,     self
    MSpec.register :exception, self
    MSpec.register :no_exception, self
    MSpec.register :finish,    self
  end

  def unregister
    MSpec.unregister :before,    self
    MSpec.unregister :after,     self
    MSpec.unregister :exception, self
    MSpec.unregister :no_exception, self
    MSpec.unregister :finish,    self
  end
end
