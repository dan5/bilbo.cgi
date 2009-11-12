# -*- encoding: UTF-8 -*-
class Controller
  @@after_filters = []
  def self.after_filter(*args)
    @@after_filters += args
  end

  # trap: alias
  alias :_orig_render :render
  def render(action)
    @@after_filters.inject(_orig_render(action)) {|t, e| __send__("plugin_#{e}", t) }
  end

  #-- Sample --
  #after_filter :_sample_filter
  #def _sample_filter(html)
  #  NKF::nkf('-s', html)
  #end
end
