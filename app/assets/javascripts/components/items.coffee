While.Items =
  checkForEmpty: ->
    if $("main .item:not(.item-drag)").length == 0
      $(".no-items").removeClass "hide"
