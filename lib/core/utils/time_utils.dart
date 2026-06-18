/// Formats how long something has been pending in a compact, human-readable
/// form. Uses days for long waits, hours/minutes for medium waits, and
/// minutes/seconds for very recent items.
///
/// Examples:
///   - 3s, 45s
///   - 2m 30s
///   - 1h 15m
///   - 2d
String formatPendingDuration(DateTime createdAt) {
  final now = DateTime.now();
  final diff = now.difference(createdAt);
  final duration = diff.isNegative ? Duration.zero : diff;

  if (duration.inDays >= 1) {
    return '${duration.inDays}d';
  }
  if (duration.inHours >= 1) {
    final minutes = duration.inMinutes.remainder(60);
    return '${duration.inHours}h ${minutes}m';
  }
  if (duration.inMinutes >= 1) {
    final seconds = duration.inSeconds.remainder(60);
    return '${duration.inMinutes}m ${seconds}s';
  }
  return '${duration.inSeconds}s';
}
