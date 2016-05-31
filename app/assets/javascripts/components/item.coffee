document.addEventListener "turbolinks:load", ->

  $(".item").click (event) ->
    Turbolinks.visit($(this).data("item-href"))
