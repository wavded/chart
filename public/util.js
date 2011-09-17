(function(){
  var isLight = true, theme;
  var body = document.body;

  function toggleTheme(){
    body.className = isLight ? 'dark' : '';
    theme.innerHTML = isLight ? 'Use Normal Theme' : 'Use Low Light Theme'
    localStorage['theme'] = isLight ? 'dark' : 'light'
    isLight = !isLight;
    return false;
  }

  window.onload = function(){
    theme = document.getElementById('theme');
    if(localStorage['theme'] === 'dark') toggleTheme();
    theme.onclick = toggleTheme;
  }
}());
