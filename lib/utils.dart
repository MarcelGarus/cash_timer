String stringifyDuration(Duration duration, {bool short = false}) {
  var text = '';
  var hours = duration.inHours;
  var minutes = duration.inMinutes;
  if (hours > 0) {
    text = '$hours ${short ? 'h' : hours == 1 ? 'hour' : 'hours'} ';
  }
  text += '$minutes ${short ? 'min' : minutes == 1 ? 'minute' : 'minutes'}';
  return text;
}
