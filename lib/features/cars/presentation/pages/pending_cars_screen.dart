import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/admin/data/models/approve_request_model.dart';
import 'package:car_app/features/admin/data/models/reject_car_request_model.dart';
import 'package:car_app/features/admin/presentation/manager/approve_car/approve_car_bloc.dart';
import 'package:car_app/features/admin/presentation/manager/approve_car/approve_car_event.dart';
import 'package:car_app/features/admin/presentation/manager/approve_car/approve_car_state.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/cars/data/models/car_status_filters.dart';
import 'package:car_app/features/cars/presentation/manager/pending_cars_bloc.dart';
import 'package:car_app/features/cars/presentation/manager/pending_cars_event.dart';
import 'package:car_app/features/cars/presentation/manager/pending_cars_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PendingCarsScreen extends StatefulWidget {
  PendingCarsScreen({super.key});

  @override
  State<PendingCarsScreen> createState() => _PendingCarsScreenState();
}

class _PendingCarsScreenState extends State<PendingCarsScreen> {
  static const _approvalStatuses = ['Pending', 'Approved', 'Rejected'];
  static const _availabilityStatuses = ['Available', 'Rented', 'Sold'];

  final _ownerController = TextEditingController();
  bool _isRejectDialogOpen = false;
  String? _approvalStatus = 'Pending';
  String? _availabilityStatus;

  CarStatusFilters get _filters => CarStatusFilters(
        approvalStatus: _approvalStatus,
        availabilityStatus: _availabilityStatus,
        ownerId: int.tryParse(_ownerController.text.trim()),
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ownerController.dispose();
    super.dispose();
  }

  void _load() {
    context.read<PendingCarsBloc>().add(
          GetPendingCarsEvent(filters: _filters),
        );
  }

  Future<void> _refresh() async {
    final bloc = context.read<PendingCarsBloc>();
    _load();
    await bloc.stream.firstWhere(
      (state) => state.status != PendingCarsStatus.loading,
    );
  }

  void _clearFilters() {
    setState(() {
      _approvalStatus = null;
      _availabilityStatus = null;
      _ownerController.clear();
    });
    _load();
  }

