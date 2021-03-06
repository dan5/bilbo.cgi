# -*- encoding: UTF-8 -*-
require 'date'
class Entry
  def date
    Date.parse(label.to_s[/\A\d{8}/])
  rescue TypeError
    update_at
  end

  def update_at
    chdir(:entries) { File.mtime(filename) }
  end
end

Plugin.add_hook(:before_entry) {|entry|
  %Q!<div class="date">#{ entry.date }</div>!
}
