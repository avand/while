document.addEventListener "turbolinks:load", ->

  $(".item-color").click ->
    $(".item-color").removeClass("item-color-selected")
    $(event.target).addClass("item-color-selected")
