class While.History
  load: () ->
    path = location.pathname.replace("items", "history")

    @container = $(".completed-items")
    @content = @container.find(".completed-items-content")
    @heading = @container.find(".completed-items-heading")

    $get path, (html) =>
      @show(html)

    @heading.click =>
      @heading.find("i").toggleClass("hide")
      @content.toggleClass("hide")

  show: (html) ->
    return unless html && html.length > 0

    @container.removeClass("hide")
    @content.html(html)
