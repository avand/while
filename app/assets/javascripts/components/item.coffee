document.addEventListener "turbolinks:load", ->

  $(".item")
    .on "touchstart mousedown", ->
      $(this).addClass("item-active")
    .on "touchend mouseup", ->
      $(this).removeClass("item-active")
