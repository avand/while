module ItemsHelper

  def progress_bar_width(number_of_items)
    return 0 if number_of_items.zero?
    (Math.log10(number_of_items) * 40).round
  end

end
