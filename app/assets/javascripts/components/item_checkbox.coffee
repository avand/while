document.addEventListener "turbolinks:load", ->

  $(".item-checkbox").click (event) ->
    itemCheckbox = $(this)
    item = itemCheckbox.parents(".item")
    itemID = item.data("item-id")
    itemCheckboxIcon = itemCheckbox.find("i")
    itemName = item.find(".item-name")

    $.ajax
      url: "/items/#{itemID}/complete"
      method: "PATCH"
      beforeSend: ->
        itemCheckbox.addClass("pulse-while-pending")
      success: (item) ->
        itemCheckboxIcon
          .removeClass("fa-check-square-o")
          .removeClass("fa-square-o")

        if item.completed
          itemCheckboxIcon.addClass("fa-check-square-o")
          itemName.addClass("strikethrough")
        else
          itemCheckboxIcon.addClass("fa-square-o")
          itemName.removeClass("strikethrough")
      complete: ->
        itemCheckbox.removeClass("pulse-while-pending")
