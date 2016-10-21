While.Item.Deleting =

  delete: (event) ->
    confirmation = $(this).parents(".item").find(".item-delete-confirmation")
      .removeClass("hide")

    animate confirmation, "fade-in", duration: 100

  cancelDelete: (event) ->
    While.Item.Deleting.hide $(this).parents(".item")

  hide: (item, callback) ->
    $confirmation = item.find(".item-delete-confirmation")
    animate $confirmation, "fade-out", duration: 200, ->
      $confirmation.addClass("hide")
      callback() if callback

  confirmDelete: (event) ->
    item = $(this).parents(".item")

    $.ajax
      url: "/items/#{item.data("hashid")}"
      data: { deleted_at: (new Date()) }
      method: "DELETE"
      beforeSend: -> item.addClass("pulse-while-pending")
      success: ->
        While.Item.Deleting.hide item, ->
          animate item, "disappear", duration: 300, ->
            item.remove()
            While.Items.toggleNoItems()
            While.Items.toggleControlBar()
