# -*- encoding: UTF-8 -*-
# rss_comments action ----------
class Controller
  def rss_comments
    generate_rss(Comment.find('20*').reverse[0, 20], :title => "Comments - #{config[:title]}")
  end
end

class Comment
  def rss_description(n = 128)
    body[0, n]
  end

  def rss_tile
    name
  end

  def rss_body
    h(body)
  end

  def time
    Time.parse(time_str)
  end
end

Plugin.add_hook(:header) {
  %Q!<link rel="alternate" type="application/rss+xml" title="RSS" href="?rss_comments">!
}
#----------

class Comment
  attr_reader :filename

  def initialize(filename, data = nil)
    filename[/\A\d{8}/] or raise(filename)
    filename[/[^\d\w_\.]/] and raise(filename)
    @filename = Pathname.new(filename)
    @data = data
  end

  def spam?
    return false unless data
    return true if data[/href|url=/i]
    return true if data[/\A[a-zA-Z0-9_\s\n\/;:\.,'"-]*\z/]
    false
  end

  def save
    self.class.chdir(spam? ? 'spams' : '') { @filename.open('w') {|f| f.write(@data) } }
  end

  def data
    @data ||= self.class.chdir { @filename.read }
  end

  def label
    @filename.to_s[/\A\d+_(.+)_c/]; $1
  end

  def body
    data.sub(/\A.*\n/, '')
  end

  def name
    data[/\A.*$/]
  end

  def time_str
    @filename.to_s[/\A(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d\d)/]
    "#{$1}/#{$2}/#{$3} #{$4}:#{$5}:#{$6}"
  end

  def to_html(idx = 1)
    num = 'c%02d' % idx
    html = <<HTML
      <span class="name">#{h name}</span>
      <span class="time"><a name="#{num}" href="./?date=#{label}&permalink##{num}">#{h time_str}</a></span>
      <p>#{h(body).gsub(/\n/, '<br />')}</p>
HTML
  end

  def self.find(pattern, options = {})
    pattern = pattern.to_s.gsub(/[^\d\w_*]/, '') # DON'T DELETE!!!
    # bug:
    limit = options[:limit] || 1000
    chdir { Dir.glob("*_#{pattern}_c*") }.sort.reverse[0, limit].map {|e| self.new(e) }.reverse
  rescue Errno::ENOENT
    []
  end

  def self.chdir(subdir = '')
    dir = Pathname.new(config[:dir][:entries]) + 'comments' + subdir
    dir.mkdir unless dir.exist?
    Dir.chdir(dir) { yield }
  end
end

class Controller
  def comment
    size = Comment.find(params[:date]).size
    time = Time.now.strftime('%Y%m%d%H%M%S')
    label = params[:date]
    fname = "#{time}_#{label}_c#{size}.txt"
    name = params[:name][/.{0,20}/]
    body = params[:body][/.{0,1000}/m].sub(/\s+\z/m, '')
    if name.size > 0 and body.size > 0
      Comment.new(fname, "#{name}\n#{body}").save
    end
    render_view(:comment_refresh)
  end
end

Plugin.add_hook(:after_entry) {|entry|
  if action_name == :permalink
    render_view(:comments, binding)
  elsif action_name == :list
    size = Comment.find(entry.label).size
    %Q!<span class="comments">#{ link_to "comments(#{size})", :action => :permalink, :date => entry.label, :label => 'c' }</span>!
  end
}

Plugin.views[:comments] = <<VIEW
<div class="comments">
   <h4><a name="c">Comments</a></h4>
   <% Comment.find(entry.label).each_with_index do |e, i| %>
     <%= e.to_html(i + 1) %>
   <% end %>
   <form class="comment" method="get" action="./"><div>
     <input type="hidden" name="date" value="<%=h entry.label %>">
     <input type="hidden" name="action" value="comment">
     <table>
       <tr class="name"><td>お名前</td><td><input class="field" name="name"></td></tr>
       <tr class="textarea"><td>コメント</td><td><textarea name="body" cols="60" rows="5"></textarea></td></tr>
       <tr class="button"><td></td><td><input type="submit" name="comment" value="投稿"></td></tr>
     </table>
   </div></form>
</div>
VIEW

Plugin.views[:comment_refresh] = <<VIEW
<html>
  <head><meta http-equiv="refresh" content="1;url=./?date=<%=h params[:date] %>&permalink#c">
        <title>moving...</title></head>
  <body><p>moving... Wait or <a href="./?date=<%=h params[:date] %>&permalink#c">Click here!</a></p></body>
</html>
VIEW
