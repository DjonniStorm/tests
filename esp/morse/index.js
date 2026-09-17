var str = '.. / ..-. ..- -.-. -.- .. -. --. / .... .- - . / .--- .- ...- .- .-.-.-';

var index = 0;
var currskip = 0;

var interval = setInterval(function () {
  if (index >= str.length) {
    digitalWrite(2, 1);
    clearInterval(interval);
    return;
  }

  if (currskip > 0) {
    currskip--;
    return;
  }

  var c = str.charAt(index);
  index++;

  switch (c) {
    case '.':
      digitalWrite(2, 0);
      currskip = 1;
      break;

    case '-':
      digitalWrite(2, 0);
      currskip = 3;
      break;

    case ' ':
      digitalWrite(2, 1);
      currskip = 2;
      break;

    case '/':
      digitalWrite(2, 1);
      currskip = 6;
      break;
  }
}, 100);
