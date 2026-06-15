import 'dart:html' as html;
import 'dart:typed_data';

void triggerWebDownload(String filename, Uint8List bytes,
    [String mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']) {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrl(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
