import 'dart:convert';
import 'dart:io';

import 'package:car_app/core/models/suggested_vehicle_image.dart';
import 'package:http/http.dart' as http;

class VehicleImageRemoteDataSource {
  static const _commonsApi = 'https://commons.wikimedia.org/w/api.php';
  static const _maximumDownloadBytes = 12 * 1024 * 1024;

  const VehicleImageRemoteDataSource();

  Uri brandLogoUri(String brandName) => Uri.https(
        'carimagesapi.com',
        '/brand-logo',
        {'make': brandName.trim()},
      );

  Future<List<SuggestedVehicleImage>> searchCarImages({
    required String brand,
    required String model,
    required int year,
    int limit = 12,
  }) async {
    final exactQuery =
        '${brand.trim()} ${model.trim()} $year automobile filetype:bitmap';
    final exactResults = await _searchCommons(exactQuery, limit);
    if (exactResults.isNotEmpty) return exactResults;
    final fallbackQuery =
        '${brand.trim()} ${model.trim()} automobile filetype:bitmap';
    return _searchCommons(fallbackQuery, limit);
  }

  Future<List<SuggestedVehicleImage>> _searchCommons(
    String query,
    int limit,
  ) async {
    final uri = Uri.parse(_commonsApi).replace(queryParameters: {
      'action': 'query',
      'format': 'json',
      'formatversion': '2',
      'generator': 'search',
      'gsrsearch': query,
      'gsrnamespace': '6',
      'gsrlimit': '${limit.clamp(1, 20)}',
      'prop': 'imageinfo',
      'iiprop': 'url|mime|extmetadata',
      'iiurlwidth': '1200',
      'iiextmetadatafilter': 'LicenseShortName|Artist|Credit',
      'origin': '*',
    });
    final response = await http.get(
      uri,
      headers: const {'User-Agent': 'CarShowroomApp/1.0 image-search'},
    ).timeout(const Duration(seconds: 18));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Image search failed (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return const [];
    final queryData = decoded['query'];
    if (queryData is! Map<String, dynamic>) return const [];
    final rawPages = queryData['pages'];
    if (rawPages is! List) return const [];

    final pages = rawPages.whereType<Map>().toList()
      ..sort((a, b) => _asInt(a['index']).compareTo(_asInt(b['index'])));
    final results = <SuggestedVehicleImage>[];
    final seenUrls = <String>{};
    for (final rawPage in pages) {
      final page = Map<String, dynamic>.from(rawPage);
      final imageInfoList = page['imageinfo'];
      if (imageInfoList is! List || imageInfoList.isEmpty) continue;
      final rawInfo = imageInfoList.first;
      if (rawInfo is! Map) continue;
      final info = Map<String, dynamic>.from(rawInfo);
      final mime = (info['mime'] ?? '').toString().toLowerCase();
      if (!_isSupportedMime(mime)) continue;
      final originalUrl = (info['url'] ?? '').toString();
      final thumbnailUrl = (info['thumburl'] ?? originalUrl).toString();
      if (thumbnailUrl.isEmpty || !seenUrls.add(thumbnailUrl)) continue;
      final metadata = info['extmetadata'] is Map
          ? Map<String, dynamic>.from(info['extmetadata'] as Map)
          : const <String, dynamic>{};
      results.add(
        SuggestedVehicleImage(
          title: _cleanTitle((page['title'] ?? '').toString()),
          previewUrl: thumbnailUrl,
          downloadUrl: thumbnailUrl,
          sourcePageUrl: (info['descriptionurl'] ?? '').toString(),
          license: _metadataValue(metadata, 'LicenseShortName'),
          artist: _stripHtml(_metadataValue(metadata, 'Artist')),
        ),
      );
    }
    return results;
  }

  Future<File> downloadImage(
    Uri uri, {
    required String fileNamePrefix,
  }) async {
    final response = await http.get(
      uri,
      headers: const {'User-Agent': 'CarShowroomApp/1.0 image-download'},
    ).timeout(const Duration(seconds: 25));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Image download failed (${response.statusCode}).');
    }
    final contentType = response.headers['content-type']?.toLowerCase() ?? '';
    if (!contentType.startsWith('image/')) {
      throw const FormatException('The downloaded file is not an image.');
    }
    final declaredLength = int.tryParse(response.headers['content-length'] ?? '');
    if ((declaredLength != null && declaredLength > _maximumDownloadBytes) ||
        response.bodyBytes.length > _maximumDownloadBytes) {
      throw FileSystemException('The image is larger than 12 MB.');
    }
    if (response.bodyBytes.isEmpty) {
      throw const FormatException('The downloaded image is empty.');
    }

    final extension = _extensionFor(contentType, uri.path);
    final safePrefix = fileNamePrefix
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final file = File(
      '${Directory.systemTemp.path}/car_app_${safePrefix}_${DateTime.now().microsecondsSinceEpoch}.$extension',
    );
    return file.writeAsBytes(response.bodyBytes, flush: true);
  }

  static bool _isSupportedMime(String mime) =>
      mime == 'image/jpeg' || mime == 'image/png' || mime == 'image/webp';

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse('$value') ?? 999999;
  }

  static String _metadataValue(Map<String, dynamic> metadata, String key) {
    final item = metadata[key];
    if (item is Map) return (item['value'] ?? '').toString();
    return '';
  }

  static String _stripHtml(String value) => value
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .trim();

  static String _cleanTitle(String value) =>
      value.replaceFirst(RegExp(r'^File:', caseSensitive: false), '').trim();

  static String _extensionFor(String contentType, String path) {
    if (contentType.contains('png')) return 'png';
    if (contentType.contains('webp')) return 'webp';
    if (contentType.contains('jpeg') || contentType.contains('jpg')) return 'jpg';
    final extension = path.split('.').last.toLowerCase();
    return {'png', 'webp', 'jpg', 'jpeg'}.contains(extension) ? extension : 'jpg';
  }
}
