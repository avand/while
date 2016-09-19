document.addEventListener "turbolinks:load", ->

  resetItem = (item, name) ->
    itemName = item.find(".item-name").removeAttr("contenteditable")

    if name
      itemName.text(name)
    else
      itemName.text(itemName.data("original-value"))

    if item.data("show-progress-bar")
      item.find(".progress-bar").removeClass("hide")
      item.removeData("show-progress-bar")

    item.find(".item-edit-control").removeClass("item-control-active")
    item.find(".item-buttons").addClass("hide")
    item.removeClass("item-editing")

  $(".item-edit-control").click (event) ->
    event.preventDefault()

    target = $(this)
    item = target.parents(".item")
    progressBar = item.find(".progress-bar")

    return if target.hasClass("item-control-active")

    itemName = item.find(".item-name").attr("contenteditable", true)

    itemName.on "mouseup", (event) -> event.stopPropagation()

    itemName = itemName.data("original-value", itemName.text())[0]
    itemName.focus()
    setEndOfContenteditable(itemName)

    if !progressBar.hasClass("hide")
      progressBar.addClass("hide")
      item.data("show-progress-bar", true)

    target.addClass("item-control-active")
    item.find(".item-buttons").removeClass("hide")
    item.addClass("item-editing")

  $(".item-edit-cancel-control").click (event) ->
    event.preventDefault()

    resetItem $(this).parents(".item")

  $(".edit_item").submit (event) ->
    event.preventDefault()

    form = $(this)
    item = form.parents(".item")
    itemName = form.find(".item-name")
    itemNameText = $.trim(itemName.text())
    hiddenItemNameField = form.find("input[name='item[name]']")

    hiddenItemNameField.val(itemNameText)

    $.ajax
      url: form.attr("action")
      data: form.serialize()
      method: form.attr("method")
      success: (newItem) ->
        resetItem(item, itemNameText)
      error: ->
        resetItem(item)
