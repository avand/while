window.loadHistory = ->
  path = location.pathname.replace("items", "history")
  cacheKey = "html:" + path.replace(/\/$/, '')

  showHistory = (html) ->
    if html && html.length > 0
      $(".archived-items").removeClass("hide").find("script").replaceWith(html)
      localStorage.setItem(cacheKey, html)

  showHistory(localStorage.getItem(cacheKey))

  $get(path, showHistory)
