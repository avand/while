class While.Item.DragDrop

  constructor: (event) ->
    @item = $(event.target).parents(".item")
    @coordinates = @getCoordinatesFromEvent event

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
        top: "#{@coordinates.top}px"
        left: "#{@coordinates.left}px"
        width: boundaries.width
        marginTop: "#{-1 * (@coordinates.top - boundaries.top)}px"
        marginLeft: "#{-1 * (@coordinates.left - boundaries.left)}px"
        transformOrigin:
          "#{@coordinates.left - boundaries.left}px " +
          "#{@coordinates.top - boundaries.top}px"
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

  getCurrentDropTarget: () ->
    for dropTarget in @dropTargets
      boundaries = dropTarget.data("boundaries")
      if @coordinates.top >= (boundaries.top - pageYOffset) &&
         @coordinates.left <= (boundaries.right - pageXOffset) &&
         @coordinates.top <= (boundaries.bottom - pageYOffset) &&
         @coordinates.left >= (boundaries.left - pageXOffset)
        return dropTarget

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

    @coordinates = @getCoordinatesFromEvent(event)

    @item.css @coordinates

    @findDropTargets()
    dropTarget = @getCurrentDropTarget()
    @activateDropTarget(dropTarget) if dropTarget

    @scroll()

  activateDropTarget: (el) ->
    $(".drop-target-active").removeClass "drop-target-active"

    if el.hasClass("item")
      @activateItemDropTarget(el)
    else if el.hasClass("ancestor")
      @activateAncestorDropTarget(el)
    else if el.hasClass("no-items")
      @activateNoItemsDropTarget(el)

  activateItemDropTarget: (item) ->
    boundaries = item.data "boundaries"
    tolerance = boundaries.height / 4

    if @coordinates.top >= (boundaries.top - pageYOffset) + tolerance &&
       @coordinates.top <= (boundaries.bottom - pageYOffset) - tolerance
      @item.addClass("item-drop")
      item.addClass("drop-target-active")
    else
      @item.removeClass("item-drop")

      if @coordinates.top > (boundaries.bottom - pageYOffset) - tolerance
        @placeholder.insertAfter(item)

      if @coordinates.top < (boundaries.top - pageYOffset) + tolerance
        @placeholder.insertBefore(item)

  activateAncestorDropTarget: (ancestor) ->
    if ancestor.hasClass("parent")
      @placeholder.prependTo(".items")
      $(".no-items").addClass("hide")
      @item.removeClass("item-drop")
    else
      @item.addClass("item-drop")
      @placeholder.appendTo(ancestor.find(".ancestor-content"))
      While.Items.checkForEmpty()

  activateNoItemsDropTarget: (noItems) ->
    @item.removeClass("item-drop")
    noItems.addClass("hide").after(@placeholder)

  finish: (event) ->
    @item.off ".drag-drop"
    $(document).off ".drag-drop"
    @enableTextSelection()

    dropTarget = @getCurrentDropTarget()

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
    orderedItemHashids = $(".item:visible").map ->
      $(this).data("hashid")

    $.ajax
      url: "/items/reorder"
      data: { hashids: orderedItemHashids.get().join() }
      method: "PATCH"
      beforeSend: -> item.addClass("pulse-while-pending")
      success: -> item.removeClass("pulse-while-pending")

  scroll: ->
    $window = $(window)
    windowHeight = $window.height()
    slowThreshold = 60
    fastThreshold = 30
    slowInterval = 6
    fastInterval = 1

    clearInterval(@scrollInterval)
    @scrollInterval = null

    scrollUp = () => $window.scrollTop($window.scrollTop() - 1)
    scrollUpFast = () => $window.scrollTop($window.scrollTop() - 2)
    scrollDown = () => $window.scrollTop($window.scrollTop() + 1)
    scrollDownFast = () => $window.scrollTop($window.scrollTop() + 2)

    if @coordinates.top < fastThreshold
      @scrollInterval = setInterval scrollUpFast, fastInterval
    else if @coordinates.top < slowThreshold
      @scrollInterval = setInterval scrollUp, slowInterval
    else if @coordinates.top > windowHeight - fastThreshold
      @scrollInterval = setInterval scrollDownFast, fastInterval
    else if @coordinates.top > windowHeight - slowThreshold
      @scrollInterval = setInterval scrollDown, slowInterval
