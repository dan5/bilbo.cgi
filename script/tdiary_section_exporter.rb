require 'rubygems'
require 'active_support'
require 'open-uri'
require 'kconv'

dir = 'tdiary_data'
address = 'http://dgames.jp/dan/'
time = 5.years.ago
Dir.mkdir(dir) unless File.exist?(dir)
while time <= Time.now
  date = sprintf("%4d%02d%02d",time.year, time.month, time.day)
  time = time.tomorrow

  html = []
  open("#{address}?date=#{date}") {|f|
    f.each_line {|line| html << line }
  }
  html = html.join('')
  html = Kconv.toutf8(html)
  unless  html =~ /class="message"/
    html.gsub!(/.*<div class="body">\s*/m, '')
    html.gsub!(/\s*<div class="comment">.*/m, '')
    html.gsub!(/<div class="section">/, '')
    html.gsub!(/<\/div>$/, '')
    html.gsub!(/\s*<!--.+?-->\s*/m, "\n")
    (3..7).each do |e|
      html.gsub!("<h#{e}>", "<h#{e - 1}>")
      html.gsub!("</h#{e}>", "</h#{e - 1}>")
    end
    html.sub!(/\A\n+/, "\n")

    # delete category link
    html.gsub!(/<a href=[^>]+category[^>]+>([^<]+)<\/a>/) { $1 }
    # delete sanchor
    html.gsub!(/<span class="sanchor">.*<\/span>/, '') 

    sufix = ''
    html.split(/\n<h2>/).each_with_index do |e, i|
      next if e.empty?
      e.sub!(/\A\n/, '')
      puts fname = "#{dir}/#{date}#{sufix}.html"
      File.open(fname, 'w') {|f| f.write '<h2>' + e }
      sufix = "_#{i}"
    end
  end
end
