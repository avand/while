module ApplicationHelper

  def body_tag
    options = {}

    options[:class] = "#{controller_name.dasherize}-controller "
    options[:class] += "#{action_name.dasherize}-action"

    content_tag :body, options do
      yield
    end
  end

end
