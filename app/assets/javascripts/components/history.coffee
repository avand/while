class While.History
  load: (path) ->
    path = path.replace("items", "history")
    cacheKey = "html:" + path.replace(/\/$/, "")

    @container = $(".completed-items")
    @content = @container.find(".completed-items-content")
    @heading = @container.find(".completed-items-heading")

    @show(localStorage.getItem(cacheKey))

    $get path, (html) =>
      @show(html)
      localStorage.setItem(cacheKey, html)

    @heading.click =>
      @heading.find("i").toggleClass("hide")
      @content.toggleClass("hide")

  show: (html) ->
    return unless html && html.length > 0

    @container.removeClass("hide")
    @content.html(html)
