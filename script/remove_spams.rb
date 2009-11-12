#!/usr/bin/env ruby

class Comment
  def move_to_spams_dir
    if spam?
      save
      self.class.chdir() { @filename.delete }
    end
  end
end

class Controller
  def remove_spams
    Comment.find('20*', :limit => 2000).each do |e|
      if e.spam?
        print '  spam!!  '
        print e.filename, ' '
        puts e.name
        e.move_to_spams_dir
      end
    end
  end
end

if __FILE__ == $0
  Encoding.default_external = 'UTF-8' if defined? Encoding

  def params
    { :action => :remove_spams }
  end

  require 'pathname'
  bilbo_root = (Pathname.new(__FILE__).expand_path).dirname + '../'
  $LOAD_PATH.unshift bilbo_root, bilbo_root + 'lib'
  load ARGV.first # load bilborc
  setup_environment
  bilbo_context
end
