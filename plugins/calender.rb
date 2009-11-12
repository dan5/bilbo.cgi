# -*- encoding: UTF-8 -*-:wq
def years
  2000..Time.now.year
end

def months
  data = {}
  years.map {|y| 
    (1..12).map {|m|
      unless Entry.find(pattern(y, m), :limit => 1).empty?
        data[y] ||= []
        data[y] << m
      end
    }
  }
  data
end

def pattern(y, m = nil, d = nil)
  ptn = "%04d" % y
  ptn += "%02d" % m if m
  ptn += "%02d" % d if d
  ptn
end

def link_to_month(ptn)
  month = /^(\d\d\d\d)(\d\d)/.match(ptn)[2]
  options = { :date => ptn, :calender => :on, :limit => 100 }
  link_to (block_given? ? yield(month) : month), options
end

def calender_months(year)
  Entry.find(year.to_s, :limit => 1000).map {|e| e.filename.to_s[0, 6] }.uniq.map {|e| link_to_month(e) }.reverse.join(' ')
end

def calender(sep = ' ')
 months.sort.reverse.map {|y, ms|
   "#{y}: #{ms.map {|m| link_to_month(pattern(y, m)) }.join(' ')}"
 }.join('<br />')
end

def link_name(pattern)
  pattern[/^(\d\d\d\d)(\d\d)/]
  "#{$1}年#{$2}月の日記"
end

def monthly_paginate_link
  a = months.map {|y, ms| ms.map {|m| pattern(y, m) } }.sort.flatten
  html = []
  if idx = a.index(params[:date])
    if idx > 0 and pre_pattern = a[idx - 1]
      html << link_to_month(pre_pattern) {|e| "&lt;#{link_name(pre_pattern)}" }
    end
    if next_pattern = a[idx + 1]
      html << link_to_month(next_pattern) {|e| "#{link_name(next_pattern)}&gt;" }
    end
  end
  html.join(' | ')
end

Plugin.add_hook(:before_entries) {
  if params[:calender] or action_name == :archives
    %Q!<div class="calender">#{ calender }</div>!
  else
    ''
  end
}

Plugin.add_hook(:before_entries) {
  monthly_paginate_link
}

Plugin.add_hook(:after_entries) {
  monthly_paginate_link
}
  
Plugin.add_hook(:before_archives) {|entry|
  "<h2>Calender</h2><p>#{ calender }</p>"
}
