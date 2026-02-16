import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DateiHandler {
  final Dio _dio = Dio();

  Future<void> dateiOeffnen({
    required String url,
    required String dateiname,
  }) async {
    if (kIsWeb) {
      await _imBrowserOeffnen(url);
      return;
    }

    final file = await _dateiHerunterladen(url, dateiname);
    await OpenFile.open(file.path);
  }

  Future<void> _imBrowserOeffnen(String url) async {
    final uri = Uri.parse(url);

    final ok = await launchUrl(
      uri,
      webOnlyWindowName: '_blank', // neuer Tab im Web
      mode: LaunchMode.platformDefault,
    );

    if (!ok) {
      throw Exception('URL konnte nicht geöffnet werden');
    }
  }

  Future<File> _dateiHerunterladen(String url, String dateiname) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$dateiname';

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

    return File(filePath);
  }
}
