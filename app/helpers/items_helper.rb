module ItemsHelper

  def progress_bar(item)
    total = item.descendants.not_deleted.count
    completed = item.descendants.completed.not_deleted.count
    percent_complete = ((completed / total.to_f) * 100).round rescue 0
    left = total - completed

    background_classes = ["progress-bar"]
    background_classes << "hidden" if total.zero?
    background_styles = ["width: #{progress_bar_width total}%;"]

    foreground_classes = ["progress-bar-status"]
    foreground_styles = ["width: #{percent_complete}%;"]

    label_classes = ["progress-bar-label"]
    label_classes << "hidden" if left.zero?

    if color = (item.color || item.root.color)
      color = Color::RGB.by_hex color
      background_styles << "background-color: ##{color.lighten_by(40).hex};"
      foreground_styles << "background-color: ##{color.darken_by(80).hex};"
    end

    content_tag :div, class: background_classes.join(" "),
                      style: background_styles.join(" ") do
      status = content_tag(:div, "", class: foreground_classes.join(" "),
                                     style: foreground_styles.join(" "))
      label = content_tag(:div, class: label_classes.join(" ")) do
        completed.zero? ? pluralize(left, "item") : "#{left} left"
      end

      status + label
    end
  end

  def progress_bar_width(number_of_items)
    return 0 if number_of_items.zero?
    (Math.log10(number_of_items + 0.5) * 40).round
  end

end
