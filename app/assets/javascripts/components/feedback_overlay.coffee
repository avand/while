document.addEventListener "turbolinks:load", ->

  modal = $(".feedback-overlay")

  modal.find(".cancel-button").click ->
    modal.addClass("hide")

  $(".give-feedback-link").click (event) ->
    event.preventDefault()

    modal.removeClass("hide")

    modal.find("textarea")[0].focus()
