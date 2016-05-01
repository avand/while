module ApplicationHelper

  def body_tag
    options = {}

    if @root.present? && @root.color.present?
      color = Color::RGB.by_hex @root.color
      options[:style] = "background-color: ##{color.lighten_by(10).hex}"
    end

    content_tag :body, options do
      yield
    end
  end

end
