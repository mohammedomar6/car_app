import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:car_app/features/transactions/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContractImageGallery extends StatelessWidget {
  final List<ContractImageModel> images;

  ContractImageGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 25.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.17),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: Colors.white24, size: 34.r),
            SizedBox(height: 8.h),
            Text('ui_159'.tr(),
              style: TextStyle(color: Colors.white38, fontSize: 10.sp),
            ),
          ],
        ),
      );
    }

    final urls = images
        .map((image) => ImageUrlHelper.getUrl(image.imageUrl))
        .where((url) => url.isNotEmpty)
        .toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.25,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGallery(context, urls, index),
          borderRadius: BorderRadius.circular(15.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: Image.network(
                  urls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ContractImageFallback(),
                ),
              ),
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.66),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in_rounded,
                          color: Colors.white, size: 15),
                      SizedBox(width: 4.w),
                      Text(
                        '${index + 1}/${urls.length}',
                        style: TextStyle(color: Colors.white, fontSize: 8.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openGallery(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) async {
    final controller = PageController(initialPage: initialIndex);
    var current = initialIndex;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) => Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: controller,
                  itemCount: urls.length,
                  onPageChanged: (index) =>
                      updateDialog(() => current = index),
                  itemBuilder: (context, index) => InteractiveViewer(
                    minScale: 0.7,
                    maxScale: 5,
                    child: Center(
                      child: Image.network(
                        urls[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return CircularProgressIndicator(
                            color: AppColors.secondary,
                          );
                        },
                        errorBuilder: (_, __, ___) =>
                            _ContractImageFallback(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: IconButton.filled(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: Icon(Icons.close_rounded),
                  ),
                ),
                Positioned(
                  top: 16.h,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Text(
                          '${current + 1} / ${urls.length}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20.h,
                  child: Text('ui_246'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();
  }
}

class _ContractImageFallback extends StatelessWidget {
  _ContractImageFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: Color(0xFF202222),
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white24,
          size: 36.r,
        ),
      );
}
