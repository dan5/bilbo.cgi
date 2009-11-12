# -*- encoding: UTF-8 -*-
def flavour
  @flavour ||= File.read('config/flavour.html.erb').split(/^__CONTENT__.*$/)
end

Plugin.add_hook(:flavour_header) {
  Plugin.views[:flavour_header] = flavour.first
  render_view(:flavour_header)
}

Plugin.add_hook(:flavour_footer) {
  Plugin.views[:flavour_footer] = flavour.last
  render_view(:flavour_footer)
}
