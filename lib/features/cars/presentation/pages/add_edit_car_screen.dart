import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'dart:io';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/data/vehicle_image_remote_data_source.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/models/suggested_vehicle_image.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:car_app/features/brand/presentation/manager/brands_bloc.dart';
import 'package:car_app/features/cars/data/models/car_request_model.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/cars/presentation/manager/car_bloc.dart';
import 'package:car_app/features/cars/presentation/widgets/car_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class AddEditCarScreen extends StatefulWidget {
  final CarResponseModel? car;
  final String initialStatus;

  AddEditCarScreen({
    super.key,
    this.car,
    this.initialStatus = 'Available',
  });

  bool get isEdit => car != null;

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final VehicleImageRemoteDataSource _imageRemoteDataSource =
      const VehicleImageRemoteDataSource();

  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;
  late final TextEditingController _priceController;
  late final TextEditingController _mileageController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _rentPriceController;
  late final TextEditingController _cylindersController;
  late final TextEditingController _interiorColorController;
  late final TextEditingController _keysController;
  late final TextEditingController _regionController;
  late final TextEditingController _horsepowerController;
  late final TextEditingController _topSpeedController;

  int _step = 0;
  int? _brandId;
  String? _fuelType;
  String? _gearType;
  String? _driveType;
  late String _status;
  final List<File> _newImages = [];
  late List<String> _existingImages;
  final List<SuggestedVehicleImage> _suggestedImages = [];
  final Set<String> _downloadingSuggestionUrls = {};
  final Set<String> _addedSuggestionUrls = {};
  final Map<String, String> _suggestionUrlByFilePath = {};
  Timer? _imageSearchDebounce;
  bool _suggestionsLoading = false;
  String? _suggestionsError;
  String? _lastSuggestionQuery;
  int _suggestionRequestId = 0;

  static const _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  static const _gearTypes = ['Automatic', 'Manual'];
  static const _driveTypes = ['FWD', 'RWD', 'AWD', '4WD'];
  static const _statuses = ['Available', 'For Sale', 'For Rent'];

  @override
  void initState() {
    super.initState();
    final car = widget.car;
    _brandId = car?.brandId;
    _fuelType = _valueOrNull(_fuelTypes, car?.fuelType);
    _gearType = _valueOrNull(_gearTypes, car?.gearType);
    _driveType = _valueOrNull(_driveTypes, car?.driveType);
    _status = _statuses.contains(car?.status)
        ? car!.status
        : (_statuses.contains(widget.initialStatus)
            ? widget.initialStatus
            : _statuses.first);
    _existingImages = List<String>.from(car?.imageUrls ?? []);

    _modelController = TextEditingController(text: car?.model ?? '');
    _yearController = TextEditingController(text: _intText(car?.year));
    _colorController = TextEditingController(text: car?.color ?? '');
    _priceController = TextEditingController(text: _doubleText(car?.price));
    _mileageController = TextEditingController(text: _intText(car?.mileage));
    _descriptionController = TextEditingController(text: car?.description ?? '');
    _rentPriceController = TextEditingController(
      text: _doubleText(car?.rentPricePerDay),
    );
    _cylindersController = TextEditingController(text: _intText(car?.cylinders));
    _interiorColorController = TextEditingController(
      text: car?.interiorColor ?? '',
    );
    _keysController = TextEditingController(text: _intText(car?.keysCount));
    _regionController = TextEditingController(text: car?.region ?? '');
    _horsepowerController = TextEditingController(
      text: _intText(car?.horsepower),
    );
    _topSpeedController = TextEditingController(text: _intText(car?.topSpeed));
    _modelController.addListener(_scheduleCarImageSearch);
    _yearController.addListener(_scheduleCarImageSearch);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandsBloc>().add(GetAllBrandsEvent());
    });
  }

  @override
  void dispose() {
    _imageSearchDebounce?.cancel();
    for (final controller in [
      _modelController,
      _yearController,
      _colorController,
      _priceController,
      _mileageController,
      _descriptionController,
      _rentPriceController,
      _cylindersController,
      _interiorColorController,
      _keysController,
      _regionController,
      _horsepowerController,
      _topSpeedController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _valueOrNull(List<String> values, String? value) {
    if (value == null) return null;
    for (final option in values) {
      if (option.toLowerCase() == value.toLowerCase()) return option;
    }
    return null;
  }

  String _intText(int? value) => value == null || value == 0 ? '' : '$value';

  String _doubleText(double? value) {
    if (value == null || value == 0) return '';
    return value == value.roundToDouble() ? '${value.toInt()}' : '$value';
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty || !mounted) return;

    final available = 8 - (_existingImages.length + _newImages.length);
    if (available <= 0) {
      _showMessage('ui_311'.tr());
      return;
    }

    setState(() {
      _newImages.addAll(
        picked.take(available).map((image) => File(image.path)),
      );
    });
    if (picked.length > available) {
      _showMessage(
        'dyn_only_photos'.tr(namedArgs: {'count': '$available'}),
      );
    }
  }

  String? _selectedBrandName() {
    final state = context.read<BrandsBloc>().state;
    if (state is! GetAllBrandsSuccess || _brandId == null) return null;
    for (final brand in state.brands) {
      if (brand.brandId == _brandId) return brand.name?.trim();
    }
    return null;
  }

  void _scheduleCarImageSearch({bool immediate = false, bool force = false}) {
    _imageSearchDebounce?.cancel();
    final brand = _selectedBrandName();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    if (brand == null || brand.isEmpty || model.length < 2 || year == null) {
      return;
    }
    final query = '$brand|$model|$year';
    if (!force && query == _lastSuggestionQuery && _suggestedImages.isNotEmpty) {
      return;
    }
    _imageSearchDebounce = Timer(
      immediate ? Duration.zero : const Duration(milliseconds: 850),
      () => _searchSuggestedImages(
        brand: brand,
        model: model,
        year: year,
        query: query,
      ),
    );
  }

  Future<void> _searchSuggestedImages({
    required String brand,
    required String model,
    required int year,
    required String query,
  }) async {
    final requestId = ++_suggestionRequestId;
    if (mounted) {
      setState(() {
        if (_lastSuggestionQuery != query) _suggestedImages.clear();
        _suggestionsLoading = true;
        _suggestionsError = null;
        _lastSuggestionQuery = query;
      });
    }
    try {
      final results = await _imageRemoteDataSource.searchCarImages(
        brand: brand,
        model: model,
        year: year,
      );
      if (!mounted || requestId != _suggestionRequestId) return;
      setState(() {
        _suggestedImages
          ..clear()
          ..addAll(results);
        _suggestionsLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _suggestionRequestId) return;
      setState(() {
        _suggestionsLoading = false;
        _suggestionsError = 'app_image_search_failed'.tr();
      });
    }
  }

  Future<void> _addSuggestedImage(SuggestedVehicleImage image) async {
    if (_addedSuggestionUrls.contains(image.downloadUrl) ||
        _downloadingSuggestionUrls.contains(image.downloadUrl)) {
      return;
    }
    if (_existingImages.length +
            _newImages.length +
            _downloadingSuggestionUrls.length >=
        8) {
      _showMessage('ui_311'.tr());
      return;
    }
    setState(() => _downloadingSuggestionUrls.add(image.downloadUrl));
    try {
      final file = await _imageRemoteDataSource.downloadImage(
        Uri.parse(image.downloadUrl),
        fileNamePrefix:
            '${_selectedBrandName() ?? 'car'}_${_modelController.text}_${_yearController.text}',
      );
      if (!mounted) return;
      setState(() {
        _newImages.add(file);
        _addedSuggestionUrls.add(image.downloadUrl);
        _suggestionUrlByFilePath[file.path] = image.downloadUrl;
      });
      _showMessage('app_suggested_photo_added'.tr(), success: true);
    } catch (_) {
      if (mounted) _showMessage('app_image_download_failed'.tr());
    } finally {
      if (mounted) {
        setState(() => _downloadingSuggestionUrls.remove(image.downloadUrl));
      }
    }
  }

  void _removeNewImage(int index) {
    final removed = _newImages.removeAt(index);
    final sourceUrl = _suggestionUrlByFilePath.remove(removed.path);
    if (sourceUrl != null) _addedSuggestionUrls.remove(sourceUrl);
  }

  Future<void> _openSuggestedImageSource(String url) async {
    if (url.trim().isEmpty) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) _showMessage('app_image_source_failed'.tr());
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step < 2) {
      final nextStep = _step + 1;
      setState(() => _step = nextStep);
      if (nextStep == 2) {
        _scheduleCarImageSearch(immediate: true);
      }
    }
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    if (step == 2) _scheduleCarImageSearch(immediate: true);
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _step = 0);
      _showMessage('ui_201'.tr());
      return;
    }
    if (_existingImages.isEmpty && _newImages.isEmpty) {
      setState(() => _step = 2);
      _showMessage('ui_009'.tr());
      return;
    }

    final request = CarRequestModel(
      brandId: _brandId!,
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      color: _colorController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      fuelType: _fuelType!,
      gearType: _gearType!,
      mileage: int.parse(_mileageController.text.trim()),
      description: _descriptionController.text.trim(),
      rentPricePerDay: _rentPriceController.text.trim().isEmpty
          ? null
          : double.parse(_rentPriceController.text.trim()),
      status: _status,
      imageUrls: _existingImages,
      images: _newImages,
      cylinders: int.parse(_cylindersController.text.trim()),
      interiorColor: _interiorColorController.text.trim(),
      keysCount: int.parse(_keysController.text.trim()),
      driveType: _driveType!,
      region: _regionController.text.trim(),
      horsepower: int.parse(_horsepowerController.text.trim()),
      topSpeed: int.parse(_topSpeedController.text.trim()),
    );

    if (widget.isEdit) {
      context.read<CarBloc>().add(
            EditCarEvent(carId: widget.car!.carId, request: request),
          );
    } else {
      context.read<CarBloc>().add(AddCarEvent(request: request));
    }
  }

  void _handleState(BuildContext context, CarState state) {
    if (state is AddCarSuccessState) {
      final carBloc = context.read<CarBloc>();
      _showMessage(state.response.message, success: true);
      Navigator.pop(context, true);
      carBloc.add(GetAllCars());
    } else if (state is EditCarSuccessState) {
      _showMessage(state.response.message, success: true);
      Navigator.pop(context, true);
    } else if (state is AddCarErrorState) {
      _showMessage(state.message);
    } else if (state is EditCarErrorState) {
      _showMessage(state.message);
    }
  }

  void _showMessage(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message.replaceFirst('Exception: ', '')),
          backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'extra_085'.tr() : null;
  }

  String? _positiveInt(String? value) {
    final number = int.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? 'extra_039'.tr() : null;
  }

  String? _positiveDouble(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || number < 0 ? 'extra_038'.tr() : null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CarBloc, CarState>(
      listener: _handleState,
      builder: (context, state) {
        final isLoading = state is AddCarLoadingState || state is EditCarLoadingState;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(onPressed: _back, icon: Icon(Icons.arrow_back)),
            title: Text(widget.isEdit ? 'Edit listing' : 'extra_034'.tr()),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeroHeader(),
                _buildProgress(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
                      child: IndexedStack(
                        index: _step,
                        children: [
                          _buildBasics(),
                          _buildSpecifications(),
                          _buildPhotosAndReview(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildBottomActions(isLoading),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 10.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.95),
            Color(0xFF7D2A15),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Icons.directions_car_filled_rounded, size: 32.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEdit ? 'extra_078'.tr() : 'extra_096'.tr(),
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4.h),
                Text('ui_007'.tr(),
                  style: TextStyle(color: Colors.white70, fontSize: 11.5.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final labels = ['extra_014'.tr(), 'extra_099'.tr(), 'extra_070'.tr()];
    const icons = [Icons.tune_rounded, Icons.speed_rounded, Icons.photo_library_rounded];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index <= _step;
          return Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _goToStep(index),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 220),
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: active ? AppColors.secondary : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icons[index], size: 18.r, color: Colors.white),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: active ? Colors.white : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.only(bottom: 18.h),
                      color: index < _step ? AppColors.secondary : Colors.white10,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasics() {
    return _section(
      title: 'ui_250'.tr(),
      subtitle: 'ui_253'.tr(),
      children: [
        BlocBuilder<BrandsBloc, BrandsState>(
          builder: (context, state) {
            if (state is GetAllBrandsLoading) {
              return LinearProgressIndicator();
            }
            if (state is GetAllBrandsError) {
              return _inlineError(
                state.massage,
                () => context.read<BrandsBloc>().add(GetAllBrandsEvent()),
              );
            }
            final brands = state is GetAllBrandsSuccess ? state.brands : [];
            return CarDropdownField<int>(
              value: brands.any((brand) => brand.brandId == _brandId) ? _brandId : null,
              label: 'ui_048'.tr(),
              icon: Icons.branding_watermark_outlined,
              validator: (value) => value == null ? 'extra_025'.tr() : null,
              onChanged: (value) {
                setState(() => _brandId = value);
                _scheduleCarImageSearch();
              },
              items: brands
                  .where((brand) => brand.brandId != null)
                  .map(
                    (brand) => DropdownMenuItem<int>(
                      value: brand.brandId,
                      child: Text(brand.name ?? 'Brand #${brand.brandId}'),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        _gap(),
        CarFormField(
          controller: _modelController,
          label: 'ui_145'.tr(),
          hint: 'extra_112'.tr(),
          icon: Icons.directions_car_outlined,
          validator: _required,
        ),
        _gap(),
        Row(
          children: [
            Expanded(
              child: CarFormField(
                controller: _yearController,
                label: 'ui_307'.tr(),
                hint: '2024',
                icon: Icons.calendar_month_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final year = int.tryParse(value ?? '');
                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                    return 'extra_055'.tr();
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CarFormField(
                controller: _colorController,
                label: 'ui_116'.tr(),
                hint: 'Black',
                icon: Icons.palette_outlined,
                validator: _required,
              ),
            ),
          ],
        ),
        _gap(),
        CarFormField(
          controller: _priceController,
          label: 'ui_230'.tr(),
          hint: '85000',
          icon: Icons.sell_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixText: 'USD',
          validator: _positiveDouble,
        ),
        _gap(),
        Row(
          children: [
            Expanded(
              child: CarDropdownField<String>(
                value: _fuelType,
                label: 'ui_124'.tr(),
                icon: Icons.local_gas_station_outlined,
                validator: (value) => value == null ? 'extra_085'.tr() : null,
                onChanged: (value) => setState(() => _fuelType = value),
                items: _fuelTypes
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.localized),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CarDropdownField<String>(
                value: _gearType,
                label: 'ui_126'.tr(),
                icon: Icons.settings_outlined,
                validator: (value) => value == null ? 'extra_085'.tr() : null,
                onChanged: (value) => setState(() => _gearType = value),
                items: _gearTypes
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.localized),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        _gap(),
        CarFormField(
          controller: _mileageController,
          label: 'ui_143'.tr(),
          hint: '25000',
          icon: Icons.route_outlined,
          keyboardType: TextInputType.number,
          suffixText: 'km',
          validator: _positiveInt,
        ),
      ],
    );
  }

  Widget _buildSpecifications() {
    return _section(
      title: 'ui_195'.tr(),
      subtitle: 'ui_128'.tr(),
      children: [
        Row(
          children: [
            Expanded(
              child: CarFormField(
                controller: _horsepowerController,
                label: 'ui_129'.tr(),
                hint: '450',
                icon: Icons.bolt_outlined,
                keyboardType: TextInputType.number,
                suffixText: 'hp',
                validator: _positiveInt,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CarFormField(
                controller: _topSpeedController,
                label: 'ui_261'.tr(),
                hint: '310',
                icon: Icons.speed_outlined,
                keyboardType: TextInputType.number,
                suffixText: 'km/h',
                validator: _positiveInt,
              ),
            ),
          ],
        ),
        _gap(),
        Row(
          children: [
            Expanded(
              child: CarFormField(
                controller: _cylindersController,
                label: 'ui_093'.tr(),
                hint: '6',
                icon: Icons.precision_manufacturing_outlined,
                keyboardType: TextInputType.number,
                validator: _positiveInt,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CarFormField(
                controller: _keysController,
                label: 'ui_136'.tr(),
                hint: '2',
                icon: Icons.key_outlined,
                keyboardType: TextInputType.number,
                validator: _positiveInt,
              ),
            ),
          ],
        ),
        _gap(),
        CarDropdownField<String>(
          value: _driveType,
          label: 'ui_106'.tr(),
          icon: Icons.alt_route_outlined,
          validator: (value) => value == null ? 'extra_085'.tr() : null,
          onChanged: (value) => setState(() => _driveType = value),
          items: _driveTypes
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.localized),
                  ))
              .toList(),
        ),
        _gap(),
        Row(
          children: [
            Expanded(
              child: CarFormField(
                controller: _interiorColorController,
                label: 'ui_133'.tr(),
                hint: 'Tan',
                icon: Icons.airline_seat_recline_extra_outlined,
                validator: _required,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CarFormField(
                controller: _regionController,
                label: 'ui_212'.tr(),
                hint: 'Dubai',
                icon: Icons.location_on_outlined,
                validator: _required,
              ),
            ),
          ],
        ),
        _gap(),
        CarDropdownField<String>(
          value: _status,
          label: 'ui_138'.tr(),
          icon: Icons.verified_outlined,
          onChanged: (value) => setState(() => _status = value ?? _status),
          items: _statuses
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.localized),
                  ))
              .toList(),
        ),
        _gap(),
        CarFormField(
          controller: _rentPriceController,
          label: 'ui_217'.tr(),
          hint: '450',
          icon: Icons.event_available_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixText: 'USD',
          validator: (value) => value == null || value.trim().isEmpty
              ? null
              : _positiveDouble(value),
        ),
        _gap(),
        CarFormField(
          controller: _descriptionController,
          label: 'ui_101'.tr(),
          hint: 'extra_029'.tr(),
          icon: Icons.notes_outlined,
          maxLines: 4,
          validator: _required,
        ),
      ],
    );
  }

  Widget _buildSmartImageSuggestions() {
    final brand = _selectedBrandName();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final ready = brand != null &&
        brand.isNotEmpty &&
        model.length >= 2 &&
        year != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'app_smart_car_photos'.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      ready
                          ? '$brand $model $year'
                          : 'app_complete_car_identity'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white54, fontSize: 9.sp),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'app_search_photos'.tr(),
                onPressed: !ready || _suggestionsLoading
                    ? null
                    : () => _scheduleCarImageSearch(
                          immediate: true,
                          force: true,
                        ),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (!ready)
            _suggestionMessage(
              icon: Icons.edit_note_rounded,
              message: 'app_car_identity_hint'.tr(),
            )
          else if (_suggestionsLoading && _suggestedImages.isEmpty)
            SizedBox(
              height: 92.h,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 9.h),
                    Text(
                      'app_searching_car_photos'.tr(),
                      style: TextStyle(color: Colors.white54, fontSize: 9.sp),
                    ),
                  ],
                ),
              ),
            )
          else if (_suggestionsError != null)
            _suggestionMessage(
              icon: Icons.cloud_off_rounded,
              message: _suggestionsError!,
              onRetry: () => _scheduleCarImageSearch(
                immediate: true,
                force: true,
              ),
            )
          else if (_lastSuggestionQuery != null && _suggestedImages.isEmpty)
            _suggestionMessage(
              icon: Icons.image_search_rounded,
              message: 'app_no_suggested_photos'.tr(),
              onRetry: () => _scheduleCarImageSearch(
                immediate: true,
                force: true,
              ),
            )
          else if (_suggestedImages.isNotEmpty) ...[
            SizedBox(
              height: 178.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestedImages.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) =>
                    _buildSuggestedImageCard(_suggestedImages[index]),
              ),
            ),
            SizedBox(height: 9.h),
            Row(
              children: [
                Icon(Icons.touch_app_rounded, color: Colors.white38, size: 14.r),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    'app_tap_photo_to_add'.tr(),
                    style: TextStyle(color: Colors.white38, fontSize: 8.5.sp),
                  ),
                ),
                if (_suggestionsLoading)
                  SizedBox(
                    width: 14.r,
                    height: 14.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _scheduleCarImageSearch(
                  immediate: true,
                  force: true,
                ),
                icon: const Icon(Icons.image_search_rounded),
                label: Text('app_search_photos'.tr()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedImageCard(SuggestedVehicleImage image) {
    final downloading = _downloadingSuggestionUrls.contains(image.downloadUrl);
    final added = _addedSuggestionUrls.contains(image.downloadUrl);
    final licenseLabel = image.license.trim().isEmpty
        ? 'Wikimedia Commons'
        : 'Wikimedia • ${image.license}';
    final license = image.artist.trim().isEmpty
        ? licenseLabel
        : '$licenseLabel • ${image.artist}';
    return InkWell(
      onTap: downloading || added ? null : () => _addSuggestedImage(image),
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: added
                ? const Color(0xFF35C68B)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image.previewUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF242626),
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 7.h,
              left: 7.w,
              child: IconButton.filled(
                tooltip: 'app_view_image_source'.tr(),
                onPressed: image.sourcePageUrl.trim().isEmpty
                    ? null
                    : () => _openSuggestedImageSource(image.sourcePageUrl),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  disabledBackgroundColor: Colors.black26,
                ),
                icon: Icon(Icons.info_outline_rounded, size: 16.r),
              ),
            ),
            Positioned(
              top: 7.h,
              right: 7.w,
              child: Container(
                width: 30.r,
                height: 30.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: added
                      ? const Color(0xFF35C68B)
                      : AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: downloading
                    ? SizedBox(
                        width: 15.r,
                        height: 15.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Icon(
                        added ? Icons.check_rounded : Icons.add_rounded,
                        size: 19.r,
                        color: Colors.black,
                      ),
              ),
            ),
            Positioned(
              left: 9.w,
              right: 9.w,
              bottom: 8.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    license,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white54, fontSize: 7.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionMessage({
    required IconData icon,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(13.r),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 22.r),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white60, fontSize: 9.5.sp),
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotosAndReview() {
    final totalImages = _existingImages.length + _newImages.length;
    return _section(
      title: 'ui_140'.tr(),
      subtitle: 'ui_139'.tr(),
      children: [
        _buildSmartImageSuggestions(),
        SizedBox(height: 16.h),
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 26.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.55),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(13.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_a_photo_outlined, size: 27.r),
                ),
                SizedBox(height: 12.h),
                Text('ui_011'.tr(), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 4.h),
                Text(
                  'dyn_photos_count'.tr(
                    namedArgs: {'count': '$totalImages'},
                  ),
                  style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ),
        if (totalImages > 0) ...[
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 9.w,
              mainAxisSpacing: 9.h,
              childAspectRatio: 1.15,
            ),
            itemCount: totalImages,
            itemBuilder: (context, index) {
              final existing = index < _existingImages.length;
              final image = existing
                  ? Image.network(
                      ImageUrlHelper.getUrl(_existingImages[index]),
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      _newImages[index - _existingImages.length],
                      fit: BoxFit.cover,
                    );
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(13.r), child: image),
                  Positioned(
                    right: 4.w,
                    top: 4.h,
                    child: InkWell(
                      onTap: () => setState(() {
                        if (existing) {
                          _existingImages.removeAt(index);
                        } else {
                          _removeNewImage(index - _existingImages.length);
                        }
                      }),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                        child: Icon(Icons.close, size: 15.r, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              _reviewRow(Icons.directions_car_outlined, 'Vehicle', _modelController.text.trim().isEmpty ? 'extra_063'.tr() : _modelController.text.trim()),
              _reviewRow(Icons.sell_outlined, 'extra_080'.tr(), _priceController.text.trim().isEmpty ? 'extra_063'.tr() : '\$${_priceController.text.trim()}'),
              _reviewRow(Icons.location_on_outlined, 'Region', _regionController.text.trim().isEmpty ? 'extra_063'.tr() : _regionController.text.trim()),
              _reviewRow(Icons.photo_library_outlined, 'extra_070'.tr(), '$totalImages selected', isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Column(
      key: ValueKey(title),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 4.h),
        Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
        SizedBox(height: 20.h),
        ...children,
      ],
    );
  }

  Widget _inlineError(String message, VoidCallback retry) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14.r)),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent),
          SizedBox(width: 10.w),
          Expanded(child: Text(message.replaceFirst('Exception: ', ''))),
          IconButton(onPressed: retry, icon: Icon(Icons.refresh)),
        ],
      ),
    );
  }

  Widget _reviewRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20.r),
          SizedBox(width: 10.w),
          Text(label, style: TextStyle(color: Colors.white54)),
          Spacer(),
          Flexible(child: Text(value, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool loading) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundAppbar,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: loading ? null : _back,
                style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 15.h)),
                child: Text('ui_045'.tr()),
              ),
            ),
          if (_step > 0) SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: loading ? null : (_step == 2 ? _submit : _next),
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 15.h)),
              child: loading
                  ? SizedBox(
                      height: 20.r,
                      width: 20.r,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_step == 2 ? (widget.isEdit ? 'extra_091'.tr() : 'extra_081'.tr()) : 'extra_031'.tr()),
                        SizedBox(width: 7.w),
                        Icon(_step == 2 ? Icons.rocket_launch_outlined : Icons.arrow_forward, size: 18.r),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap() => SizedBox(height: 13.h);
}
