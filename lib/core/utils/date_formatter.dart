import 'package:intl/intl.dart';

/// Clean, localized date formatting utilities for Thovario.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullFormat = DateFormat('MMMM d, yyyy');
  static final DateFormat _fullWithTimeFormat = DateFormat(
    'MMMM d, yyyy • h:mm a',
  );
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _timeOnly = DateFormat('h:mm a');

  /// Formats date for thought detail view (e.g. October 19, 2026 • 2:30 PM).
  static String formatDetail(DateTime dateTime) {
    return _fullWithTimeFormat.format(dateTime.toLocal());
  }

  /// Formats date for list cards with gentle relative or calendar labels.
  static String formatCard(DateTime dateTime) {
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(local.year, local.month, local.day);
    final differenceDays = today.difference(target).inDays;

    if (differenceDays == 0) {
      return 'Today • ${_timeOnly.format(local)}';
    } else if (differenceDays == 1) {
      return 'Yesterday • ${_timeOnly.format(local)}';
    } else if (differenceDays < 7 && differenceDays > 0) {
      final dayName = DateFormat('EEEE').format(local);
      return '$dayName • ${_timeOnly.format(local)}';
    } else {
      return _shortDate.format(local);
    }
  }

  /// Formats date for simple header displays (e.g. October 19, 2026).
  static String formatHeader(DateTime dateTime) {
    return _fullFormat.format(dateTime.toLocal());
  }
}
