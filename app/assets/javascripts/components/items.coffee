While.Items =
  checkForEmpty: ->
    noItems = $(".no-items")

    if $("main .item:visible:not(.item-drag)").length == 0
      noItems.removeClass "hide"
    else
      noItems.addClass "hide"

  add: (event) ->
    event.preventDefault()

    if $("#item-new").length == 0
      newItem = $("#item-new-template").clone(true).appendTo(".items")
      newItem.attr("id", "item-new").removeClass("hide")
      newItem.find(".item-edit-control").click()
      While.Items.checkForEmpty()
    else
      $("#item-new .item-name")[0].focus()

  Events:

    bind: ->
      $(".new-item-button").on("click", While.Items.add);
