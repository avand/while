While.Item.Events =
  bind: (container) ->
    container ||= $(".items")

    container.find(".item-checkbox:not(.disabled)").click \
      While.Item.Completing.toggleComplete

    container.find(".item-delete-control:not(.disabled)").click \
      While.Item.Deleting.delete

    container.find(".item-delete-cancel-control").click \
      While.Item.Deleting.cancelDelete

    container.find(".item-delete-confirm-control").click \
      While.Item.Deleting.confirmDelete

    container.find(".item-drag-control:not(.disabled)")
      .on "mousedown touchstart", (event) ->
        event.preventDefault()

        dragDrop = new While.Item.DragDrop(event)
        dragDrop.start()

    container.find(".item-content")
      .on "click", (event) ->
        item = $(this).parents(".item")

        if !item.hasClass("item-editing")
          Turbolinks.visit(item.data("href"))

    container.find(".item-form").on "submit", While.Item.Saving.save
    container.find(".item-edit-control").click While.Item.Saving.edit
    container.find(".item-edit-cancel-control").click While.Item.Saving.cancel

    container.find(".item-form").on "keypress", (event) ->
      While.Item.Saving.save.call(this, event) if event.which == 13
