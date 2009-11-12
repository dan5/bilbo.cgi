require 'cgi'

# todo: セットアップ時、ここに index.cgi の内容が埋め込まれるような incex.cgi.erb にすべき

def context
  load './bilborc'
  setup_environment
  bilbo_context()
rescue Exception
  "<h2>#{$!.class}</h2>\n#{CGI.escapeHTML($!.message)}\n<pre>#{CGI.escapeHTML($@.join("\n\t"))}</pre>"
end

def params
  @params ||= CGI.new.params.keys.inject({}) {|t, k| t[k.to_sym] = CGI.new.params[k][0]; t }
end

CGI.new.out{ context() }
