module ApplicationHelper

  def body_tag
    options = {}

    # if @root.present? && @root.color.present?
    #   color = Color::RGB.by_hex @root.color
    #   options[:style] = "background-color: ##{color.hex}"
    # end

    options[:class] = "#{controller_name.dasherize}-controller "
    options[:class] += "#{action_name.dasherize}-action"

    content_tag :body, options do
      yield
    end
  end

end
