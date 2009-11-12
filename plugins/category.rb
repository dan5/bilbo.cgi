# -*- encoding: UTF-8 -*-

# trap
alias :_orig_chdir :chdir
def chdir(key)
  if key == :entries && category = params[:category]
    begin
      return _orig_chdir(key) { Dir.chdir("category/#{escape(category)}") { yield } }
    rescue Errno::ENOENT
    end
  end
  _orig_chdir(key) { yield }
end

def categories
  _orig_chdir(:entries) { File.exist?("category") ? Dir.chdir("category") { Dir.glob('*') } : []  }
end

def category_size(category)
  _orig_chdir(:entries) { Dir.glob("category/#{category}/*").size } 
end

def link_to_category(category)
  opt = { :category=> category }
  s = "#{unescape(category)}(#{category_size(category)})"
  params[:category] == unescape(category) ? s : link_to(s, opt)
end

def link_to_categories(sep = '')
  categories.map {|e| link_to_category(e) }.join(sep)
end

class Entry
  def categories
    super.select{|e| _orig_chdir(:entries) { File.exist?("category/#{e}/#{filename}") } }
  end

  unless action_name == :categoriz
    # trap
    alias :_orig_to_html :to_html
    def to_html
      _orig_to_html.gsub(/<h2>(<[^>]*>\s*)*\[.+?<\/h2>/m) { $&.gsub(/\[.+?\]/, '') }
    end
  end
end

if params[:category]
  Plugin.add_hook(:before_header) {
    "<head><title>#{config[:title]}: Categories: #{params[:category]}</title></head>"
  }
end

Plugin.add_hook(:after_entry) {|entry|
  a = entry.categories
  a.empty? ? '' : %Q!<div class="category">category: #{ a.map {|e| link_to_category(e) }.join(' ') }</div>!
}

Plugin.add_hook(:before_entries) {|entry|
  a = categories.map {|e| link_to_category(e) }.join(' ')
  params[:category] ? %Q!<div class="categories"><p>#{ a }</p></div>! : ''
}

Plugin.add_hook(:before_archives) {|entry|
<<HTML
  <h2>Categories</h2>
  <p>#{ link_to_categories(' ') }</p>
HTML
}
