class TestLogger
  def debug(string)
    entries << string
  end

  def latest_entry
    entries.last
  end

  private

  def entries
    @entries ||= []
  end
end

