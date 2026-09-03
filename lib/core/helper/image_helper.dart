import '../constant/app_strings.dart';

class ImageUrlHelper {
  static String getUrl(String imagePath) {
    final path = imagePath.trim();
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.encodeFull(path);
    }

    final base = AppStrings.imageBaseUrl.endsWith('/')
        ? AppStrings.imageBaseUrl.substring(0, AppStrings.imageBaseUrl.length - 1)
        : AppStrings.imageBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.encodeFull('$base$normalizedPath');
  }
}
