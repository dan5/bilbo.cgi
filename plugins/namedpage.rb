# -*- encoding: UTF-8 -*-
class Controller
  def named
    @page_name = params[:name] || params.index(nil).to_s
    @entry = Entry.find(@page_name, :limit => 1, :complete_label => true).first
    @title = "#{config[:title]}: #{@page_name}"
    render(:entry)
  end
end

def default_action
  params.index(nil) ? :named : :list
end
