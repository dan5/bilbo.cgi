require 'bilbo/helper'
require 'pathname'

class Entry
  attr_reader :filename
  def initialize(filename)
    @filename = Pathname.new(filename)
  end

  def label
    filename.basename('.*')
  end

  def body
    @body ||= chdir(:entries) { filename.read }
  end

  def to_html
    @@compilers[filename.extname].call(self) rescue h($!)
  end

  def self.find(pattern, options = {})
    pattern.gsub!(/[^\d\w_]/, '') # DON'T DELETE!!!
    pattern += '\.' if options[:complete_label]
    limit = options[:limit] || 10
    files = chdir(:entries) { Dir.glob("#{pattern}*") }.sort.reverse
    (files[limit * (options[:page] || 0), limit] || []).map {|e| Entry.new(e) }
  end

  @@compilers = Hash.new(lambda {|entry| entry.body })
  def self.add_compiler(extname, &block)
    @@compilers[extname] = block
  end
end

class Controller
  def list
    @entries = Entry.find(params[:date] || '20',
                          :limit => (params[:limit] || config[:limit] || 5).to_i,
                          :page => (params[:page] || 0).to_i)
    render(:list)
  end

  def render(action)
    render_view(:layout) { render_view(action) }
  end
end

class Plugin
  def self.load
    Dir.glob("#{config[:dir][:plugins]}/*.rb").sort.each {|e| Kernel.load e }
  end

  @@hook_procs = {}
  def self.add_hook(key, priority = 128, &block) # todo: priority
    @@hook_procs[key] ||= []
    @@hook_procs[key] << block
  end

  def self.render_hook(key, *args)
    (@@hook_procs[key] || []).map {|e| e.call(*args) }.join("\n")
  end

  def self.views
    @@views ||= {}
  end
end

def default_action
  :list
end

def action_name # support: ruby 1.8 and 1.9
  # todo: Hash#index
  action = (params[:action] || params.index(nil) || 'list').to_sym
  Controller.instance_methods(false).map(&:to_sym).include?(action) ? action : default_action
end

def bilbo_context
  Plugin.load
  Controller.new.__send__(action_name)
end
