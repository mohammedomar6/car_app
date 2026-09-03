import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/data/vehicle_image_remote_data_source.dart';
import 'package:car_app/features/auth/presentation/widgets/elevated_button_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:car_app/features/brand/data/models/brand_request_model.dart';
import 'package:car_app/features/brand/data/models/edit_request_model.dart';
import 'package:car_app/features/brand/presentation/manager/brands_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/helper/image_helper.dart';

class BrandDialog extends StatefulWidget {
  final int? brandId;
  final String? brandName;
  final String? brandImage;

  BrandDialog({
    super.key,
    this.brandId,
    this.brandName,
    this.brandImage,
  });

  bool get isEdit => brandId != null;

  @override
  State<BrandDialog> createState() => _BrandDialogState();
}

class _BrandDialogState extends State<BrandDialog> {
  final TextEditingController _brandController =
  TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final VehicleImageRemoteDataSource _imageRemoteDataSource =
      const VehicleImageRemoteDataSource();

  File? _image;
  Timer? _logoDebounce;
  String? _suggestedLogoUrl;
  bool? _logoAvailable;
  bool _downloadingLogo = false;
  bool _imageFromSuggestion = false;
  String? _suggestedLogoForName;

  @override
  void initState() {
    super.initState();

    _brandController.text = widget.brandName ?? '';
    _brandController.addListener(_scheduleLogoSuggestion);
    _scheduleLogoSuggestion();
  }

