While.Item.Completing =

  toggleComplete: (event) ->
    itemCheckbox = $(this)
    itemCheckboxIcon = itemCheckbox.find("i")

    return if itemCheckboxIcon.hasClass("fa-check-circle")

    item = itemCheckbox.parents(".item")
    itemName = item.find(".item-name")

    $.ajax
      url: "/items/#{item.data("hashid")}/complete"
      data: { completed_at: new Date() }
      method: "PATCH"
      beforeSend: ->
        itemName.addClass("strikethrough")
        itemCheckboxIcon
          .removeClass("fa-circle-thin")
          .addClass("fa-check-circle")

        setTimeout ( ->
          transition item, {
            transform: "translateY(100px)"
            opacity: 0
            zIndex: 9999
          }, duration: 500, (el) ->
            el.css("height", el.height() + 4)

            transition el, {
              "height": "0px"
              "padding": "0px"
              "margin": "0px"
              "border-width": "0px"
            }, duration: 200, (el) -> el.remove()
        ), 150
      success: (html) ->
        While.history.show(html)
