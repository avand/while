document.addEventListener "turbolinks:load", ->

  $(".item-checkbox").click (event) ->
    event.stopPropagation()

    itemCheckbox = $(this)
    itemCheckboxIcon = itemCheckbox.find("i")

    return if itemCheckboxIcon.hasClass("fa-check-square-o")

    item = itemCheckbox.parents(".item")
    itemName = item.find(".item-name")

    $.ajax
      url: "/items/#{item.data("item-hashid")}/complete"
      data: { completed_at: new Date() }
      method: "PATCH"
      beforeSend: ->
        itemName.addClass("strikethrough")
        itemCheckboxIcon
          .removeClass("fa-square-o")
          .addClass("fa-check-square-o")

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
