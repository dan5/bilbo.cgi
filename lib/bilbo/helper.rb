BILBO_VERSION = '0.1.0'
require 'erb'
require 'cgi'

def escape(str) CGI.escape(str); end
def unescape(str) CGI.unescape(str); end
def h(str) CGI.escapeHTML(str.to_s); end
def chdir(key) Dir.chdir(config[:dir][key]) { yield }; end

def render_view(name, b = binding)
  erb = Plugin.views[name] || (chdir(:views) { File.read("#{name}.html.erb") })
  ERB.new(erb).result(b)
rescue
  "<h3>ViewError in #{h name}</h3>#{h $!}<pre>#{$@.join("\n")}</pre>"
end
    
def link_to(name, options = {})
  controller = options.delete(:controller)
  label = '#' + label if label = options.delete(:label)
  params = options.keys.map {|e| "#{e}=#{options[e]}"}.join('&').sub(/action=/, '')
  %Q!<a href="./#{controller}#{options.empty? ? '' : '?'}#{params}#{label}">#{name}</a>!
end

# for ruby 1.8
unless :a.respond_to?(:to_proc)
  class Symbol
    def to_proc
      Proc.new { |obj, *args| obj.send(self, *args) }
    end
  end
end
