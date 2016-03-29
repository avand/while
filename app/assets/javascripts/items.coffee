document.addEventListener "turbolinks:load", ->

  incrementClearedItemsCount = ->
    element = $(".cleared-items-count")
    currentCount = parseInt(element.text())
    remainingCount = element.data("clearable-items-count")
    animationDuration = 100

    animate element, "jump",
      duration: animationDuration,
      iterationCount: remainingCount

    interval = setInterval ( ->
      if remainingCount > 0
        element.text(++currentCount)
        remainingCount--
      else
        clearInterval(interval)

      element.data("clearable-items-count", remainingCount)
    ), animationDuration

  clearCompleted = ->
    item = $(".item-clearable:first")

    return if item.length is 0

    isCompleted = item.data("item-completed")
    descendantsCompletedCount = item.data("item-descendants-completed-count")

    if descendantsCompletedCount > 0
      progress = item.find(".item-progress")
      progressBar = item.find(".item-progress-bar")

      transitionDuration = descendantsCompletedCount * 20

      animationQueue.push [progress, { width: progress.data("cleared-width") }, {
        duration: transitionDuration, delay: transitionDuration }]

      animationQueue.push [progressBar, { width: "0%" }, {
        duration: transitionDuration }]

    if isCompleted
      item.css("height", item.height())

      animationQueue.push [item, "disappear", { duration: 300, delay: 75 },
        -> item.remove()]

    item.removeClass("item-clearable")
    clearCompleted()

  fadeOutControl = ->
    animate $(this), "fade-out"

  $(".clear-completed-control")
    .click (e) -> e.preventDefault()
    .click -> incrementClearedItemsCount()
    .click fadeOutControl
    .click ->
      clearCompleted()
      runAnimationQueue()
