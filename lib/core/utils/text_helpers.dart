/// Helper utilities for string processing in Thovario.
class TextHelpers {
  TextHelpers._();

  /// Returns cleaned string, trimmed of excessive surrounding whitespace.
  static String clean(String text) {
    return text.trim();
  }

  /// Truncates content for list previews with ellipsis if needed.
  static String truncate(String text, {int maxLength = 120}) {
    final trimmed = text.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    // Try to cut at a word boundary within the last 15 characters
    final cutPoint = trimmed.lastIndexOf(' ', maxLength);
    if (cutPoint > (maxLength - 20) && cutPoint > 0) {
      return '${trimmed.substring(0, cutPoint)}...';
    }
    return '${trimmed.substring(0, maxLength)}...';
  }

  /// Calculates word count.
  static int wordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}
