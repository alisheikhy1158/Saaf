/// "0:24" style countdown text (minutes:seconds). Negative values show 0:00.
String formatCountdown(int seconds) {
  final total = seconds < 0 ? 0 : seconds;
  final minutes = total ~/ 60;
  final rest = (total % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}
