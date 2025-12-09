// Wird nur in Flutter Web verwendet
import 'dart:html' as html;

void openPdf(String url) {
  html.window.open(url, "_blank");
}
