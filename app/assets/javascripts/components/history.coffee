window.loadHistory = ->
  showHistory = (html) ->
    if html.length > 0
      $(".archived-items").removeClass("hide").find("script").replaceWith(html)

  $get(location.pathname.replace("items", "history"), showHistory)
