While.Item.Completing =

  toggleComplete: (event) ->
    item = $(this).parents(".item")
    itemName = item.find(".item-name")
    itemWasCompleted = item.hasClass("item-completed")

    $.ajax
      url: "/items/#{item.data("hashid")}/complete"
      data: {
        completed_at: if itemWasCompleted then null else new Date()
      }
      method: "PATCH"
      beforeSend: ->
        item.addClass("pulse-while-pending")

        if !itemWasCompleted
          item.addClass("item-completed")
      success: (html) ->
        if !itemWasCompleted
          transition item, {
            transform: "translateY(100px)"
            opacity: 0
            zIndex: 9999
          }, duration: 700, (el) ->
            el.css("height", el.height() + 4)

            transition el, {
              "height": "0px"
              "padding": "0px"
              "margin": "0px"
              "border-width": "0px"
            }, duration: 200, (el) ->
              el.remove()
              While.history.show(html)
