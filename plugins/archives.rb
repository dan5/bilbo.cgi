# -*- encoding: UTF-8 -*-
load 'plugins/helper.rb'

class Controller
  def archives(date = params[:date] || '20')
    @entries = Entry.find(date, :limit => (params[:limit] || 200).to_i,
                                :page => (params[:page] || 0).to_i)
    @title = "#{config[:title]}: archives"
    render(:archives)
  end
end

Plugin.views[:archives] = <<VIEW
<div class="archives">
  <%= Plugin.render_hook(:before_archives) %>
  <div><h2>Entries</h2>
  <ul>
  <% @entries.each do |entry| %>
    <li><%= link_to entry.date, :action => :permalink, :date => entry.label %> <%= entry.title %></li>
  <% end %>
  </ul>
  </div>
</div>
VIEW
