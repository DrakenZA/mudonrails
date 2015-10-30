# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
typeIsArray = ( value ) ->
    value and
        typeof value is 'object' and
        value instanceof Array and
        typeof value.length is 'number' and
        typeof value.splice is 'function' and
        not ( value.propertyIsEnumerable 'length' )

#window.client = new Faye.Client('/faye')
window.client = new Faye.Client('https://drakenfaye.herokuapp.com/faye
')




jQuery ->
  client.subscribe userid, (payload) ->

    $('.panel-body').append("<ul>"+looper+"</ul>") for looper in payload.message
