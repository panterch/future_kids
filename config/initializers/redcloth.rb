class String
  def textilize
    RedCloth.new(self).to_html.html_safe
  end
end

