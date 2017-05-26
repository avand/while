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
          item.addClass("item-completing")
      success: (html) ->
        item.removeClass("pulse-while-pending")
        if !itemWasCompleted
          topOfItem = item.offset().top
          topOfCompletedItems = $(".completed-items").offset().top
          offset = Math.floor(topOfCompletedItems - topOfItem)

          transition item, {
            "transform": "translateY(#{offset}px)"
            "z-index": "9999"
            "opacity": "0"
          }, duration: 1000, (el) ->
            While.history.show(html)

            el.css("height", el.height() + 4)

            transition el, {
              "height": "0px"
              "padding": "0px"
              "margin": "0px"
              "border-width": "0px"
            }, duration: 200, (el) ->
              el.remove()
