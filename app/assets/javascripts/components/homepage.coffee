document.addEventListener "turbolinks:load", ->

  if window.navigator.standalone
    $("a[href='/auth/google_oauth2']").each ->
      $(this).attr("target", "_blank")
