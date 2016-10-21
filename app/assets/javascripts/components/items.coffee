While.Items =
  checkForEmpty: ->
    if $("main .item:not(.item-drag)").length == 0
      $(".no-items").removeClass "hide"

  add: (event) ->
    event.preventDefault()

    if $("#item-new").length == 0
      newItem = $("#item-new-template").clone(true).appendTo(".items")
      newItem.attr("id", "item-new").removeClass("hide")
      newItem.find(".item-edit-control").click()
    else
      $("#item-new .item-name")[0].focus()

  Events:

    bind: ->
      $(".new-item-button").on("click", While.Items.add);
