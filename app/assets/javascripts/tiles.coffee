# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#typeIsArray = ( value ) ->
#    value and
#        typeof value is 'object' and
#        value instanceof Array and
#        typeof value.length is 'number' and
#        typeof value.splice is 'function' and
#        not ( value.propertyIsEnumerable 'length' )

#window.client = new Faye.Client('/faye')

$ ->
  $('.panel-body').slimScroll
    height: '500px'
    start: 'bottom'


jQuery ->
  PrivatePub.subscribe userid, (data, channel) ->
    $('.panel-body').append(looper) for looper in data.chat
    $('.panel-body').slimScroll
      scrollTo: $('.panel-body').prop('scrollHeight')+10 + 'px'
