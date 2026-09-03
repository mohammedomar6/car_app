import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'dart:io';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/cars/data/models/car_response_model.dart';
import 'package:car_app/features/orders/data/models/order_requests.dart';
import 'package:car_app/features/orders/presentation/manager/order_bloc.dart';
import 'package:car_app/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class CreateOrderArguments {
  final CarResponseModel car;
  final String initialType;

  CreateOrderArguments({
    required this.car,
    this.initialType = 'Buy',
  });
}

class CreateOrderScreen extends StatefulWidget {
  final CarResponseModel car;
  final String initialType;

  CreateOrderScreen({
    super.key,
    required this.car,
    this.initialType = 'Buy',
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  final Map<String, XFile> _documents = {};

  late String _orderType;
  late DateTime _startDate;
  late DateTime _endDate;
  int _installmentMonths = 12;

  @override
  void initState() {
    super.initState();
    _orderType = ['Buy', 'Rent', 'Installment'].contains(widget.initialType)
        ? widget.initialType
        : 'Buy';
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day).add(Duration(days: 1));
    _endDate = _startDate.add(Duration(days: 2));
    context.read<OrderBloc>().add(ClearOrderAvailabilityEvent());
    context.read<OrderBloc>().add(ResetOrderFeedbackEvent());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<_DocumentRequirement> get _requirements {
    switch (_orderType) {
      case 'Rent':
        return [
          _DocumentRequirement(
            keyName: 'identity',
            title: 'ui_130'.tr(),
            subtitle: 'ui_001'.tr(),
            icon: Icons.badge_rounded,
          ),
          _DocumentRequirement(
            keyName: 'license',
            title: 'ui_290'.tr(),
            subtitle: 'ui_223'.tr(),
            icon: Icons.credit_card_rounded,
          ),
        ];
      case 'Installment':
        return [
          _DocumentRequirement(
            keyName: 'identity',
            title: 'ui_130'.tr(),
            subtitle: 'ui_004'.tr(),
            icon: Icons.badge_rounded,
          ),
          _DocumentRequirement(
            keyName: 'income',
            title: 'ui_205'.tr(),
            subtitle: 'ui_229'.tr(),
            icon: Icons.work_rounded,
          ),
          _DocumentRequirement(
            keyName: 'bank',
            title: 'ui_207'.tr(),
            subtitle: 'ui_002'.tr(),
            icon: Icons.account_balance_rounded,
          ),
        ];
      default:
        return [
          _DocumentRequirement(
            keyName: 'identity',
            title: 'ui_130'.tr(),
            subtitle: 'ui_004'.tr(),
            icon: Icons.badge_rounded,
          ),
          _DocumentRequirement(
            keyName: 'payment',
            title: 'ui_189'.tr(),
            subtitle: 'ui_170'.tr(),
            icon: Icons.receipt_long_rounded,
            isRequired: false,
          ),
        ];
    }
  }

  int get _rentalDays {
    final days = _endDate.difference(_startDate).inDays;
    return days < 1 ? 1 : days;
  }

  double get _estimatedTotal {
    if (_orderType == 'Rent') {
      return (widget.car.rentPricePerDay ?? 0) * _rentalDays;
    }
    return widget.car.price;
  }

  void _changeOrderType(String type) {
    if (_orderType == type) return;
    setState(() {
      _orderType = type;
      _documents.clear();
    });
    context.read<OrderBloc>().add(ClearOrderAvailabilityEvent());
  }

  Future<void> _pickDocument(_DocumentRequirement requirement) async {
    final selected = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (selected == null || !mounted) return;
    setState(() => _documents[requirement.keyName] = selected);
  }

  Future<void> _selectDate({required bool start}) async {
    final current = start ? _startDate : _endDate;
    final firstDate = start ? DateTime.now() : _startDate.add(Duration(days: 1));
    final selected = await showDatePicker(
      context: context,
      initialDate: current.isBefore(firstDate) ? firstDate : current,
      firstDate: DateTime(firstDate.year, firstDate.month, firstDate.day),
      lastDate: DateTime.now().add(Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.secondary,
            surface: Color(0xFF171919),
          ),
        ),
        child: child!,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (start) {
        _startDate = selected;
        if (!_endDate.isAfter(_startDate)) {
          _endDate = _startDate.add(Duration(days: 1));
        }
      } else {
        _endDate = selected;
      }
    });
    context.read<OrderBloc>().add(ClearOrderAvailabilityEvent());
  }

