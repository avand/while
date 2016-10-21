document.addEventListener "turbolinks:load", ->

  $(".item-content")
    .on "click", (event) ->
      item = $(this).parents(".item")
      if item.data("state") == "default"
        Turbolinks.visit(item.data("href"))
