// Web-only file download helper (this admin app targets Flutter web).
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// Triggers a browser download of [text] as a file named [filename].
void downloadText(String text, String filename, {String mime = 'text/csv'}) {
  final bytes = utf8.encode(text);
  final blob = html.Blob([bytes], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = filename
    ..click();
  html.Url.revokeObjectUrl(url);
}