  void _checkAvailability() {
    context.read<OrderBloc>().add(
          CheckOrderAvailabilityEvent(
            carId: widget.car.carId,
            orderType: _orderType,
            startDate: _orderType == 'Rent' ? _startDate : null,
            endDate: _orderType == 'Rent' ? _endDate : null,
          ),
        );
  }

  void _submit(OrderState state) {
    final missingDocuments = _requirements
        .where((requirement) => requirement.isRequired)
        .where((requirement) => !_documents.containsKey(requirement.keyName))
        .map((requirement) => requirement.title)
        .toList();
    if (missingDocuments.isNotEmpty) {
      _showMessage('dyn_please_upload'.tr(
        namedArgs: {'documents': missingDocuments.join(', ')},
      ));
      return;
    }
    if (state.availabilityStatus != OrderRequestStatus.success ||
        state.availability?.isAvailable != true) {
      _showMessage('ui_070'.tr());
      return;
    }

    final documents = _requirements
        .map((requirement) => _documents[requirement.keyName])
        .whereType<XFile>()
        .toList();
    final notes = _notesController.text.trim();
    final bloc = context.read<OrderBloc>();

    switch (_orderType) {
      case 'Rent':
        bloc.add(
          CreateRentOrderEvent(
            RentOrderRequest(
              carId: widget.car.carId,
              userNotes: notes,
              startDate: _startDate,
              endDate: _endDate,
              documents: documents,
            ),
          ),
        );
        break;
      case 'Installment':
        bloc.add(
          CreateInstallmentOrderEvent(
            InstallmentOrderRequest(
              carId: widget.car.carId,
              installmentMonths: _installmentMonths,
              notes: notes,
              documents: documents,
            ),
          ),
        );
        break;
      default:
        bloc.add(
          CreateBuyOrderEvent(
            BuyOrderRequest(
              carId: widget.car.carId,
              userNotes: notes,
              documents: documents,
            ),
          ),
        );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Color(0xFF222525),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _showSuccess(OrderState state) async {
    final viewOrders = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          width: 68.r,
          height: 68.r,
          decoration: BoxDecoration(
            color: Color(0xFF35C68B).withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: Color(0xFF35C68B),
            size: 38,
          ),
        ),
        title: Text('ui_179'.tr()),
        content: Text(
          state.operationResponse?.id == null
              ? state.message
              : 'dyn_order_created'.tr(namedArgs: {
                  'message': state.message,
                  'id': '${state.operationResponse!.id}',
                }),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('ui_104'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('ui_301'.tr()),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.read<OrderBloc>().add(ResetOrderFeedbackEvent());
    if (viewOrders == true) {
      Navigator.pushReplacementNamed(context, AppRoutes.myOrders);
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == OrderRequestStatus.success) {
          _showSuccess(state);
        } else if (state.submitStatus == OrderRequestStatus.failure) {
          _showMessage(state.errorMessage);
        }
      },
      builder: (context, state) {
        final isSubmitting = state.submitStatus == OrderRequestStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: Text('ui_224'.tr()),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CarHero(car: widget.car),
                  SizedBox(height: 18.h),
                  _sectionTitle('extra_026'.tr(), 'extra_094'.tr()),
                  SizedBox(height: 12.h),
                  Row(
                    children: ['Buy', 'Rent', 'Installment'].map((type) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: type == 'Installment' ? 0 : 8.w,
                          ),
                          child: _OrderTypeButton(
                            type: type,
                            isSelected: _orderType == type,
                            onTap: () => _changeOrderType(type),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                  if (_orderType == 'Rent') _buildRentDetails(),
                  if (_orderType == 'Installment') _buildInstallmentDetails(),
                  OrderSectionCard(
                    title: 'ui_314'.tr(),
                    icon: Icons.chat_bubble_outline_rounded,
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      minLines: 3,
                      decoration: _inputDecoration(
                        'extra_005'.tr(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildDocuments(),
                  SizedBox(height: 16.h),
                  _AvailabilityCard(
                    state: state,
                    onCheck: _checkAvailability,
                  ),
                  SizedBox(height: 16.h),
                  _buildSummary(),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 58.h,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : () => _submit(state),
                      child: isSubmitting
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'dyn_send_order'.tr(
                                    namedArgs: {'type': _orderType.localized},
                                  ),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Center(
                    child: Text('ui_317'.tr(),
                      style: TextStyle(color: Colors.white38, fontSize: 10.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRentDetails() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: OrderSectionCard(
        title: 'ui_219'.tr(),
        icon: Icons.date_range_rounded,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'ui_198'.tr(),
                    date: _startDate,
                    onTap: () => _selectDate(start: true),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white30,
                    size: 20.r,
                  ),
                ),
                Expanded(
                  child: _DateTile(
                    label: 'ui_225'.tr(),
                    date: _endDate,
                    onTap: () => _selectDate(start: false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.nights_stay_rounded,
                      color: AppColors.secondary, size: 19.r),
                  SizedBox(width: 9.w),
                  Text(
                    'dyn_rental_days'.tr(
                      namedArgs: {'count': '$_rentalDays'},
                    ),
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'dyn_per_day'.tr(
                      namedArgs: {
                        'amount':
                            '\$${(widget.car.rentPricePerDay ?? 0).toStringAsFixed(2)}',
                      },
                    ),
                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentDetails() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: OrderSectionCard(
        title: 'ui_132'.tr(),
        icon: Icons.payments_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ui_193'.tr(),
              style: TextStyle(color: Colors.white54, fontSize: 11.sp),
            ),
            SizedBox(height: 9.h),
            DropdownButtonFormField<int>(
              value: _installmentMonths,
              dropdownColor: Color(0xFF202222),
              decoration: _inputDecoration('extra_095'.tr()),
              items: [6, 12, 18, 24, 36, 48, 60]
                  .map(
                    (months) => DropdownMenuItem(
                      value: months,
                      child: Text(
                        'dyn_months'.tr(namedArgs: {'count': '$months'}),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _installmentMonths = value);
              },
            ),
            SizedBox(height: 11.h),
            Text(
              'dyn_payment_month'.tr(
                namedArgs: {
                  'amount':
                      '\$${(widget.car.price / _installmentMonths).toStringAsFixed(2)}',
                },
              ),
              style: TextStyle(color: AppColors.secondary, fontSize: 11.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocuments() {
    return OrderSectionCard(
      title: 'ui_222'.tr(),
      icon: Icons.folder_copy_rounded,
      child: Column(
        children: [
          Text('ui_284'.tr(),
            style: TextStyle(color: Colors.white54, fontSize: 10.sp, height: 1.5),
          ),
          SizedBox(height: 13.h),
          ..._requirements.map((requirement) {
            final file = _documents[requirement.keyName];
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _DocumentTile(
                requirement: requirement,
                file: file,
                onPick: () => _pickDocument(requirement),
                onRemove: file == null
                    ? null
                    : () => setState(
                          () => _documents.remove(requirement.keyName),
                        ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return OrderSectionCard(
      title: 'ui_181'.tr(),
      icon: Icons.receipt_rounded,
      child: Column(
        children: [
          OrderInfoRow(label: 'ui_059'.tr(), value: widget.car.model),
          OrderInfoRow(label: 'ui_182'.tr(), value: _orderType),
          if (_orderType == 'Rent')
            OrderInfoRow(label: 'ui_219'.tr(), value: '$_rentalDays days'),
          if (_orderType == 'Installment')
            OrderInfoRow(
              label: 'ui_193'.tr(),
              value: '$_installmentMonths months',
            ),
          OrderInfoRow(
            label: _orderType == 'Rent' ? 'extra_051'.tr() : 'Vehicle price',
            value: '\$${_estimatedTotal.toStringAsFixed(2)}',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white38, fontSize: 11.sp),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white30, fontSize: 12.sp),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.22),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.secondary),
      ),
    );
  }
}

class _CarHero extends StatelessWidget {
  final CarResponseModel car;

  _CarHero({required this.car});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageUrlHelper.getUrl(
      car.imageUrls.isEmpty ? '' : car.imageUrls.first,
    );
    return Container(
      height: 190.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.92)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 18.w,
              right: 18.w,
              bottom: 16.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.model,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${car.year}  •  ${car.gearType}  •  ${car.fuelType}',
                          style: TextStyle(color: Colors.white60, fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${car.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTypeButton extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  _OrderTypeButton({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.secondary.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(15.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          height: 78.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                orderTypeIcon(type),
                color: isSelected ? AppColors.secondary : Colors.white54,
                size: 23.r,
              ),
              SizedBox(height: 7.h),
              Text(
                type,
                style: TextStyle(
                  color: isSelected ? AppColors.secondary : Colors.white70,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(13.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white38, fontSize: 9.sp)),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: AppColors.secondary, size: 16.r),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      formatOrderDate(date),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentRequirement {
  final String keyName;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isRequired;

  _DocumentRequirement({
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isRequired = true,
  });
}

class _DocumentTile extends StatelessWidget {
  final _DocumentRequirement requirement;
  final XFile? file;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  _DocumentTile({
    required this.requirement,
    required this.file,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    return Material(
      color: hasFile
          ? Color(0xFF35C68B).withValues(alpha: 0.075)
          : Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(15.r),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: hasFile
                  ? Color(0x5535C68B)
                  : Colors.white.withValues(alpha: 0.07),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 43.r,
                height: 43.r,
                decoration: BoxDecoration(
                  color: hasFile
                      ? Color(0xFF35C68B).withValues(alpha: 0.13)
                      : AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: hasFile
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(file!.path),
                          fit: BoxFit.cover,
                          cacheWidth: 180,
                        ),
                      )
                    : Icon(requirement.icon,
                        color: AppColors.secondary, size: 20.r),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            requirement.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!requirement.isRequired)
                          Text(
                            '  ${'ui_163'.tr()}',
                            style: TextStyle(color: Colors.white30, fontSize: 8.sp),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hasFile ? _fileName(file!.path) : requirement.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasFile ? Color(0xFF35C68B) : Colors.white38,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.close_rounded, color: Colors.white54),
                )
              else
                Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.secondary, size: 22.r),
            ],
          ),
        ),
      ),
    );
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }
}

class _AvailabilityCard extends StatelessWidget {
  final OrderState state;
  final VoidCallback onCheck;

  _AvailabilityCard({required this.state, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.availabilityStatus == OrderRequestStatus.loading;
    final checked = state.availabilityStatus == OrderRequestStatus.success;
    final isAvailable = state.availability?.isAvailable == true;
    final color = checked
        ? (isAvailable ? Color(0xFF35C68B) : Color(0xFFFF5F6D))
        : AppColors.secondary;
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 43.r,
            height: 43.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? Padding(
                    padding: EdgeInsets.all(12.r),
                    child: CircularProgressIndicator(strokeWidth: 2, color: color),
                  )
                : Icon(
                    checked
                        ? (isAvailable
                            ? Icons.check_circle_rounded
                            : Icons.event_busy_rounded)
                        : Icons.verified_user_rounded,
                    color: color,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checked
                      ? (isAvailable ? 'extra_018'.tr() : 'extra_019'.tr())
                      : 'extra_011'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  checked
                      ? (isAvailable
                          ? 'extra_109'.tr()
                          : 'extra_022'.tr())
                      : 'extra_086'.tr(),
                  style: TextStyle(color: Colors.white54, fontSize: 9.sp),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: isLoading ? null : onCheck,
            child: Text(checked ? 'extra_024'.tr() : 'extra_023'.tr()),
          ),
        ],
      ),
    );
  }
}
