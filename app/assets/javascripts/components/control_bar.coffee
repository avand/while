document.addEventListener "turbolinks:load", ->

  $(".cleanup-button").click (event) ->
    event.preventDefault()

    $cleanupButton = $(this)

    return if $cleanupButton.hasClass("button-disabled")

    $(".item").each ->
      $item = $(this)

      return unless $item.data("item-completed-at")

      animationQueue.push [
        $item,
        "disappear",
        { duration: 300, delay: 75 },
        -> $item.remove()
      ]

    $.ajax
      url: $cleanupButton.attr("href")
      method: "PATCH"
      beforeSend: -> $cleanupButton.addClass("pulse-while-pending")
      success: ->
        $cleanupButton.removeClass("pulse-while-pending")
        runAnimationQueue -> window.location.reload()
