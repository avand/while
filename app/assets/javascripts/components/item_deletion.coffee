document.addEventListener "turbolinks:load", ->

  cancelDelete = (item, callback) ->
    $confirmation = item.find(".item-delete-confirmation")
    animate $confirmation, "fade-out", duration: 200, ->
      $confirmation.addClass("hidden")
      callback() if callback

  $(".item-delete-control").click (event) ->
    $el = $(this).parents(".item").find(".item-delete-confirmation")
      .removeClass("hidden")
    animate $el, "fade-in", duration: 100

  $(".item-delete-cancel-control").click (event) ->
    cancelDelete $(this).parents(".item")

  $(".item-delete-confirm-control").click (event) ->
    $item = $(this).parents(".item")

    $.ajax
      url: "/items/#{$item.data("item-id")}"
      data: { deleted_at: (new Date()) }
      method: "DELETE"
      success: ->
        cancelDelete $item, ->
          animate $item, "disappear", duration: 300, ->
            $item.remove()
            checkForEmptyList()
