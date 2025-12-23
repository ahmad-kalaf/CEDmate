import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DateiHandler {
  final Dio _dio = Dio();

  Future<void> dateiOeffnen({
    required String url,
    required String dateiname,
  }) async {
    if (kIsWeb) {
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..target = '_blank'
        ..rel = 'noopener noreferrer'
        ..style.display = 'none';

      web.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
    }
    try {
      final file = await _dateiHerunterladen(url, dateiname);
      print('Dateipfad: ${file.path}');
      await OpenFile.open(file.path);
    } catch (e) {
      throw Exception('Datei konnte nicht geöffnet werden: $e');
    }
  }

  Future<File> _dateiHerunterladen(String url, String dateiname) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$dateiname';
    final file = File(filePath);

    final response = await _dio.download(
      url,
      filePath,
      options: Options(
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Download fehlgeschlagen (${response.statusCode})');
    }

    return file;
  }
}
