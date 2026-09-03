import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_icon.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/cars/data/models/car_status_filters.dart';
import 'package:car_app/features/home/presentation/widgets/card_car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helper/image_helper.dart';
import '../../../../cars/presentation/manager/car_bloc.dart';

class CarsInGarage extends StatefulWidget {
  CarsInGarage({super.key});

  @override
  State<CarsInGarage> createState() => _CarsInGarageState();
}

class _CarsInGarageState extends State<CarsInGarage> {
  static const _approvalStatuses = ['Pending', 'Approved', 'Rejected'];
  static const _availabilityStatuses = ['Available', 'Rented', 'Sold'];
  String? _approvalStatus;
  String? _availabilityStatus;

  CarStatusFilters get _filters => CarStatusFilters(
        approvalStatus: _approvalStatus,
        availabilityStatus: _availabilityStatus,
      );

  void _loadMyCars() {
    context.read<CarBloc>().add(GetMyCars(filters: _filters));
  }

  @override
  void initState() {
    super.initState();

    _loadMyCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50.w,
        title: Text(AppStrings.carsInGarage),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(AppIcon.arrowBack),
        ),
        actions: [
          IconButton(
            tooltip: 'ui_010'.tr(),
            onPressed: () async {
              final created = await Navigator.pushNamed<dynamic>(
                context,
                AppRoutes.addCar,
              );
              if (created == true && mounted) {
                _loadMyCars();
              }
            },
            icon: Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildGarageFilters()),
          BlocConsumer<CarBloc, CarState>(
            listener: (context, state) {
              if (state is DeleteCarSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.response.message),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
                _loadMyCars();
              } else if (state is DeleteCarErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message.replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
                _loadMyCars();
              }
            },
            builder: (context, state) {
              if (state is MyCarsLoadingState) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is DeleteCarLoadingState) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is MyCarsErrorState) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(state.massage),
                  ),
                );
              }

              if (state is MyCarsSuccessState) {
                if (state.myCars.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('ui_154'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final CarResponseModel car =
                      state.myCars[index];

                      return Column(
                        children: [
                          CardCar(
                            car: car,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.carDetails,
                                arguments: car,
                              );
                            },
                            name: car.model,
                            price: car.price,
                            speed: car.topSpeed.toDouble(),
                            hp: car.horsepower,
                            image: ImageUrlHelper.getUrl(
                              car.imageUrls.isEmpty ? '' : car.imageUrls.first,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          _buildListingActions(car, state),

                          SizedBox(height: 8.h),

                          _buildApprovalStatus(car),

                          SizedBox(height: 8.h),

                          _buildAvailabilityStatus(car),

                          SizedBox(height: 20.h),
                        ],
                      );
                    },
                    childCount: state.myCars.length,
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListingActions(CarResponseModel car, CarState state) {
    final deleting = state is DeleteCarLoadingState && state.carId == car.carId;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: deleting ? null : () => _openEditor(car),
              icon: Icon(Icons.edit_outlined),
              label: Text('ui_110'.tr()),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: deleting ? null : () => _confirmDelete(car),
              icon: deleting
                  ? SizedBox(
                      width: 17.r,
                      height: 17.r,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.delete_outline),
              label: Text(deleting ? 'extra_036'.tr() : 'Delete'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(CarResponseModel car) async {
    final updated = await Navigator.pushNamed<dynamic>(
      context,
      AppRoutes.addCar,
      arguments: AddCarRouteArguments(car: car),
    );
    if (updated == true && mounted) {
      _loadMyCars();
    }
  }

  Future<void> _confirmDelete(CarResponseModel car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('ui_099'.tr()),
        content: Text(
          'dyn_delete_car'.tr(namedArgs: {'model': car.model}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('ui_055'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('ui_094'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<CarBloc>().add(DeleteCarEvent(carId: car.carId));
    }
  }

  Widget _buildApprovalStatus(CarResponseModel car) {
    switch (car.approvalStatus.toLowerCase()) {
      case 'pending':
        return _statusContainer(
          icon: Icons.hourglass_top,
          title: 'ui_030'.tr(),
          subtitle: 'ui_313'.tr(),
          iconColor: Colors.orange,
          borderColor: Colors.orange,
        );

      case 'approved':
        return _statusContainer(
          icon: Icons.check_circle,
          title: 'ui_029'.tr(),
          subtitle: 'ui_312'.tr(),
          iconColor: Colors.green,
          borderColor: Colors.green,
        );

      case 'rejected':
        return _statusContainer(
          icon: Icons.cancel,
          title: 'ui_031'.tr(),
          subtitle: car.approvalNotes?.toString() ?? '',
          iconColor: Colors.red,
          borderColor: Colors.red,
        );

      default:
        return _statusContainer(
          icon: Icons.info,
          title: car.approvalStatus.isEmpty
              ? 'extra_007'.tr()
              : car.approvalStatus.localized,
          subtitle: '',
          iconColor: Colors.grey,
          borderColor: Colors.grey,
        );
    }
  }

  Widget _buildAvailabilityStatus(CarResponseModel car) {
    switch (car.availabilityStatus.toLowerCase()) {
      case 'available':
        return _statusContainer(
          icon: Icons.key_rounded,
          title: 'ui_042'.tr(),
          subtitle: 'ui_259'.tr(),
          iconColor: Colors.green,
          borderColor: Colors.green,
        );
      case 'rented':
        return _statusContainer(
          icon: Icons.calendar_month_rounded,
          title: 'ui_043'.tr(),
          subtitle: 'ui_260'.tr(),
          iconColor: Colors.blueAccent,
          borderColor: Colors.blueAccent,
        );
      case 'sold':
        return _statusContainer(
          icon: Icons.sell_rounded,
          title: 'ui_044'.tr(),
          subtitle: 'ui_258'.tr(),
          iconColor: Colors.blueGrey,
          borderColor: Colors.blueGrey,
        );
      default:
        return _statusContainer(
          icon: Icons.info_outline_rounded,
          title: car.availabilityStatus.isEmpty
              ? 'extra_012'.tr()
              : car.availabilityStatus.localized,
          subtitle: '',
          iconColor: Colors.grey,
          borderColor: Colors.grey,
        );
    }
  }

  Widget _buildGarageFilters() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      padding: EdgeInsets.all(13.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: Colors.white70, size: 19.r),
              SizedBox(width: 8.w),
              Text('ui_120'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _approvalStatus = null;
                    _availabilityStatus = null;
                  });
                  _loadMyCars();
                },
                child: Text('ui_072'.tr()),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _GarageFilterDropdown(
                  label: 'ui_027'.tr(),
                  value: _approvalStatus,
                  values: _approvalStatuses,
                  onChanged: (value) {
                    setState(() => _approvalStatus = value);
                    _loadMyCars();
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _GarageFilterDropdown(
                  label: 'ui_039'.tr(),
                  value: _availabilityStatus,
                  values: _availabilityStatuses,
                  onChanged: (value) {
                    setState(() => _availabilityStatus = value);
                    _loadMyCars();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusContainer({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GarageFilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  _GarageFilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        value: value ?? '__all__',
        isExpanded: true,
        dropdownColor: Color(0xFF202222),
        decoration: InputDecoration(labelText: label),
        items: [
          DropdownMenuItem(value: '__all__', child: Text('ui_016'.tr())),
          ...values.map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item.localized),
            ),
          ),
        ],
        onChanged: (selected) =>
            onChanged(selected == '__all__' ? null : selected),
      );
}