  void _applyOwnerFilter() {
    final value = _ownerController.text.trim();
    if (value.isNotEmpty && (int.tryParse(value) ?? 0) <= 0) {
      _showSnack('ui_114'.tr(), isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    _load();
  }

  Future<void> _approve(CarResponseModel car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.verified_rounded, color: Color(0xFF35C68B)),
        title: Text(
          'dyn_approve_car'.tr(namedArgs: {'model': car.model}),
        ),
        content: Text(
          'dyn_car_visible'.tr(namedArgs: {'id': '${car.carId}'}),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('ui_055'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('ui_033'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<ApproveCarBloc>().add(
            ApproveCar(request: ApproveRequestModel(id: car.carId)),
          );
    }
  }

  Future<void> _reject(CarResponseModel car) async {
    if (_isRejectDialogOpen) return;
    _isRejectDialogOpen = true;

    final rejectRoute = DialogRoute<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RejectCarDialog(carModel: car.model),
    );

    try {
      final notes = await Navigator.of(context).push<String>(rejectRoute);

      // Wait until the dialog's overlay entries and reverse animation are fully
      // removed before rebuilding this screen from the BLoC response.
      await rejectRoute.completed;

      if (notes != null && mounted) {
        context.read<ApproveCarBloc>().add(
              RejectCar(
                request: RejectCarRequestModel(
                  carId: car.carId,
                  adminNotes: notes,
                ),
              ),
            );
      }
    } finally {
      _isRejectDialogOpen = false;
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message.replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? Color(0xFF8B3038) : Color(0xFF176B50),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApproveCarBloc, ApproveCarState>(
      listener: (context, actionState) {
        if (actionState.status == ApproveCarStatus.success) {
          _showSnack(actionState.message);
          _load();
        } else if (actionState.status == ApproveCarStatus.failure) {
          _showSnack(actionState.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('ui_062'.tr()),
          actions: [
            IconButton(
              tooltip: 'ui_210'.tr(),
              onPressed: _load,
              icon: Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child: BlocBuilder<PendingCarsBloc, PendingCarsState>(
                builder: (context, state) => _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<PendingCarsBloc, PendingCarsState>(
      builder: (context, state) => Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.24),
              Color(0xFF141616),
            ],
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.24),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: AppColors.secondary,
                size: 27.r,
              ),
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ui_292'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text('ui_228'.tr(),
                    style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
            Text(
              '${state.cars.length}',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatusDropdown(
                  label: 'ui_027'.tr(),
                  value: _approvalStatus,
                  allLabel: 'ui_017'.tr(),
                  values: _approvalStatuses,
                  icon: Icons.verified_outlined,
                  onChanged: (value) {
                    setState(() => _approvalStatus = value);
                    _load();
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatusDropdown(
                  label: 'ui_039'.tr(),
                  value: _availabilityStatus,
                  allLabel: 'ui_018'.tr(),
                  values: _availabilityStatuses,
                  icon: Icons.key_rounded,
                  onChanged: (value) {
                    setState(() => _availabilityStatus = value);
                    _load();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ownerController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _applyOwnerFilter(),
                  decoration: InputDecoration(
                    labelText: 'ui_184'.tr(),
                    hintText: 'ui_019'.tr(),
                    prefixIcon: Icon(Icons.person_search_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'ui_026'.tr(),
                      onPressed: _applyOwnerFilter,
                      icon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              IconButton.filledTonal(
                tooltip: 'ui_073'.tr(),
                onPressed: _clearFilters,
                icon: Icon(Icons.filter_alt_off_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(PendingCarsState state) {
    if (state.status == PendingCarsStatus.loading && state.cars.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }
    if (state.status == PendingCarsStatus.failure && state.cars.isEmpty) {
      return _AdminCarsEmpty(
        title: 'ui_079'.tr(),
        subtitle: state.message.replaceFirst('Exception: ', ''),
        onRefresh: _load,
      );
    }
    if (state.cars.isEmpty) {
      return _AdminCarsEmpty(
        title: 'ui_163'.tr(),
        subtitle: 'ui_277'.tr(),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.secondary,
      child: BlocBuilder<ApproveCarBloc, ApproveCarState>(
        builder: (context, actionState) => ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
          itemCount: state.cars.length,
          itemBuilder: (context, index) {
            final car = state.cars[index];
            return _AdminCarCard(
              car: car,
              isProcessing: actionState.status == ApproveCarStatus.loading &&
                  actionState.processingCarId == car.carId,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.carDetails,
                arguments: car.carId,
              ),
              onApprove: () => _approve(car),
              onReject: () => _reject(car),
            );
          },
        ),
      ),
    );
  }
}

class _RejectCarDialog extends StatefulWidget {
  final String carModel;

  const _RejectCarDialog({required this.carModel});

  @override
  State<_RejectCarDialog> createState() => _RejectCarDialogState();
}

class _RejectCarDialogState extends State<_RejectCarDialog> {
  final _notesController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      setState(() => _validationError = 'extra_083'.tr());
      return;
    }
    Navigator.of(context).pop(notes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      icon: Container(
        width: 58.r,
        height: 58.r,
        decoration: const BoxDecoration(
          color: Color(0x22FF5F6D),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.gpp_bad_rounded,
          color: const Color(0xFFFF5F6D),
          size: 30.r,
        ),
      ),
      title: Text(
        'dyn_reject_car'.tr(namedArgs: {'model': widget.carModel}),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ui_306'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
          SizedBox(height: 15.h),
          TextField(
            controller: _notesController,
            autofocus: true,
            minLines: 3,
            maxLines: 5,
            maxLength: 500,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'ui_014'.tr(),
              hintText: 'ui_115'.tr(),
              errorText: _validationError,
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('ui_055'.tr()),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5F6D),
          ),
          onPressed: _submit,
          icon: const Icon(Icons.close_rounded),
          label: Text('ui_214'.tr()),
        ),
      ],
    );
  }
}

class _AdminCarCard extends StatelessWidget {
  final CarResponseModel car;
  final bool isProcessing;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  _AdminCarCard({
    required this.car,
    required this.isProcessing,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final approval = car.approvalStatus.isEmpty ? 'Pending' : car.approvalStatus;
    final image = car.imageUrls.isEmpty
        ? ''
        : ImageUrlHelper.getUrl(car.imageUrls.first);
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            child: Padding(
              padding: EdgeInsets.all(13.r),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      width: 112.w,
                      height: 96.h,
                      child: image.isEmpty
                          ? _CarImageFallback()
                          : Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _CarImageFallback(),
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
                                car.model.isEmpty ? 'Car #${car.carId}' : car.model,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white38,
                            ),
                          ],
                        ),
                        SizedBox(height: 7.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: [
                            _CarStatusBadge(value: approval, approval: true),
                            _CarStatusBadge(
                              value: car.availabilityStatus.isEmpty
                                  ? 'extra_105'.tr()
                                  : car.availabilityStatus,
                            ),
                          ],
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          'dyn_owner_summary'.tr(namedArgs: {
                            'id': '${car.userId}',
                            'year': '${car.year}',
                            'price': car.price.toStringAsFixed(0),
                          }),
                          style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if ((car.approvalNotes ?? '').trim().isNotEmpty)
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 13.w),
              padding: EdgeInsets.all(11.r),
              decoration: BoxDecoration(
                color: _approvalColor(approval).withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                car.approvalNotes!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white60, fontSize: 10.sp),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(13.w, 12.h, 13.w, 13.h),
            child: isProcessing
                ? SizedBox(
                    height: 42.h,
                    child: Center(
                      child: SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      if (approval.toLowerCase() != 'rejected')
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFFFF6B76),
                              side: BorderSide(color: Color(0x55FF6B76)),
                            ),
                            icon: Icon(Icons.close_rounded),
                            label: Text('ui_213'.tr()),
                          ),
                        ),
                      if (approval.toLowerCase() != 'approved') ...[
                        if (approval.toLowerCase() != 'rejected')
                          SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            icon: Icon(Icons.check_rounded),
                            label: Text('ui_032'.tr()),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CarImageFallback extends StatelessWidget {
  _CarImageFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white.withValues(alpha: 0.05),
        child: Icon(
          Icons.directions_car_filled_rounded,
          color: Colors.white24,
          size: 38.r,
        ),
      );
}

class _CarStatusBadge extends StatelessWidget {
  final String value;
  final bool approval;

  _CarStatusBadge({required this.value, this.approval = false});

  @override
  Widget build(BuildContext context) {
    final color = approval
        ? _approvalColor(value)
        : _availabilityColor(value);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        value.localized,
        style: TextStyle(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String allLabel;
  final List<String> values;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  _StatusDropdown({
    required this.label,
    required this.value,
    required this.allLabel,
    required this.values,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value ?? '__all__',
      isExpanded: true,
      dropdownColor: Color(0xFF202222),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19.r),
      ),
      items: [
        DropdownMenuItem(value: '__all__', child: Text(allLabel)),
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
}

class _AdminCarsEmpty extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRefresh;

  _AdminCarsEmpty({
    required this.title,
    required this.subtitle,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.all(28.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.manage_search_rounded,
                color: AppColors.secondary,
                size: 52.r,
              ),
              SizedBox(height: 14.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 11.sp),
              ),
              if (onRefresh != null) ...[
                SizedBox(height: 17.h),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: Icon(Icons.refresh_rounded),
                  label: Text('ui_275'.tr()),
                ),
              ],
            ],
          ),
        ),
      );
}

Color _approvalColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return Color(0xFF35C68B);
    case 'rejected':
      return Color(0xFFFF5F6D);
    default:
      return Color(0xFFFFB547);
  }
}

Color _availabilityColor(String status) {
  switch (status.toLowerCase()) {
    case 'available':
      return Color(0xFF35C68B);
    case 'rented':
      return Color(0xFF58A6FF);
    case 'sold':
      return Color(0xFF90949B);
    default:
      return Colors.white54;
  }
}
