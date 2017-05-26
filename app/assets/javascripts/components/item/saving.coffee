While.Item.Saving =

  save: (event) ->
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
      beforeSend: -> item.addClass("pulse-while-pending")
      complete: (response) ->
        newItem = $(response.responseText)
        item.replaceWith(newItem)
        While.Item.Events.bind($(newItem))
        While.Items.toggleControlBar()

        if newItem.attr("id") == "item-new-template"
          $(".new-item-button").click()

  edit: (event) ->
    event.preventDefault()

    target = $(this)
    item = target.parents(".item")
    progressBar = item.find(".progress-bar")

    return if target.hasClass("item-control-active")

    itemName = item.find(".item-name").attr("contenteditable", true)

    itemName = itemName.data("original-value", itemName.text())[0]
    itemName.focus()
    setEndOfContenteditable(itemName)

    if !progressBar.hasClass("hide")
      progressBar.addClass("hide")
      item.data("show-progress-bar", true)

    target.addClass("item-control-active")
    item.find(".item-buttons").removeClass("hide")
    item.addClass("item-editing")

  cancel: (event) ->
    event.preventDefault()
    event.stopPropagation()

    item = $(this).parents(".item")

    if item.attr("id") == "item-new"
      item.remove()
    else
      While.Item.Saving.reset item

    While.Items.toggleNoItems()
    While.Items.toggleControlBar()

  reset: (item) ->
    itemName = item.find(".item-name").removeAttr("contenteditable")

    itemName.text(itemName.data("original-value"))

    if item.data("show-progress-bar")
      item.find(".progress-bar").removeClass("hide")
      item.removeData("show-progress-bar")

    item.find(".item-edit-control").removeClass("item-control-active")
    item.find(".item-buttons").addClass("hide")
    item.removeClass("item-editing")
