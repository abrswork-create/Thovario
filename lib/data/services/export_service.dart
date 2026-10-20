import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/thought.dart';

/// Service responsible for exporting thoughts into readable Markdown format.
class ExportService {
  /// Converts a list of thoughts to a formatted Markdown string.
  static String formatAsMarkdown(List<Thought> thoughts) {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM d, yyyy h:mm a').format(now);

    buffer.writeln('# Thovario Journal Export');
    buffer.writeln('_Generated on $dateStr • ${thoughts.length} entries_\n');
    buffer.writeln('---\n');

    for (int i = 0; i < thoughts.length; i++) {
      final t = thoughts[i];
      final title = t.title.trim().isNotEmpty
          ? t.title.trim()
          : 'Untitled Thought';
      final created = DateFormat(
        'MMMM d, yyyy • h:mm a',
      ).format(t.createdAt.toLocal());
      final updated = DateFormat(
        'MMMM d, yyyy • h:mm a',
      ).format(t.updatedAt.toLocal());
      final favoriteMark = t.isFavorite ? ' ★ Favorite' : '';

      buffer.writeln('## $title');
      buffer.writeln('**Date:** $created$favoriteMark');
      if (t.updatedAt.isAfter(t.createdAt.add(const Duration(minutes: 1)))) {
        buffer.writeln('**Last modified:** $updated');
      }
      buffer.writeln();
      buffer.writeln(t.content);
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Exports thoughts to a local temporary Markdown file and invokes native iOS share sheet.
  /// Returns true if file was created and share sheet opened.
  Future<bool> exportThoughts(
    List<Thought> thoughts, {
    Rect? sharePositionOrigin,
  }) async {
    if (thoughts.isEmpty) {
      return false;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final dateStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${tempDir.path}/thovario_export_$dateStamp.md';
      final file = File(filePath);

      final markdown = formatAsMarkdown(thoughts);
      await file.writeAsString(markdown);

      final xFile = XFile(
        file.path,
        mimeType: 'text/markdown',
        name: 'thovario_export_$dateStamp.md',
      );
      await Share.shareXFiles(
        [xFile],
        text: 'Thovario Journal Export',
        subject: 'My Thovario Journal Export',
        sharePositionOrigin: sharePositionOrigin,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Shares a single thought via native iOS share sheet.
  Future<bool> shareSingleThought(
    Thought thought, {
    Rect? sharePositionOrigin,
  }) async {
    try {
      final buffer = StringBuffer();
      final title = thought.title.trim().isNotEmpty
          ? '${thought.title.trim()}\n\n'
          : '';
      buffer.write('$title${thought.content.trim()}');

      await Share.share(
        buffer.toString(),
        subject: thought.title.trim().isNotEmpty
            ? thought.title.trim()
            : 'A thought from Thovario',
        sharePositionOrigin: sharePositionOrigin,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
