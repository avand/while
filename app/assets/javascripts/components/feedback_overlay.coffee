document.addEventListener "turbolinks:load", ->

  modal = $(".feedback-overlay")

  modal.find(".cancel-button").click ->
    modal.addClass("hidden")

  $(".give-feedback-link").click (event) ->
    event.preventDefault()

    modal.removeClass("hidden")

    modal.find("textarea")[0].focus()
