#= require lib/jquery

$ ->
   isLight = true
   localStorage = window.localStorage or {}

   $('#theme').on 'click', ->
      isLight = !isLight
      if isLight
         $('body').removeClass 'dark'
         $('#theme').text 'Use Low Light Theme'
         localStorage['theme'] = 'light'
      else
         $('body').addClass 'dark'
         $('#theme').text 'Use Normal Theme'
         localStorage['theme'] = 'dark'
      false

   $('#keychange').on 'change', ->
      key = $(@).val().replace '#', 'sharp'
      document.location="/?title=#{title}&key=#{key}"

   $('#titlechange').on 'change', ->
      song = $(@).val()
      document.location = "/?title=#{song}"

   title = $('#title').text()
   if localStorage['theme'] is 'dark' then $('#theme').trigger 'click'
