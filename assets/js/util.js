require(['jquery'], function ($) {
   $(function () {
      var isLight = true
      var localStorage = window.localStorage || {}

      $('#theme').on('click', function () {
         isLight = !isLight
         if (isLight) {
            $('body').removeClass('dark')
            $('#theme').text('Use Low Light Theme')
            localStorage['theme'] = 'light'
         }
         else {
            $('body').addClass('dark')
            $('#theme').text('Use Normal Theme')
            localStorage['theme'] = 'dark'
         }
      })

      $('#keychange').on('change', function () {
         key = $(this).val().replace('#', 'sharp')
         document.location = "/?title="+title+"&key="+key
      })

      $('#titlechange').on('change', function () {
         song = $(this).val()
         document.location = "/?title="+song
      })

      title = $('#title').text()

      if (localStorage['theme'] == 'dark')
         $('#theme').trigger('click')
   })
})
