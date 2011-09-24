(function(){
  var isLight = true, theme, keychange, title, titlechange;
  var body = document.body;

  function toggleTheme(){
    body.className = isLight ? 'dark' : '';
    theme.innerHTML = isLight ? 'Use Normal Theme' : 'Use Low Light Theme'
    localStorage['theme'] = isLight ? 'dark' : 'light'
    isLight = !isLight;
    return false;
  }

  function changeKey(){
    var key = keychange.options[keychange.selectedIndex].value;
    document.location="/?title=" + title + "&key=" + key.replace('#','sharp');
  }

  function changeSong(){
    var song = titlechange.options[titlechange.selectedIndex].value;
    document.location="/?title=" + song;
  }

  window.onload = function(){
    theme = document.getElementById('theme');
    keychange = document.getElementById('keychange');
    titlechange = document.getElementById('titlechange');
    title = document.getElementById('title').innerHTML;
    if(localStorage['theme'] === 'dark') toggleTheme();

    theme.onclick = toggleTheme;
    keychange.onchange = changeKey;
    titlechange.onchange = changeSong;
  }
}());
