document.addEventListener "turbolinks:load", ->

  window.drake = dragula [$(".items")[0]]

  createStyleToHideShadow = ->
    $("<style>").appendTo("body").attr(id: "hide-shadow").text(
      ".items > .gu-transit { padding: 0; margin: 0; }")

  removeStyleToHideShadow = ->
    $("#hide-shadow").remove()

  # Hides the shadow lines before and after the item placeholder.
  toggleShadow = ->
    $shadow = $(".gu-transit")

    if $shadow.next().hasClass("item-placeholder") ||
       $shadow.prev().hasClass("item-placeholder")
      createStyleToHideShadow()
    else
      removeStyleToHideShadow()

  insertPlaceholder = ($el) ->
    $placeholder = $("<div>").addClass("item-placeholder")
    $placeholder.css "height", $el.height()
    $el.after $placeholder

  addItemContainers = ($skipEl) ->
    $(".item").each ->
      return if $skipEl.attr("id") is this.id
      drake.containers.push this.querySelector(".item-name")

  drake.on "drag", (el, source) ->
    $el = $(el)

    insertPlaceholder($el)
    $el.addClass("shadow-line")
    createStyleToHideShadow()
    addItemContainers($el)

  drake.on "dragend", (el) ->
    $(".item-placeholder").remove()
    $(".shadow-line").removeClass("shadow-line")
    removeStyleToHideShadow()

  drake.on "shadow", (shadow, container, source) ->
    toggleShadow()

  drake.on "over", (shadow, container, source) ->
    $(container).parents(".item").addClass("shadow-outline")

  drake.on "out", (el, container, source) ->
    $(container).parents(".item").removeClass("shadow-outline")