  @override
  void dispose() {
    _logoDebounce?.cancel();
    _brandController.removeListener(_scheduleLogoSuggestion);
    _brandController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _imageFromSuggestion = false;
      _suggestedLogoForName = null;
    });
  }

  void _scheduleLogoSuggestion() {
    _logoDebounce?.cancel();
    final name = _brandController.text.trim();
    if (_imageFromSuggestion && _suggestedLogoForName != name) {
      setState(() {
        _image = null;
        _imageFromSuggestion = false;
        _suggestedLogoForName = null;
      });
    }
    if (name.length < 2) {
      if (mounted && (_suggestedLogoUrl != null || _logoAvailable != null)) {
        setState(() {
          _suggestedLogoUrl = null;
          _logoAvailable = null;
        });
      }
      return;
    }
    _logoDebounce = Timer(const Duration(milliseconds: 650), () {
      if (!mounted || _brandController.text.trim() != name) return;
      setState(() {
        _suggestedLogoUrl =
            _imageRemoteDataSource.brandLogoUri(name).toString();
        _logoAvailable = null;
      });
    });
  }

  void _setLogoAvailability(bool available) {
    if (!mounted || _logoAvailable == available) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _logoAvailable != available) {
        setState(() => _logoAvailable = available);
      }
    });
  }

  Future<bool> _useSuggestedLogo({bool showError = true}) async {
    if (_downloadingLogo) return false;
    final name = _brandController.text.trim();
    if (name.length < 2 || _logoAvailable == false) return false;
    final uri = _suggestedLogoUrl == null
        ? _imageRemoteDataSource.brandLogoUri(name)
        : Uri.parse(_suggestedLogoUrl!);
    setState(() => _downloadingLogo = true);
    try {
      final downloaded = await _imageRemoteDataSource.downloadImage(
        uri,
        fileNamePrefix: '${name}_logo',
      );
      if (!mounted || _brandController.text.trim() != name) return false;
      setState(() {
        _image = downloaded;
        _imageFromSuggestion = true;
        _suggestedLogoForName = name;
      });
      return true;
    } catch (_) {
      if (showError && mounted) _showMessage('app_image_download_failed'.tr());
      return false;
    } finally {
      if (mounted) setState(() => _downloadingLogo = false);
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (_downloadingLogo) return;
    final name = _brandController.text.trim();

    if (name.isEmpty) {
      _showMessage('ui_202'.tr());
      return;
    }

    // ==========================================================
    // EDIT
    // ==========================================================

    if (widget.isEdit) {
      final request = BrandRequestModel(
        brandName: name,
        imageFile: _image,
      );

      context.read<BrandsBloc>().add(
        EditBrandEvent(
          brandId: widget.brandId!,
          brandModel: request,
        ),
      );

      return;
    }

    // ==========================================================
    // ADD
    // ==========================================================

    if (_image == null) {
      final downloaded = await _useSuggestedLogo(showError: false);
      if (!downloaded) {
        _showMessage('ui_203'.tr());
        return;
      }
    }

    final request = BrandRequestModel(
      brandName: name,
      imageFile: _image!,
    );

    context.read<BrandsBloc>().add(
      AddBrandEvent(
        brandModel: request,
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // STATE LISTENER
  // ============================================================

  void _handleState(
      BuildContext context,
      BrandsState state,
      ) {
    if (state is AddBrandSuccess) {
      Navigator.pop(context);

      _showMessage(
        state.addBrandModel.message ??
            'extra_016'.tr(),
      );

      return;
    }

    if (state is AddBrandError) {
      _showMessage(state.massage);
      return;
    }

    if (state is EditBrandSuccess) {
      Navigator.pop(context);

      _showMessage(
        state.editBrandModel.message ??
            'extra_017'.tr(),
      );

      return;
    }

    if (state is EditBrandError) {
      _showMessage(state.massage);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: BlocListener<BrandsBloc, BrandsState>(
        listener: _handleState,
        child: AlertDialog(


          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: _buildTitle(),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildNameField(),

                SizedBox(height: 12.h),

                _buildSmartLogoSuggestion(),

                SizedBox(height: 15.h),

                _buildImagePicker(),

                SizedBox(height: 25.h),

                _buildSubmitButton(),

                SizedBox(height: 12.h),

                _buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(
          widget.isEdit
              ? Icons.edit_outlined
              : Icons.add_business_outlined,
          size: 25.r,
        ),
        SizedBox(width: 10.w),
        Text(
          widget.isEdit
              ? 'ui_108'.tr()
              : 'extra_004'.tr(),
        ),
      ],
    );
  }

  // ============================================================
  // BRAND NAME
  // ============================================================

  Widget _buildNameField() {
    return TextFieldWidget(
      label: 'ui_049'.tr(),
      type: TextInputType.text,
      hint: 'extra_013'.tr(),
      icon: Icons.car_crash,
      isPassword: false,
      controller: _brandController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'extra_041'.tr();
        }

        return null;
      },
      color: AppColors.darkGrey,
    );
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Widget _buildImagePicker() {
    return DottedBorder(
      options: RectDottedBorderOptions(
        color: AppColors.textAuth,
        dashPattern: [3, 6],
      ),
      child: InkWell(
        onTap: _pickImage,
        child: _image != null
            ? _buildSelectedImage()
            : widget.isEdit &&
            widget.brandImage != null &&
            widget.brandImage!.isNotEmpty
            ? _buildOldImage()
            : _buildEmptyImage(),
      ),
    );
  }

  Widget _buildSmartLogoSuggestion() {
    final url = _suggestedLogoUrl;
    if (url == null) return const SizedBox.shrink();
    return Container(
      width: 250.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: AppColors.secondary, size: 18.r),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  'app_smart_logo'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            height: 105.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: _logoAvailable == false
                ? Text(
                    'app_logo_not_found'.tr(),
                    style: const TextStyle(color: Colors.black54),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    frameBuilder: (context, child, frame, syncLoaded) {
                      if (frame != null || syncLoaded) _setLogoAvailability(true);
                      return child;
                    },
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const CircularProgressIndicator(),
                    errorBuilder: (_, __, ___) {
                      _setLogoAvailability(false);
                      return Text(
                        'app_logo_not_found'.tr(),
                        style: const TextStyle(color: Colors.black54),
                      );
                    },
                  ),
          ),
          SizedBox(height: 9.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logoAvailable == false || _downloadingLogo
                  ? null
                  : _useSuggestedLogo,
              icon: _downloadingLogo
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_done_rounded),
              label: Text(
                _downloadingLogo
                    ? 'app_downloading_image'.tr()
                    : 'app_use_suggested_logo'.tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY IMAGE
  // ============================================================

  Widget _buildEmptyImage() {
    return Container(
      width: 250.w,
      height: 150.h,
      color: AppColors.darkGrey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.textAuth,
            size: 40.r,
          ),
          Text('ui_281'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayLarge,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OLD IMAGE
  // ============================================================

  Widget _buildOldImage() {
    return Container(
      width: 250.w,
      height: 180.h,
      color: AppColors.darkGrey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            ImageUrlHelper.getUrl(
              widget.brandImage!,
            ),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return Icon(
                Icons.broken_image_outlined,
                size: 50.r,
              );
            },
          ),
          Positioned(
            bottom: 10.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child:  Text(
                style: TextStyle(color: Colors.white),
                'extra_100'.tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED IMAGE
  // ============================================================

  Widget _buildSelectedImage() {
    return Container(
      width: 250.w,
      height: 180.h,
      color: AppColors.darkGrey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Stack(
          children: [
            Image.file(
              _image!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _image = null;
                    _imageFromSuggestion = false;
                    _suggestedLogoForName = null;
                  });
                },
                icon: Icon(
                  Icons.close,
                  color: AppColors.secondary,
                  size: 28.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    return BlocBuilder<BrandsBloc, BrandsState>(
      buildWhen: (previous, current) {
        return current is AddBrandLoading ||
            current is EditBrandLoading ||
            current is AddBrandSuccess ||
            current is EditBrandSuccess ||
            current is AddBrandError ||
            current is EditBrandError;
      },
      builder: (context, state) {
        final loading =
            state is AddBrandLoading ||
            state is EditBrandLoading || _downloadingLogo;

        return  ElevatedButtonWidget(
          width: 250.w,
          height: 65.h,
          onPressed: () {
            if (loading) return;
            _submit();
          },
          label: loading
              ? 'extra_077'.tr()
              : widget.isEdit
              ? 'extra_090'.tr()
              : 'extra_003'.tr(),
          icon: loading
              ? Icons.hourglass_top
              : widget.isEdit
              ? Icons.save_outlined
              : Icons.add,
        );
      },
    );
  }

  // ============================================================
  // CANCEL BUTTON
  // ============================================================

  Widget _buildCancelButton() {
    return SizedBox(
      width: 250.w,
      height: 60.h,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('ui_055'.tr()),
      ),
    );
  }
}
