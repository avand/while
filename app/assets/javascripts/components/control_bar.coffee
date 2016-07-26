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
