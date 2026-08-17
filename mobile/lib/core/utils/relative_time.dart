String formatRelativeTime(String? isoString) {
  if (isoString == null || isoString.isEmpty) return '';

  final dateTime = DateTime.tryParse(isoString);
  if (dateTime == null) return isoString;

  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inSeconds < 60) return 'الآن';

  if (diff.inMinutes < 2) return 'منذ دقيقة';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقائق';

  if (diff.inHours < 2) return 'منذ ساعة';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعات';

  if (diff.inDays < 2) return 'منذ يوم';
  if (diff.inDays < 30) return 'منذ ${diff.inDays} أيام';

  if (diff.inDays < 60) return 'منذ شهر';
  return 'منذ ${(diff.inDays / 30).floor()} أشهر';
}