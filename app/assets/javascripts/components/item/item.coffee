document.addEventListener "turbolinks:load", ->

  $(".item-drag-control")
    .on "mousedown", (event) ->
      event.preventDefault()

      dragDrop = new While.DragDrop(event)
      dragDrop.start()

  $(".item-content")
    .on "click", (event) ->
      item = $(this).parents(".item")
      if item.data("state") == "default"
        Turbolinks.visit(item.data("href"))
