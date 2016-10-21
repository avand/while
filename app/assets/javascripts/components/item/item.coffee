document.addEventListener "turbolinks:load", ->

  $(".item-drag-control")
    .on "mousedown touchstart", (event) ->
      event.preventDefault()

      dragDrop = new While.DragDrop(event)
      dragDrop.start()

  $(".item-content")
    .on "click", (event) ->
      item = $(this).parents(".item")

      if !item.hasClass("item-editing")
        Turbolinks.visit(item.data("href"))
