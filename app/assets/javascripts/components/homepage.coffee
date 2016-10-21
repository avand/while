document.addEventListener "turbolinks:load", ->

  prompt = $(".install-prompt")
  overlay = $(".install-overlay")

  $(".install-control").click (event) ->
    event.preventDefault()

    prompt.toggleClass("hide");
    overlay.toggleClass("hide");

    setTimeout ( () ->
      prompt.toggleClass("collapsed");
      overlay.toggleClass("transparent");
    ), 5

  $(".install-prompt-close-control").click (event) ->
    event.preventDefault()

    prompt.toggleClass("collapsed");
    overlay.toggleClass("transparent");

    setTimeout ( () ->
      prompt.toggleClass("hide");
      overlay.toggleClass("hide");
    ), parseFloat(prompt.css("transition-duration")) * 1000

  if window.navigator.standalone
    $(".splash").addClass("hide")
    $(".splash-standalone").removeClass("hide")
