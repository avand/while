document.addEventListener "turbolinks:load", ->

  $(".item")
    .click (event) ->
      Turbolinks.visit($(this).data("item-href"))
    .on "touchstart mousedown", ->
      $(this).addClass("item-active")
    .on "touchend mouseup", ->
      $(this).removeClass("item-active")
