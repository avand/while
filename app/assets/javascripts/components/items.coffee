While.Items =
  toggleNoItems: ->
    visibleItems = $(".items .item:visible:not(.item-drag)").length > 0

    if $(".ancestor").length > 1
      if visibleItems
        $(".no-items-drop-target").addClass("hide")
      else
        $(".no-items-drop-target").removeClass("hide")
    else
      if visibleItems
        $(".no-items-bootstrap").addClass("hide")
      else
        $(".no-items-bootstrap").removeClass("hide")

  toggleControlBar: ->
    if $(".no-items-bootstrap:visible").length > 0 ||
       $(".item-editing").length > 0 ||
       $(".item-drag").length > 0
      $(".control-bar-container").addClass "hide"
    else
      $(".control-bar-container").removeClass "hide"

  add: (event) ->
    event.preventDefault()

    newItem = $("#item-new-template").clone(true).appendTo(".items")
    newItem.attr("id", "item-new").removeClass("hide")
    newItem.find(".item-edit-control").click()
    While.Items.toggleNoItems()
    While.Items.toggleControlBar()

  Events:

    bind: ->
      While.Items.toggleNoItems()
      $(".new-item-button").on("click", While.Items.add);
