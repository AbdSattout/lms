DateTime? parseApiDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value.toLocal();

  final text = value.toString().trim();
  if (text.isEmpty) return null;

  final hasTimeZone = RegExp(
    r'(z|[+-]\d{2}:?\d{2})$',
    caseSensitive: false,
  ).hasMatch(text);
  final hasTime = text.contains('T') || text.contains(' ');
  final normalizedText = hasTime && !hasTimeZone ? '${text}Z' : text;

  return DateTime.tryParse(normalizedText)?.toLocal();
}

String formatArabicRelativeTime(DateTime dateTime, {DateTime? now}) {
  final currentTime = (now ?? DateTime.now()).toLocal();
  final targetTime = dateTime.toLocal();
  final difference = currentTime.difference(targetTime);

  if (difference.inMinutes < 1) return 'الآن';
  if (difference.inHours < 1) {
    return 'منذ ${_arabicTimeUnit(difference.inMinutes, _minuteForms)}';
  }
  if (difference.inDays < 1) {
    return 'منذ ${_arabicTimeUnit(difference.inHours, _hourForms)}';
  }
  if (difference.inDays < 30) {
    return 'منذ ${_arabicTimeUnit(difference.inDays, _dayForms)}';
  }
  if (difference.inDays < 365) {
    return 'منذ ${_arabicTimeUnit(difference.inDays ~/ 30, _monthForms)}';
  }

  return 'منذ ${_arabicTimeUnit(difference.inDays ~/ 365, _yearForms)}';
}

String _arabicTimeUnit(int count, _ArabicTimeUnitForms forms) {
  if (count <= 0) return forms.single;
  if (count == 1) return forms.single;
  if (count == 2) return forms.dual;
  if (count >= 3 && count <= 10) return '$count ${forms.plural}';
  return '$count ${forms.single}';
}

class _ArabicTimeUnitForms {
  final String single;
  final String dual;
  final String plural;

  const _ArabicTimeUnitForms({
    required this.single,
    required this.dual,
    required this.plural,
  });
}

const _minuteForms = _ArabicTimeUnitForms(
  single: 'دقيقة',
  dual: 'دقيقتين',
  plural: 'دقائق',
);

const _hourForms = _ArabicTimeUnitForms(
  single: 'ساعة',
  dual: 'ساعتين',
  plural: 'ساعات',
);

const _dayForms = _ArabicTimeUnitForms(
  single: 'يوم',
  dual: 'يومين',
  plural: 'أيام',
);

const _monthForms = _ArabicTimeUnitForms(
  single: 'شهر',
  dual: 'شهرين',
  plural: 'أشهر',
);

const _yearForms = _ArabicTimeUnitForms(
  single: 'سنة',
  dual: 'سنتين',
  plural: 'سنوات',
);
