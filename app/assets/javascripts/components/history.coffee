class While.History
  load: (path) ->
    @path = path.replace("items", "history")
    @cacheKey = "html:" + @path.replace(/\/$/, "")

    @show(localStorage.getItem(@cacheKey))

    $get @path, (html) =>
      @show(html)
      localStorage.setItem(@cacheKey, html)

  show: (html) ->
    return unless html && html.length > 0

    $(".completed-items").removeClass("hide")
    $(".completed-items-content").html(html)
