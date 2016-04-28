document.addEventListener "turbolinks:load", ->

  $(".item-checkbox").click (event) ->
    $itemCheckbox = $(this)
    $item = $itemCheckbox.parents(".item")
    $itemCheckboxIcon = $itemCheckbox.find("i")
    $itemName = $item.find(".item-name")

    itemID = $item.data("item-id")
    data = { completed_at: null }

    data["completed_at"] = new Date() unless $item.data("item-completed")

    $.ajax
      url: "/items/#{itemID}/complete"
      data: data
      method: "PATCH"
      beforeSend: ->
        $itemCheckbox.addClass("pulse-while-pending")
      success: (item) ->
        $itemCheckboxIcon
          .removeClass("fa-check-square-o")
          .removeClass("fa-square-o")

        if item.completed_at
          $itemCheckboxIcon.addClass("fa-check-square-o")
          $itemName.addClass("strikethrough")
          $item.data("item-completed", true)
        else
          $itemCheckboxIcon.addClass("fa-square-o")
          $itemName.removeClass("strikethrough")
          $item.data("item-completed", false)
      complete: ->
        $itemCheckbox.removeClass("pulse-while-pending")
