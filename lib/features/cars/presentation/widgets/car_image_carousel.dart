import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  CarImageCarousel({
    super.key,
    required this.imageUrls,
    required this.height,
  });

  @override
  State<CarImageCarousel> createState() => _CarImageCarouselState();
}

class _CarImageCarouselState extends State<CarImageCarousel> {
  int _currentIndex = 0;

  List<String> get _images => widget.imageUrls
      .map(ImageUrlHelper.getUrl)
      .where((url) => url.trim().isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    final images = _images;
    if (images.isEmpty) return _emptyImage();

    return Stack(
      fit: StackFit.expand,
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () => _openGallery(images, index),
              child: _networkImage(images[index]),
            );
          },
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1,
            enableInfiniteScroll: images.length > 1,
            autoPlay: images.length > 1,
            autoPlayInterval: Duration(seconds: 4),
            autoPlayAnimationDuration: Duration(milliseconds: 750),
            autoPlayCurve: Curves.easeInOutCubic,
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              if (mounted) setState(() => _currentIndex = index);
            },
          ),
        ),
         Positioned.fill(child: _ImageGradient()),
        if (images.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 78.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final active = index == _currentIndex;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  width: active ? 22.w : 7.r,
                  height: 7.r,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    color: active ? AppColors.secondary : Colors.white54,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                );
              }),
            ),
          ),
        Positioned(
          right: 14.w,
          bottom: 70.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.photo_library_rounded,
                    color: Colors.white, size: 15.r),
                SizedBox(width: 5.w),
                Text(
                  '${_currentIndex + 1}/${images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _networkImage(String url) {
    return SizedBox.expand(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Color(0xFF171919),
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: AppColors.secondary,
              value: progress.expectedTotalBytes == null
                  ? null
                  : progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _emptyImage(),
      ),
    );
  }

  Widget _emptyImage() {
    return Container(
      height: widget.height,
      color: Color(0xFF171919),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car_rounded,
            size: 72.r,
            color: AppColors.secondary.withValues(alpha: 0.6),
          ),
          SizedBox(height: 10.h),
          Text('ui_162'.tr(),
            style: TextStyle(color: Colors.white38, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Future<void> _openGallery(List<String> images, int initialIndex) async {
    var selectedIndex = initialIndex;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, updateDialog) {
          return Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: CarouselSlider.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index, realIndex) {
                        return InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 5,
                          child: Center(
                            child: Image.network(
                              images[index],
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _emptyImage(),
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: MediaQuery.sizeOf(context).height,
                        viewportFraction: 1,
                        initialPage: initialIndex,
                        enableInfiniteScroll: images.length > 1,
                        onPageChanged: (index, reason) {
                          updateDialog(() => selectedIndex = index);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4.h,
                    left: 6.w,
                    child: IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 13.h,
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
                            '${selectedIndex + 1} / ${images.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 18.h,
                    child: Text('ui_245'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ImageGradient extends StatelessWidget {
  _ImageGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.18),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.86),
            ],
            stops: [0, 0.48, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
