#!/usr/bin/env ruby
require 'fileutils'

class Entry
  def category_title
    to_html[/<h2>.*?<\/h2>/i].to_s.gsub(/<[^>]*>/, '')
  end
end

class Controller
  def categoriz
    rootdir = Pathname.new('category')
    chdir(:entries) {
      FileUtils.remove_entry_secure(rootdir, true) if rootdir.exist?
      rootdir.mkdir
    }
    @entries = Entry.find('20', :limit => 99999)
    @entries.each do |entry|
      entry.category_title.scan(/\[([^\]]+)\]/).each do |e|
        next if config[:categories] and !config[:categories].index(e.first)
        dir = rootdir + escape(e.first)
        chdir(:entries) {
          dir.mkdir unless dir.exist?
          Dir.chdir(dir) {
            unless entry.filename.exist?
              FileUtils.symlink "../../#{entry.filename}", './'
              puts "      categoriz #{entry.filename} #{dir}"
            end
          }
        }
      end
    end
  end
end

if __FILE__ == $0
  Encoding.default_external = 'UTF-8' if defined? Encoding

  def params
    { :action => :categoriz }
  end

  require 'pathname'
  bilbo_root = (Pathname.new(__FILE__).expand_path).dirname + '../'
  $LOAD_PATH.unshift bilbo_root, bilbo_root + 'lib'
  load ARGV.first # load bilborc
  setup_environment
  bilbo_context
end
