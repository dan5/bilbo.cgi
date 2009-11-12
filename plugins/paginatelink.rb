# -*- encoding: UTF-8 -*-
def paginate_link(entries)
  page  = params[:page].to_i
  limit = params[:limit].to_i
  limit = config[:limit] || 5 if limit <= 0
  options = params.dup
  options[:page]  = page + 1
  options[:limit] = limit
  pre_entries = Entry.find(options[:date] || '20', options)
  options[:date]  = params[:date] if params[:date]
  html = []
  if pre_entries.size > 0
    html << %Q!<span class="paginate">#{ link_to "&lt;前の#{pre_entries.size}件", options }</span>!
  end
  if page > 0
    options[:page] = page - 1
    html << %Q!<span class="paginate">#{ link_to "次の#{limit}件&gt;", options }</span>!
  end
  html.join(' | ')
end

Plugin.add_hook(:before_entries) {|entries|
  paginate_link(entries)
}

Plugin.add_hook(:after_entries) {|entries|
  paginate_link(entries)
}
