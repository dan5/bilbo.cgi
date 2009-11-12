load 'plugins/helper.rb'

class Controller
  def permalink
    @entry = Entry.find(params[:date], :limit => 1, :complete_label => true).first
    @title = "#{@entry.title.gsub(/<.*?>/, '')} - #{config[:title]}"
    render(:entry)
  end
end

Plugin.add_hook(:after_entry) {|entry|
  if action_name == :list
    %Q!<span class="permalink">#{ link_to 'permalink', :action => :permalink, :date => entry.label }</span>!
  end
}
