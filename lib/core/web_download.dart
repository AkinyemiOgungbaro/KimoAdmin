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

/// Triggers a browser download of [bytes] as a file named [filename].
void downloadBytes(List<int> bytes, String filename, {String mime = 'application/pdf'}) {
  final blob = html.Blob([bytes], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = filename
    ..click();
  html.Url.revokeObjectUrl(url);
}

/// Opens a URL in a new tab.
void openUrl(String url) {
  html.window.open(url, '_blank');
}
