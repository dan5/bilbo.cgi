class Controller
  def newentry
    params[:name] ||= 'new'
    named()
  end

  def save
    time = Time.now
    src = Entry.new('new.txt').body
    src.split(/^--$/).each_with_index do |body, i|
      filename = sprintf("%4d%02d%02d_%02d.txt",time.year, time.month, time.day, i)
      chdir(:entries) { open(filename, 'w') {|f| f.write(body) } }
    end
    '<meta http-equiv="Refresh" content="1;URL=./"><a href="./">Latest</a>'
  end
end



if action_name == :newentry
  def link_to_save
    %Q!<div class="save">#{ link_to 'save', :action => :save }</div>!
  end

  Plugin.add_hook(:before_content) { link_to_save }
  Plugin.add_hook(:after_content) { link_to_save }
end
