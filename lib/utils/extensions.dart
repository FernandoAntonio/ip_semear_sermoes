extension FormatDuration on Duration {
  String formatDuration() {
    String hours = inHours.toString().padLeft(0, '2');
    String minutes = inMinutes.remainder(60).toString().padLeft(2, '');
    String seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${int.parse(hours) > 0 ? '$hours:' : ''}$minutes:$seconds";
  }
}
