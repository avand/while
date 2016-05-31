document.addEventListener "turbolinks:load", ->

  $(".item-checkbox").click (event) ->
    event.stopPropagation()

    $itemCheckbox = $(this)
    $item = $itemCheckbox.parents(".item")
    $itemCheckboxIcon = $itemCheckbox.find("i")
    $itemName = $item.find(".item-name")

    itemID = $item.data("item-id")
    data = { completed_at: null }

    data["completed_at"] = new Date() unless $item.data("item-completed-at")

    $.ajax
      url: "/items/#{itemID}/complete"
      data: data
      method: "PATCH"
      beforeSend: ->
        $itemCheckbox.addClass("pulse-while-pending")
      success: (item) ->
        $item.data("item-completed-at", item["completed_at"])

        $itemCheckboxIcon
          .removeClass("fa-check-square-o")
          .removeClass("fa-square-o")

        if item.completed_at
          $itemCheckboxIcon.addClass("fa-check-square-o")
          $itemName.addClass("strikethrough")
        else
          $itemCheckboxIcon.addClass("fa-square-o")
          $itemName.removeClass("strikethrough")

        $cleanupButton = $(".cleanup-button")
        if $(".item-checkbox .fa-check-square-o").length > 0
          $cleanupButton.removeClass "button-disabled"
        else
          $cleanupButton.addClass "button-disabled"
      complete: ->
        $itemCheckbox.removeClass("pulse-while-pending")
