# -*- encoding: UTF-8 -*-
class Controller
  def myaction
    render(:myaction)
  end
end

Plugin.add_hook(:before_entries) {
    "Hello, World!"
}

Plugin.views[:myaction] = <<VIEW
<div class="archives">
<h2>MyAction</h2>
<p>hello...</p>
<p>ただいまの時間は「<%=h Time.now %>」です。</p>
</div>
VIEW
