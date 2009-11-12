#!/usr/bin/env ruby
require 'rbconfig'
require 'fileutils'
require 'pathname'

def foo(fname)
  if File.exist?(fname)
    print "\texists  ", Dir.pwd, '/'
    puts fname
  else
    print "\tcreate  ", Dir.pwd, '/'
    puts fname
    yield(fname)
  end
end

def cgi_root
  ARGV.first or 'cgi'
end

bilbo_root = (Pathname.new(__FILE__).expand_path).dirname
foo(cgi_root) {|dir| Dir.mkdir(cgi_root) }

Dir.chdir(cgi_root) {
  foo('index.cgi') {|fname|
    File.open(fname, 'w') {|f|
      f.puts "#!#{Config::CONFIG['bindir']}/ruby -Ku"
      f.puts "Encoding.default_external = 'UTF-8' if defined? Encoding"
      f.puts "$LOAD_PATH.unshift '#{bilbo_root}/lib'"
      f.puts "$LOAD_PATH.unshift '#{bilbo_root}'"
      f.puts "require 'index.rb'"
    }
    FileUtils.chmod(0755, 'index.cgi')
  }

  foo('bilborc') {|fname|
    rc = File.read(bilbo_root + 'bilborc.default')
    rc.gsub!('__BILBO_ROOT__', bilbo_root)
    File.open(fname, 'w') {|f| f.write(rc) }
  }

  foo('.htaccess') {|fname| FileUtils.cp(bilbo_root + 'dot.htaccess', fname) }
  foo('favicon.ico') {|fname| FileUtils.cp(bilbo_root + 'misc/favicon.ico', fname) }
  foo('stylesheets') {|dir| FileUtils.symlink(bilbo_root + dir, dir) }
  foo('config') {|dir| Dir.mkdir dir }
  foo('config/flavour.html.erb') {|fname| FileUtils.cp(bilbo_root + fname, fname) }
  foo('config/plugins') {|dir| Dir.mkdir dir }

  %w(flavour
     showdate
     archives
     bilborss
     namedpage
     category
     permalink
     comment
     calender 
     paginatelink
  ).each_with_index {|e, i|
    foo("config/plugins/%02d0_#{e}.rb" % (i)) {|src|
      FileUtils.symlink(bilbo_root + "plugins/#{e}.rb", src)
    }
  }
}
