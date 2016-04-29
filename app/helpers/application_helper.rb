module ApplicationHelper

  def body_tag
    options = {}

    options[:style] = "background-color: #{@color}"

    content_tag :body, options do
      yield
    end
  end

end
