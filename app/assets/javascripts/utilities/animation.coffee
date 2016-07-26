# Push an animation onto this array to build a sequence of animations. Push an
# array of params: the element you want to affect, the name of the animation or
# properties you want to animate, any animation-specific properties, and a
# callback to run after the animations complete.
#
# Examples:
#
#   animationQueue.push [$el, "fade-out", { duration: 100 }, -> $el.remove()]
#
#   animationQueue.push [$el, { width: "50%" }]
#
window.animationQueue = []

# Sequentially (and recursively) process the animation queue. This function will
# delegate to `transition` and `animate` depending on the contents of the
# animation queue.
window.runAnimationQueue = (queueCallback) ->
  nextAnimation = window.animationQueue.shift()

  if !nextAnimation
    queueCallback() if queueCallback
    return

  element = nextAnimation[0]
  callback = nextAnimation[3]

  if typeof nextAnimation[1] is "string"
    animationName = nextAnimation[1]
    animationOptions = nextAnimation[2]

    animate element, animationName, animationOptions, (element) ->
      callback(element) if callback
      runAnimationQueue(queueCallback)
  else
    properties = nextAnimation[1]
    transitionOptions = nextAnimation[2]

    transition element, properties, transitionOptions, (element) ->
      callback(element) if callback
      runAnimationQueue(queueCallback)

# Controlling animations solely with class names is hard. But jQuery's
# animations don't take advantage of CSS animations. This method and
# `transition` attempt to find a middle ground. Use `animate` to apply
# animation properties to an element and then perform a callback when the
# animation is finished.
window.animate = (element, animationName, options, callback) ->
  options ||= {}
  options.delay ||= 0
  options.duration ||= 100
  options.fillMode ||= "forwards"

  properties =
    "animation-delay": "#{options.delay}ms"
    "animation-direction": options.direction
    "animation-duration": "#{options.duration}ms"
    "animation-fill-mode": options.fillMode
    "animation-name": animationName
    "animation-iteration-count": options.iterationCount
    "animation-timing-function": options.timingFunction
    "animation-play-state": options.playState

  element.css properties

  setTimeout ( -> callback(element) if callback ), options.duration

# Like `animate`, `transition` allows you to drive an animation with JS. The
# difference with this function is that you can still control many of the
# transition properties in a CSS rule.
window.transition = (element, properties, options, callback) ->
  options ||= {}
  options.delay ||= Math.round(parseFloat(element.css("transition-delay")) * 1000)
  options.duration ||= Math.round(parseFloat(element.css("transition-duration")) * 1000)

  transitionProperties = { "transition-property": Object.keys(properties).join(", ") }
  transitionProperties["transition-timing-function"] = options.timingFunction
  transitionProperties["transition-delay"] = "#{options.delay}ms"
  transitionProperties["transition-duration"] = "#{options.duration}ms"

  element.css transitionProperties
  element.css properties

  setTimeout ( ->
    Object.keys(transitionProperties).forEach (key) -> transitionProperties[key] = ""
    element.css transitionProperties

    callback(element) if callback
  ), options.duration
