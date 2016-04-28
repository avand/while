module ApplicationHelper

  def body_tag
    options = {}

    if @root.present? && @root.color.present?
      options[:style] = "background-color: #{@root.color}"
    end

    content_tag :body, options do
      yield
    end
  end

end
