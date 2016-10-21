class While.DragDrop

  constructor: (event) ->
    @item = $(event.target).parents(".item")
    @startingPoint = @getCoordinatesFromEvent event

  start: () ->
    @findDropTargets()
    @disableTextSelection()

    @placeholder = $("<div>")
      .css "height", @item.height()
      .addClass("item-placeholder")
      .insertAfter @item

    boundaries = @item[0].getBoundingClientRect()

    @item
      .css
        top: "#{@startingPoint.top}px"
        left: "#{@startingPoint.left}px"
        width: boundaries.width
        marginTop: "#{-1 * (@startingPoint.top - boundaries.top)}px"
        marginLeft: "#{-1 * (@startingPoint.left - boundaries.left)}px"
        transformOrigin:
          "#{@startingPoint.left - boundaries.left}px " +
          "#{@startingPoint.top - boundaries.top}px"
      .data "original-index", @item.index()
      .addClass("item-drag")

    $(document)
      .on "mousemove.drag-drop touchmove.drag-drop", (event) => @drag(event)
      .on "mouseup.drag-drop touchend.drag-drop", (event) => @finish(event)

  findDropTargets: ->
    @dropTargets = []

    $(".item, .ancestor:not(:last-child), .no-items").each (i, el) =>
      el = $(el)

      if el.attr("id") != @item.attr("id")
        boundaries = el.offset()
        boundaries.width = parseFloat el.css "width"
        boundaries.height = parseFloat el.css "height"
        boundaries.right = boundaries.left + boundaries.width
        boundaries.bottom = boundaries.top + boundaries.height
        el.data "boundaries", boundaries
        @dropTargets.push el

    @dropTargets

  disableTextSelection: ->
    $("<style>")
      .attr("id", "transparent-selection-background-rules")
      .text("::selection { background-color: transparent !important; }
             ::-moz-selection { background-color: transparent !important; }")
      .appendTo("body")

  enableTextSelection: ->
    $("#transparent-selection-background-rules").remove()

  drag: (event) ->
    event.preventDefault()

    coordinates = @getCoordinatesFromEvent(event)
    dropTarget = @getDropTargetAtPointer(coordinates)

    @item.css coordinates
    @item.data "coordinates", coordinates

    return unless dropTarget

    boundaries = dropTarget.data "boundaries"

    $(".drop-target-active").removeClass "drop-target-active"

    if dropTarget.hasClass("item")
      tolerance = boundaries.height / 4

      if coordinates.top >= (boundaries.top - pageYOffset) + tolerance &&
         coordinates.top <= (boundaries.bottom - pageYOffset) - tolerance
        @item.addClass("item-drop")
        dropTarget.addClass("drop-target-active")
      else
        @item.removeClass("item-drop")

        if coordinates.top > (boundaries.bottom - pageYOffset) - tolerance
          @placeholder.insertAfter(dropTarget)

        if coordinates.top < (boundaries.top - pageYOffset) + tolerance
          @placeholder.insertBefore(dropTarget)

        @findDropTargets()
    else if dropTarget.hasClass("ancestor")
      if dropTarget.hasClass("parent")
        @placeholder.prependTo(".items")
        $(".no-items").addClass("hide")
        @item.removeClass("item-drop")
      else
        @item.addClass("item-drop")
        @placeholder.appendTo(dropTarget.find(".ancestor-content"))
        While.Items.checkForEmpty()

      @findDropTargets()
    else if dropTarget.hasClass("no-items")
      @item.removeClass("item-drop")
      dropTarget.addClass("hide").after(@placeholder)

  finish: (event) ->
    @item.off ".drag-drop"
    $(document).off ".drag-drop"
    @enableTextSelection()

    coordinates = @item.data("coordinates") || @startingPoint
    dropTarget = @getDropTargetAtPointer(coordinates)

    if dropTarget && (dropTarget.hasClass("item") || dropTarget.hasClass("ancestor"))
      setTimeout ( =>
        @item.remove()
        @placeholder.remove()
      ), parseFloat(@item.css("transition-duration")) * 1000

      @item.addClass("item-vanish")
      @placeholder.addClass("item-placeholder-vanish").css "height", ""
      $(".drop-target-active").removeClass "drop-target-active"
      @adoptItem(@item, dropTarget)
    else
      @item
        .css
          top: ""
          left: ""
          width: ""
          marginTop: ""
          marginLeft: ""
          transformOrigin: ""
        .removeClass("item-drag")

      @placeholder.replaceWith(@item)

      if @item.data("original-index") != @item.index()
        @reorderItem(@item)

  getCoordinatesFromEvent: (event) ->
    if event.type.match(/^touch/)
      touch = event.originalEvent.touches[0]
      top: touch.clientY, left: touch.clientX
    else
      top: event.clientY, left: event.clientX

  adoptItem: (child, parent) ->
    $.ajax
      url: "/items/#{parent.data("hashid")}/adopt"
      data: "child_hashid=#{child.data("hashid")}"
      method: "PATCH"
      beforeSend: -> parent.addClass("pulse-while-pending")
      success: (newProgressBar) ->
        newProgressBar = $(newProgressBar)
        newLabel = newProgressBar.find(".progress-bar-label")

        width = newProgressBar.css("width")
        statusWidth = newProgressBar.find(".progress-bar-status").css("width")
        labelHTML = newLabel.html()

        progressBar = parent.find(".progress-bar")
        status = progressBar.find(".progress-bar-status")
        label = progressBar.find(".progress-bar-label")

        parent.removeClass("pulse-while-pending")
        progressBar.removeClass("hide").css("width", width)
        status.css("width", statusWidth)
        label.html(labelHTML)

        if newLabel.hasClass("hide")
          label.addClass("hide")
        else
          label.removeClass("hide")

        While.Items.checkForEmpty()

  reorderItem: (item) ->
    orderedItemHashids = $(".item").map ->
      $(this).data("hashid")

    $.ajax
      url: "/items/reorder"
      data: { hashids: orderedItemHashids.get().join() }
      method: "PATCH"
      beforeSend: -> item.addClass("pulse-while-pending")
      success: -> item.removeClass("pulse-while-pending")

  getDropTargetAtPointer: (coordinates) ->
    for dropTarget in this.dropTargets
      boundaries = dropTarget.data("boundaries")
      if coordinates.top >= (boundaries.top - pageYOffset) &&
         coordinates.left <= (boundaries.right - pageXOffset) &&
         coordinates.top <= (boundaries.bottom - pageYOffset) &&
         coordinates.left >= (boundaries.left - pageXOffset)
        return dropTarget
