document.addEventListener "turbolinks:load", ->

  dragDelay = 400
  dragDelayTimer = null

  startDrag = (item, pointerOffset) ->
    placeholder = $("<div>")
      .css "height", item.height()
      .addClass("item-placeholder")
      .insertAfter item

    itemOffset = item.offset()

    item
      .css
        top: "#{pointerOffset.top - pageYOffset}px"
        left: "#{pointerOffset.left - pageXOffset}px"
        width: item.css("width")
        marginTop: "#{-1 * (pointerOffset.top - itemOffset.top)}px"
        marginLeft: "#{-1 * (pointerOffset.left - itemOffset.left)}px"
        transformOrigin:
          "#{pointerOffset.top - itemOffset.top}px" +
          "#{pointerOffset.left - itemOffset.left}px"
      .addClass("item-drag")
      .find("a").on "click.drag-drop", (event) -> event.preventDefault()

  drag = (item, pointerOffset, event) ->
    startingPointerOffset = item.data("pointerClientOffset")

    return clearTimeout(dragDelayTimer) if !item.hasClass("item-drag") &&
      pointerStrayedFromStartingPoint(startingPointerOffset, pointerOffset)

    event.preventDefault()

    item.css pointerOffset

  finishDrag = (item) ->
    $(".item-placeholder").remove()

    item
      .css
        top: ""
        left: ""
        width: ""
        marginTop: ""
        marginLeft: ""
        transformOrigin: ""
      .removeData "pointerOffset"
      .removeClass("item-drag")

    setTimeout ( -> item.find("a").off "click.drag-drop" ), 10

  pointerStrayedFromStartingPoint = (startingPointerOffset, pointerOffset) ->
    tolerance = 3 # px
    startingPointerOffset &&
    (pointerOffset.top < startingPointerOffset.top - tolerance ||
     pointerOffset.top > startingPointerOffset.top + tolerance ||
     pointerOffset.left < startingPointerOffset.left - tolerance ||
     pointerOffset.left > startingPointerOffset.left + tolerance)

  delayDrag = (item, pointerOffset) ->
    item.data
      pointerPageOffset: pointerOffset
      pointerClientOffset:
        top: pointerOffset.top - pageYOffset
        left: pointerOffset.left - pageXOffset

    dragDelayTimer = setTimeout ( -> startDrag item, pointerOffset ), dragDelay

  $(".item").each ->
    item = $(this)

    item
      .on "touchstart", (event) ->
        touch = event.originalEvent.touches[0]
        delayDrag item, top: touch.pageY, left: touch.pageX
      .on "mousedown", (event) ->
        delayDrag item, top: event.pageY, left: event.pageX
      .on "mouseup", (event) ->
        clearTimeout(dragDelayTimer)
        finishDrag(item)
      .on "touchmove", (event) ->
        touch = event.originalEvent.touches[0]
        drag item, top: touch.clientY, left: touch.clientX, event
      .on "mousemove", (event) ->
        drag item, top: event.clientY, left: event.clientX, event
      .on "touchend", (event) ->
        finishDrag(item)
