import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/brand/presentation/manager/brands_bloc.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/cars/data/models/car_search_filters.dart';
import 'package:car_app/features/cars/presentation/manager/car_bloc.dart';
import 'package:car_app/features/cars/presentation/widgets/car_form_field.dart';
import 'package:car_app/features/cars/presentation/widgets/container_favorite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _filterKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _yearController = TextEditingController();

  int? _brandId;
  String? _fuelType;
  String? _gearType;
  bool _showFilters = false;

  static const _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  static const _gearTypes = ['Automatic', 'Manual'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandsBloc>().add(GetAllBrandsEvent());
      context.read<CarBloc>().add(ClearCarSearchEvent());
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    final form = _filterKey.currentState;
    if (form != null && !form.validate()) return;

    context.read<CarBloc>().add(
          SearchCarsEvent(
            filters: CarSearchFilters(
              brandId: _brandId,
              model: _modelController.text,
              minPrice: double.tryParse(_minPriceController.text.trim()),
              maxPrice: double.tryParse(_maxPriceController.text.trim()),
              year: int.tryParse(_yearController.text.trim()),
              fuelType: _fuelType,
              gearType: _gearType,
            ),
          ),
        );
  }

  void _clear() {
    _modelController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _yearController.clear();
    setState(() {
      _brandId = null;
      _fuelType = null;
      _gearType = null;
    });
    context.read<CarBloc>().add(ClearCarSearchEvent());
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value.trim());
    return number == null || number < 0 ? 'extra_054'.tr() : null;
  }

  String? _maxPriceValidator(String? value) {
    final basic = _priceValidator(value);
    if (basic != null || value == null || value.trim().isEmpty) return basic;
    final min = double.tryParse(_minPriceController.text.trim());
    final max = double.tryParse(value.trim());
    if (min != null && max != null && max < min) return 'extra_015'.tr();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(child: _buildSearchHeader()),
          SliverToBoxAdapter(child: _buildFilterPanel()),
          BlocBuilder<CarBloc, CarState>(
            builder: (context, state) {
              if (state is CarSearchLoadingState) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _statusView(
                    icon: Icons.manage_search_rounded,
                    title: 'ui_237'.tr(),
                    subtitle: 'ui_141'.tr(),
                    loading: true,
                  ),
                );
              }

              if (state is CarSearchErrorState) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _statusView(
                    icon: Icons.cloud_off_outlined,
                    title: 'ui_235'.tr(),
                    subtitle: state.message.replaceFirst('Exception: ', ''),
                    actionLabel: 'Try again',
                    onAction: _search,
                  ),
                );
              }

              if (state is CarSearchSuccessState) {
                if (state.cars.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _statusView(
                      icon: Icons.no_crash_outlined,
                      title: 'ui_157'.tr(),
                      subtitle: 'ui_279'.tr(),
                      actionLabel: 'extra_027'.tr(),
                      onAction: _clear,
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
                  sliver: SliverList.builder(
                    itemCount: state.cars.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _resultCount(state.cars.length);
                      }
                      return _SearchCarCard(car: state.cars[index - 1]);
                    },
                  ),
                );
              }

              return SliverFillRemaining(
                hasScrollBody: false,
                child: _statusView(
                  icon: Icons.travel_explore_rounded,
                  title: 'ui_122'.tr(),
                  subtitle: 'ui_234'.tr(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 10.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF242728), Color(0xFF121414)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ui_315'.tr(), style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 4.h),
          Text('ui_091'.tr(), style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
          SizedBox(height: 18.h),
          TextFormField(
            controller: _modelController,
            textInputAction: TextInputAction.search,
            onFieldSubmitted: (_) => _search(),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'ui_236'.tr(),
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                tooltip: 'ui_233'.tr(),
                onPressed: _search,
                icon: Icon(Icons.arrow_forward_rounded),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: AppColors.secondary),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                  icon: Icon(_showFilters ? Icons.tune_rounded : Icons.tune_outlined),
                  label: Text(_showFilters ? 'extra_053'.tr() : 'extra_098'.tr()),
                ),
              ),
              SizedBox(width: 10.w),
              IconButton.filledTonal(
                tooltip: 'ui_073'.tr(),
                onPressed: _clear,
                icon: Icon(Icons.restart_alt_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 260),
      crossFadeState: _showFilters ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: SizedBox(width: double.infinity),
      secondChild: Form(
        key: _filterKey,
        child: Container(
          margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            children: [
              BlocBuilder<BrandsBloc, BrandsState>(
                builder: (context, state) {
                  final brands = state is GetAllBrandsSuccess ? state.brands : [];
                  return CarDropdownField<int>(
                    value: brands.any((brand) => brand.brandId == _brandId) ? _brandId : null,
                    label: state is GetAllBrandsLoading ? 'extra_056'.tr() : 'Any brand',
                    icon: Icons.branding_watermark_outlined,
                    onChanged: state is GetAllBrandsLoading
                        ? null
                        : (value) => setState(() => _brandId = value),
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
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: CarFormField(
                      controller: _minPriceController,
                      label: 'ui_144'.tr(),
                      hint: '25000',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _priceValidator,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CarFormField(
                      controller: _maxPriceController,
                      label: 'ui_142'.tr(),
                      hint: '150000',
                      icon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _maxPriceValidator,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              CarFormField(
                controller: _yearController,
                label: 'ui_146'.tr(),
                hint: '2023',
                icon: Icons.calendar_month_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final year = int.tryParse(value);
                  return year == null || year < 1900 || year > DateTime.now().year + 1
                      ? 'extra_055'.tr()
                      : null;
                },
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: CarDropdownField<String>(
                      value: _fuelType,
                      label: 'ui_024'.tr(),
                      icon: Icons.local_gas_station_outlined,
                      onChanged: (value) => setState(() => _fuelType = value),
                      items: _fuelTypes
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.localized),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CarDropdownField<String>(
                      value: _gearType,
                      label: 'ui_025'.tr(),
                      icon: Icons.settings_outlined,
                      onChanged: (value) => setState(() => _gearType = value),
                      items: _gearTypes
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.localized),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: Icon(Icons.manage_search_rounded),
                  label: Text('ui_240'.tr()),
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.h)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultCount(int count) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Text(
            'dyn_cars_found'.tr(namedArgs: {'count': '$count'}),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
          ),
          Spacer(),
          Icon(Icons.auto_awesome, color: AppColors.secondary, size: 18.r),
          SizedBox(width: 5.w),
          Text('ui_047'.tr(), style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
        ],
      ),
    );
  }

  Widget _statusView({
    required IconData icon,
    required String title,
    required String subtitle,
    bool loading = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(34.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(19.r),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: loading
                  ? SizedBox(
                      width: 32.r,
                      height: 32.r,
                      child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2.5),
                    )
                  : Icon(icon, size: 36.r, color: AppColors.secondary),
            ),
            SizedBox(height: 16.h),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 6.h),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12.sp, height: 1.5)),
            if (actionLabel != null) ...[
              SizedBox(height: 18.h),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchCarCard extends StatelessWidget {
  final CarResponseModel car;

  _SearchCarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    final hasImage = car.imageUrls.isNotEmpty;
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.carDetails,
        arguments: car,
      ),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Container(
                width: 122.w,
                height: 112.h,
                color: Colors.white.withValues(alpha: 0.04),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasImage
                        ? Image.network(
                            ImageUrlHelper.getUrl(car.imageUrls.first),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageFallback(),
                          )
                        : _imageFallback(),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Transform.scale(
                        scale: 0.78,
                        alignment: Alignment.topRight,
                        child: ContainerFavoriteWidget(
                          car: car,
                          iconColor: Colors.white,
                          radius: 18.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          car.model,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Icon(Icons.arrow_outward_rounded, size: 17.r, color: Colors.white38),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\$${car.price.toStringAsFixed(0)}',
                    style: TextStyle(color: AppColors.secondary, fontSize: 15.sp, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      _chip(Icons.calendar_month_outlined, '${car.year}'),
                      _chip(Icons.route_outlined, '${car.mileage} km'),
                      _chip(Icons.local_gas_station_outlined, car.fuelType),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.white54),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 9.5.sp)),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Center(child: Icon(Icons.directions_car_rounded, size: 38.r, color: Colors.white24));
  }
}
