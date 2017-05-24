class While.History

  load: () ->
    path = location.pathname.replace("items", "history")

    @container = $(".completed-items")

    $get path, (html) => @show(html)

  show: (html) ->
    return unless html && html.length > 0

    @container.html(html)
    While.Item.Events.bind(@container)
