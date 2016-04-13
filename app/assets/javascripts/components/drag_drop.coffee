document.addEventListener "turbolinks:load", ->

  dragItem = null
  dragDelay = 400
  dropTargets = []
  dragDelayTimer = null
  startingPointOffset = null

  startDrag = (item, pointerOffset) ->
    dragItem = item

    calculateDropTargetBoundaries(dragItem)

    placeholder = $("<div>")
      .css "height", dragItem.height()
      .addClass("item-placeholder")
      .insertAfter dragItem

    boundaries = dragItem[0].getBoundingClientRect()

    dragItem
      .css
        top: "#{pointerOffset.top}px"
        left: "#{pointerOffset.left}px"
        width: item.css("width")
        marginTop: "#{-1 * (pointerOffset.top - boundaries.top)}px"
        marginLeft: "#{-1 * (pointerOffset.left - boundaries.left)}px"
        transformOrigin:
          "#{pointerOffset.top - boundaries.top}px" +
          "#{pointerOffset.left - boundaries.left}px"
      .data "original-index", dragItem.index()
      .addClass("item-drag")
      .find("a").on "click.drag-drop", (event) -> event.preventDefault()

  drag = (pointerOffset, event) ->
    if !dragItem
      if pointerStrayedFromStartingPoint(pointerOffset)
        clearTimeout(dragDelayTimer)
        dragItem = null
      return

    event.preventDefault()

    dragItem.css pointerOffset

    if dropTarget = getDropTargetAtPointer(pointerOffset)
      return unless dropTarget.hasClass("item")

      boundaries = dropTarget.data "boundaries"
      tolerance = boundaries.height / 4

      $(".drop-target-active").removeClass "drop-target-active"

      if pointerOffset.top >= (boundaries.top - pageYOffset) + tolerance &&
         pointerOffset.top <= (boundaries.bottom - pageYOffset) - tolerance
        dragItem.addClass("item-drop")
        dropTarget.addClass("drop-target-active")
      else
        dragItem.removeClass("item-drop")

        if pointerOffset.top > (boundaries.bottom - pageYOffset) - tolerance
          $(".item-placeholder").insertAfter(dropTarget)
          calculateDropTargetBoundaries(dragItem)

        if pointerOffset.top < (boundaries.top - pageYOffset) + tolerance
          $(".item-placeholder").insertBefore(dropTarget)
          calculateDropTargetBoundaries(dragItem)

  finishDrag = ->
    return unless dragItem
    return unless dragItem.hasClass("item-drag")

    pointerOffset =
      top: parseFloat(dragItem.css("top")),
      left: parseFloat(dragItem.css("left"))

    placeholder = $(".item-placeholder")

    if dropTarget = getDropTargetAtPointer(pointerOffset)
      dragItem.addClass("item-vanish")
      placeholder.addClass("item-placeholder-vanish").css "height", ""
      $(".drop-target-active").removeClass "drop-target-active"

      setTimeout ( ->
        dragItem.remove()
        placeholder.remove()
        dragItem.find("a").off "click.drag-drop"
        dragItem = null
      ), parseFloat(dragItem.css("transition-duration")) * 1000

      adoptItem(dragItem, dropTarget)
    else
      dragItem
        .css
          top: ""
          left: ""
          width: ""
          marginTop: ""
          marginLeft: ""
          transformOrigin: ""
        .removeClass("item-drag")

      placeholder.replaceWith(dragItem)

      if dragItem.data("original-index") != dragItem.index()
        reorderItem(dragItem)

      setTimeout ( ->
        dragItem.find("a").off "click.drag-drop"
        dragItem = null
      ), 5

  pointerStrayedFromStartingPoint = (pointerOffset) ->
    tolerance = 3 # px

    startingPointOffset &&
    (pointerOffset.top < startingPointOffset.top - tolerance ||
     pointerOffset.top > startingPointOffset.top + tolerance ||
     pointerOffset.left < startingPointOffset.left - tolerance ||
     pointerOffset.left > startingPointOffset.left + tolerance)

  delayDrag = (item, pointerOffset) ->
    startingPointOffset = pointerOffset
    dragDelayTimer = setTimeout ( -> startDrag item, pointerOffset ), dragDelay

  calculateDropTargetBoundaries = ->
    dropTargets = []

    $(".item").each ->
      item = $(this)

      if item.attr("id") != dragItem.attr("id")
        boundaries = item.offset()
        boundaries.width = parseFloat item.css "width"
        boundaries.height = parseFloat item.css "height"
        boundaries.right = boundaries.left + boundaries.width
        boundaries.bottom = boundaries.top + boundaries.height
        item.data "boundaries", boundaries
        dropTargets.push item

  getDropTargetAtPointer = (pointerOffset) ->
    for dropTarget in dropTargets
      boundaries = dropTarget.data("boundaries")
      if pointerOffset.top >= (boundaries.top - pageYOffset) &&
         pointerOffset.left <= (boundaries.right - pageXOffset) &&
         pointerOffset.top <= (boundaries.bottom - pageYOffset) &&
         pointerOffset.left >= (boundaries.left - pageXOffset)
        return dropTarget

  reorderItem = (item) ->
    orderedItemIDs = $(".item").map ->
      $(this).data("item-id")

    $.ajax
      url: "/items/reorder"
      data: { ids: orderedItemIDs.get().join() }
      method: "PATCH"
      beforeSend: -> item.addClass("item-wait")
      success: -> item.removeClass("item-wait")

  adoptItem = (child, parent) ->
    $.ajax
      url: "/items/#{parent.data("item-id")}/adopt"
      data: "child_id=#{child.data("item-id")}"
      method: "PATCH"
      beforeSend: -> parent.addClass("item-wait")
      success: (data) ->
        parent
          .removeClass("item-wait")
          .find(".item-progress")
            .removeClass("hidden")
            .css("width", "#{data["progress_width"]}%")
            .find(".item-progress-bar")
              .css("width", "#{data["progress_bar_width"]}%")

  $(".item").each ->
    item = $(this)

    item
      .on "touchstart.drag-drop", (event) ->
        touch = event.originalEvent.touches[0]
        delayDrag item, top: touch.clientY, left: touch.clientX
      .on "mousedown.drag-drop", (event) ->
        delayDrag item, top: event.clientY, left: event.clientX

      .on "touchend.drag-drop mouseup.drag-drop", (event) ->
        clearTimeout(dragDelayTimer)
        finishDrag()

  $(document)
    .on "touchmove.drag-drop", (event) ->
      touch = event.originalEvent.touches[0]
      drag top: touch.clientY, left: touch.clientX, event
    .on "mousemove.drag-drop", (event) ->
      drag top: event.clientY, left: event.clientX, event
