#!/usr/bin/env ruby
require 'pathname'
bilbo_root = Pathname.new(__FILE__).expand_path.dirname + '..'
$LOAD_PATH.unshift bilbo_root + 'lib'
$LOAD_PATH.unshift bilbo_root

def params
  { :action => :rss }
end

Encoding.default_external = 'UTF-8' if defined? Encoding
bilborc = ARGV.first || raise
load bilborc
cgi_root = Pathname.new(bilborc).expand_path.dirname
setup_environment
fname = cgi_root + config[:rss][:uri].split('/').last
rss = bilbo_context()
File.open(fname, 'w') {|f| f.puts rss }
