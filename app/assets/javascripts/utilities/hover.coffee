document.addEventListener "turbolinks:load", ->
  $("html").one "touchstart", (event) ->
    $(this).removeClass("hover-enabled")
