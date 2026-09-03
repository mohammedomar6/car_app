import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDocumentViewer extends StatelessWidget {
  final List<String> documentUrls;

  OrderDocumentViewer({
    super.key,
    required this.documentUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ui_249'.tr(),
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10.sp,
            height: 1.5,
          ),
        ),
        SizedBox(height: 13.h),
        ...List.generate(documentUrls.length, (index) {
          final originalPath = documentUrls[index];
          final url = _resolvedUrl(originalPath);
          final isImage = _isImage(url);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == documentUrls.length - 1 ? 0 : 10.h,
            ),
            child: _DocumentTile(
              index: index + 1,
              fileName: _fileName(originalPath),
              url: url,
              isImage: isImage,
              onTap: () => isImage
                  ? _showImage(context, url, _fileName(originalPath))
                  : _openFile(context, url),
            ),
          );
        }),
      ],
    );
  }

  static String _resolvedUrl(String path) {
    return ImageUrlHelper.getUrl(path);
  }

  static bool _isImage(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp']
        .any(path.endsWith);
  }

  static String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final name = normalized.split('/').last;
    try {
      return Uri.decodeComponent(name);
    } catch (_) {
      return name;
    }
  }

  static Future<void> _openFile(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    var opened = false;
    try {
      if (uri != null && uri.hasScheme) {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('ui_158'.tr()),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  static Future<void> _showImage(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.94),
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: Icon(Icons.close_rounded, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'ui_168'.tr(),
                      onPressed: () => _openFile(dialogContext, url),
                      icon: Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.6,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return CircularProgressIndicator(
                          color: AppColors.secondary,
                          value: progress.expectedTotalBytes == null
                              ? null
                              : progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!,
                        );
                      },
                      errorBuilder: (_, __, ___) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white38,
                            size: 54,
                          ),
                          SizedBox(height: 12.h),
                          Text('ui_078'.tr(),
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.r),
                child: Text('ui_200'.tr(),
                  style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final int index;
  final String fileName;
  final String url;
  final bool isImage;
  final VoidCallback onTap;

  _DocumentTile({
    required this.index,
    required this.fileName,
    required this.url,
    required this.isImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(15.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.all(11.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: isImage
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        cacheWidth: 180,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_outlined,
                          color: AppColors.secondary,
                        ),
                      )
                    : Icon(
                        _fileIcon(fileName),
                        color: AppColors.secondary,
                        size: 25.r,
                      ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dyn_document'.tr(namedArgs: {'index': '$index'}),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white38, fontSize: 9.sp),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImage ? Icons.visibility_rounded : Icons.open_in_new_rounded,
                      color: AppColors.secondary,
                      size: 15.r,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      isImage ? 'extra_079'.tr() : 'extra_066'.tr(),
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _fileIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_rounded;
    }
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
      return Icons.table_chart_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }
}
