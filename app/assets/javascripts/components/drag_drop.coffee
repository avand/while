document.addEventListener "turbolinks:load", ->

  dragDelay = 400
  dragDelayTimer = null
  dropTargets = []

  startDrag = (item, pointerOffset) ->
    calculateDropTargetBoundaries(item)

    placeholder = $("<div>")
      .css "height", item.height()
      .addClass("item-placeholder")
      .insertAfter item

    boundaries = item[0].getBoundingClientRect()

    item
      .css
        top: "#{pointerOffset.top}px"
        left: "#{pointerOffset.left}px"
        width: item.css("width")
        marginTop: "#{-1 * (pointerOffset.top - boundaries.top)}px"
        marginLeft: "#{-1 * (pointerOffset.left - boundaries.left)}px"
        transformOrigin:
          "#{pointerOffset.top - boundaries.top}px" +
          "#{pointerOffset.left - boundaries.left}px"
      .data "original-index", item.index()
      .addClass("item-drag")
      .find("a").on "click.drag-drop", (event) -> event.preventDefault()

  drag = (item, pointerOffset, event) ->
    startingPointerOffset = item.data("pointerOffset")

    return clearTimeout(dragDelayTimer) if !item.hasClass("item-drag") &&
      pointerStrayedFromStartingPoint(startingPointerOffset, pointerOffset)
    return unless item.hasClass("item-drag")

    event.preventDefault()

    item.css pointerOffset

    if dropTarget = getDropTargetAtPointer(pointerOffset)
      return unless dropTarget.hasClass("item")

      boundaries = dropTarget.data "boundaries"
      tolerance = boundaries.height / 4

      if pointerOffset.top >= (boundaries.top - pageYOffset) + tolerance &&
         pointerOffset.top <= (boundaries.bottom - pageYOffset) - tolerance
        item.addClass("item-drop")
        dropTarget.addClass("drop-target-active")
      else
        item.removeClass("item-drop")
        dropTarget.removeClass("drop-target-active")

        if pointerOffset.top > (boundaries.bottom - pageYOffset) - tolerance
          $(".item-placeholder").insertAfter(dropTarget)
          calculateDropTargetBoundaries(item)

        if pointerOffset.top < (boundaries.top - pageYOffset) + tolerance
          $(".item-placeholder").insertBefore(dropTarget)
          calculateDropTargetBoundaries(item)

  finishDrag = (item) ->
    return unless item.hasClass("item-drag")

    pointerOffset =
      top: parseFloat(item.css("top")),
      left: parseFloat(item.css("left"))

    placeholder = $(".item-placeholder")

    if dropTarget = getDropTargetAtPointer(pointerOffset)
      item.addClass("item-vanish")
      placeholder.addClass("item-placeholder-vanish").css "height", ""
      $(".drop-target-active").removeClass "drop-target-active"

      setTimeout ( ->
        item.remove()
        placeholder.remove()
      ), parseFloat(item.css("transition-duration")) * 1000

      submitMove(item, dropTarget)
    else
      item
        .css
          top: ""
          left: ""
          width: ""
          marginTop: ""
          marginLeft: ""
          transformOrigin: ""
        .removeClass("item-drag")

      placeholder.replaceWith(item)

      submitReorder(item) if item.data("original-index") != item.index()

    setTimeout ( -> item.find("a").off "click.drag-drop" ), 10

  pointerStrayedFromStartingPoint = (startingPointerOffset, pointerOffset) ->
    tolerance = 3 # px
    startingPointerOffset &&
    (pointerOffset.top < startingPointerOffset.top - tolerance ||
     pointerOffset.top > startingPointerOffset.top + tolerance ||
     pointerOffset.left < startingPointerOffset.left - tolerance ||
     pointerOffset.left > startingPointerOffset.left + tolerance)

  delayDrag = (item, pointerOffset) ->
    item.data "pointerOffset", top: pointerOffset.top, left: pointerOffset.left

    dragDelayTimer = setTimeout ( -> startDrag item, pointerOffset ), dragDelay

  calculateDropTargetBoundaries = (excludedItem) ->
    dropTargets = []

    $(".item").each ->
      item = $(this)

      if item.attr("id") != excludedItem.attr("id")
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

  submitReorder = (item) ->
    ordered_ids = $(".item").map ->
      $(this).data("item-id")

    $.ajax
      url: "/items/reorder"
      data: { ids: ordered_ids.get().join() }
      method: "PATCH"
      beforeSend: ->
        item.addClass("item-wait")
      success: ->
        item.removeClass("item-wait")

  submitMove = (item, newParentItem) ->
    $.ajax
      url: "/items/#{newParentItem.data("item-id")}/adopt"
      data: "child_id=#{item.data("item-id")}"
      method: "PATCH"
      beforeSend: ->
        newParentItem.addClass("item-wait")
      success: (data) ->
        newParentItem
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
        finishDrag(item)

      .on "touchmove.drag-drop", (event) ->
        touch = event.originalEvent.touches[0]
        drag item, top: touch.clientY, left: touch.clientX, event
      .on "mousemove.drag-drop", (event) ->
        drag item, top: event.clientY, left: event.clientX, event
