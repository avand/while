module ItemsHelper

  def progress_bar(item)
    total = item.new_record? ? 0 : item.descendants.not_deleted.count
    completed = item.new_record? ? 0 : item.descendants.completed.not_deleted.count
    percent_complete = ((completed / total.to_f) * 100).round rescue 0

    background_classes = ["progress-bar"]
    background_classes << "hide" if total.zero?
    background_styles = ["width: #{progress_bar_width total}%;"]

    foreground_classes = ["progress-bar-status"]
    foreground_styles = ["width: #{percent_complete}%;"]

    if color = (item.color || item.root.color)
      color = Color::RGB.by_hex color
      background_styles << "background-color: ##{color.lighten_by(20).hex};"
      foreground_styles << "background-color: ##{color.hex};"
    end

    content_tag :div, class: background_classes.join(" "),
                      style: background_styles.join(" ") do
      content_tag(:div, "", {
        class: foreground_classes.join(" "),
        style: foreground_styles.join(" ")
      })
    end
  end

  def progress_bar_width(number_of_items)
    return 0 if number_of_items.zero?
    (Math.log10(number_of_items + 0.5) * 40).round
  end

end
