document.addEventListener "turbolinks:load", ->

  controlBar = $(".control-bar")
  container = $(".control-bar-container")
  container.css "height", container.height()

  setInterval(( ->
    windowHeight = $(window).height()
    controlBarBottom = container[0].getBoundingClientRect().bottom

    if (controlBarBottom - windowHeight) > 0
      controlBar.addClass("control-bar-fixed")
    else
      controlBar.removeClass("control-bar-fixed")
  ), 100) if container[0]

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
