import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/helper/image_helper.dart';
import 'package:car_app/features/cars/presentation/widgets/car_form_field.dart';
import 'package:car_app/features/orders/data/models/order_model.dart';
import 'package:car_app/features/transactions/data/models/transaction_model.dart';
import 'package:car_app/features/transactions/data/models/transaction_request.dart';
import 'package:car_app/features/transactions/presentation/manager/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class TransactionFormScreen extends StatefulWidget {
  final OrderModel? order;
  final TransactionModel? transaction;

  TransactionFormScreen({
    super.key,
    this.order,
    this.transaction,
  });

  bool get isEdit => transaction != null;

  @override
  State<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  static const _types = [
    'Deposit',
    'FullPayment',
    'InstallmentPayment',
  ];
  static const _statuses = ['Completed', 'Pending', 'Refunded', 'Failed'];
  static const _paymentSuggestions = [
    'Cash',
    'Bank Transfer',
    'Card',
    'Cheque',
  ];

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _newImages = <File>[];
  late final TextEditingController _orderController;
  late final TextEditingController _amountController;
  late final TextEditingController _paymentController;
  late final TextEditingController _referenceController;
  late final TextEditingController _notesController;
  late String _type;
  late String _status;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    final order = widget.order;
    _orderController = TextEditingController(
      text: '${transaction?.orderId ?? order?.orderId ?? ''}',
    );
    _amountController = TextEditingController(
      text: _numberText(transaction?.amount ?? order?.totalPrice),
    );
    _paymentController = TextEditingController(
      text: transaction?.paymentMethod ?? '',
    );
    _referenceController = TextEditingController(
      text: transaction?.referenceNumber ?? '',
    );
    _notesController = TextEditingController(text: transaction?.notes ?? '');
    _type = _resolveType(transaction, order);
    _status = _statuses.contains(transaction?.status)
        ? transaction!.status
        : 'Completed';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(
            ResetTransactionFeedbackEvent(),
          );
    });
  }

  @override
  void dispose() {
    _orderController.dispose();
    _amountController.dispose();
    _paymentController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _resolveType(TransactionModel? transaction, OrderModel? order) {
    if (_types.contains(transaction?.transactionType)) {
      return transaction!.transactionType;
    }
    if (order?.orderType.toLowerCase() == 'installment') {
      return 'InstallmentPayment';
    }
    return 'FullPayment';
  }

  String _numberText(double? value) {
    if (value == null || value == 0) return '';
    return value == value.roundToDouble() ? '${value.toInt()}' : '$value';
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 88);
    if (picked.isEmpty || !mounted) return;
    final supported = picked
        .where((image) => _isSupportedContractImage(image.path))
        .toList();
    if (supported.isEmpty) {
      _showSnack(
        'ui_282'.tr(),
        isError: true,
      );
      return;
    }
    setState(() {
      final existingPaths = _newImages.map((file) => file.path).toSet();
      for (final image in supported) {
        if (existingPaths.add(image.path)) _newImages.add(File(image.path));
      }
    });
    if (supported.length != picked.length) {
      _showSnack(
        'ui_242'.tr(),
        isError: true,
      );
    }
  }

  bool _isSupportedContractImage(String path) {
    final normalizedPath = path.trim().toLowerCase();
    return normalizedPath.endsWith('.jpg') ||
        normalizedPath.endsWith('.jpeg') ||
        normalizedPath.endsWith('.png') ||
        normalizedPath.endsWith('.webp');
  }

  bool _validateDetails() {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    return true;
  }

  void _next() {
    if (_step == 0 && !_validateDetails()) return;
    FocusScope.of(context).unfocus();
    if (_step < 2) setState(() => _step++);
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) setState(() => _step--);
  }

  void _submit() {
    if (!_validateDetails()) {
      setState(() => _step = 0);
      return;
    }
    final request = TransactionRequest(
      orderId: int.parse(_orderController.text.trim()),
      amount: double.parse(_amountController.text.trim()),
      paymentMethod: _paymentController.text,
      transactionType: _type,
      status: _status,
      referenceNumber: _referenceController.text,
      notes: _notesController.text,
      contractImages: List<File>.from(_newImages),
    );
    if (widget.isEdit) {
      context.read<TransactionBloc>().add(
            UpdateTransactionEvent(
              transactionId: widget.transaction!.transactionId,
              request: request,
            ),
          );
    } else {
      context.read<TransactionBloc>().add(CreateTransactionEvent(request));
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              isError ? Color(0xFF8B3038) : Color(0xFF176B50),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus,
      listener: (context, state) {
        if (state.submitStatus == TransactionRequestStatus.success) {
          _showSnack(state.message);
          Navigator.pop(context, true);
        } else if (state.submitStatus == TransactionRequestStatus.failure) {
          _showSnack(state.errorMessage, isError: true);
        }
      },
      builder: (context, state) {
        final submitting =
            state.submitStatus == TransactionRequestStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isEdit ? 'Edit transaction' : 'Create contract'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _FormHero(isEdit: widget.isEdit),
                _StepProgress(currentStep: _step),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: IndexedStack(
                      index: _step,
                      children: [
                        _buildDetailsStep(),
                        _buildContractStep(),
                        _buildReviewStep(),
                      ],
                    ),
                  ),
                ),
                _buildNavigation(submitting),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 22.h),
      child: Column(
        children: [
          _FormSection(
            title: 'ui_172'.tr(),
            icon: Icons.receipt_long_rounded,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CarFormField(
                        controller: _orderController,
                        readOnly: widget.order != null || widget.isEdit,
                        keyboardType: TextInputType.number,
                        label: 'ui_173'.tr(),
                        hint: 'ui_173'.tr(),
                        icon: Icons.tag_rounded,
                        validator: (value) {
                          final id = int.tryParse(value?.trim() ?? '');
                          return id == null || id <= 0
                              ? 'extra_040'.tr()
                              : null;
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CarFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        label: 'ui_022'.tr(),
                        hint: 'ui_022'.tr(),
                        icon: Icons.attach_money_rounded,
                        prefixText: '\$ ',
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          return amount == null || amount <= 0
                              ? 'extra_038'.tr()
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CarFormField(
                  controller: _paymentController,
                  textCapitalization: TextCapitalization.words,
                  label: 'ui_192'.tr(),
                  hint: 'ui_066'.tr(),
                  icon: Icons.payments_rounded,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'extra_069'.tr()
                      : null,
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 7.w,
                    runSpacing: 7.h,
                    children: _paymentSuggestions.map((method) {
                      final selected = _paymentController.text
                              .trim()
                              .toLowerCase() ==
                          method.toLowerCase();
                      return ChoiceChip(
                        label: Text(method.localized),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() => _paymentController.text = method);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _FormSection(
            title: 'ui_271'.tr(),
            icon: Icons.tune_rounded,
            child: Column(
              children: [
                CarDropdownField<String>(
                  value: _type,
                  label: 'ui_273'.tr(),
                  icon: Icons.account_balance_wallet_rounded,
                  items: _types
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(_typeLabel(item)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _type = value ?? _type),
                ),
                SizedBox(height: 12.h),
                CarDropdownField<String>(
                  value: _status,
                  label: 'ui_272'.tr(),
                  icon: Icons.fact_check_rounded,
                  items: _statuses
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.localized),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _status = value ?? _status),
                ),
                SizedBox(height: 12.h),
                CarFormField(
                  controller: _referenceController,
                  label: 'ui_209'.tr(),
                  hint: 'ui_206'.tr(),
                  icon: Icons.numbers_rounded,
                ),
                SizedBox(height: 12.h),
                CarFormField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 800,
                  label: 'ui_167'.tr(),
                  hint: 'ui_167'.tr(),
                  icon: Icons.notes_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractStep() {
    final existing = widget.transaction?.contractImages ?? [];
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 22.h),
      child: _FormSection(
        title: 'ui_076'.tr(),
        icon: Icons.image_rounded,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                widget.isEdit
                    ? 'extra_052'.tr()
                    : 'extra_010'.tr(),
                style: TextStyle(color: Colors.white60, fontSize: 10.sp),
              ),
            ),
            if (existing.isNotEmpty) ...[
              SizedBox(height: 14.h),
              _ImageGrid(
                count: existing.length,
                itemBuilder: (index) => Image.network(
                  ImageUrlHelper.getUrl(existing[index].imageUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ImageFallback(),
                ),
              ),
            ],
            if (_newImages.isNotEmpty) ...[
              SizedBox(height: 14.h),
              _ImageGrid(
                count: _newImages.length,
                itemBuilder: (index) => Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_newImages[index], fit: BoxFit.cover),
                    Positioned(
                      top: 5.h,
                      right: 5.w,
                      child: IconButton.filled(
                        onPressed: () =>
                            setState(() => _newImages.removeAt(index)),
                        style: IconButton.styleFrom(
                          backgroundColor: Color(0xCC8B3038),
                        ),
                        icon: Icon(Icons.close_rounded, size: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.add_photo_alternate_rounded),
                label: Text(
                  _newImages.isEmpty
                      ? 'extra_093'.tr()
                      : 'Add more images (${_newImages.length})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 22.h),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(19.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.22),
                  Color(0xFF151717),
                ],
              ),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.secondary,
                  size: 44.r,
                ),
                SizedBox(height: 10.h),
                Text(
                  widget.isEdit ? 'extra_089'.tr() : 'extra_082'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  widget.isEdit
                      ? 'Verify the transaction information before saving.'
                      : 'extra_035'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 13.h),
          _FormSection(
            title: 'ui_121'.tr(),
            icon: Icons.summarize_rounded,
            child: Column(
              children: [
                _ReviewRow(label: 'ui_171'.tr(), value: '#${_orderController.text}'),
                _ReviewRow(
                  label: 'ui_022'.tr(),
                  value: '\$${_amountController.text}',
                ),
                _ReviewRow(
                  label: 'ui_187'.tr(),
                  value: _paymentController.text,
                ),
                _ReviewRow(label: 'ui_280'.tr(), value: _typeLabel(_type)),
                _ReviewRow(label: 'ui_243'.tr(), value: _status.localized),
                _ReviewRow(
                  label: 'ui_077'.tr(),
                  value:
                      '${(widget.transaction?.contractImages.length ?? 0) + _newImages.length}',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(bool submitting) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Color(0xFF141616),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: submitting ? null : _back,
                child: Text('ui_045'.tr()),
              ),
            ),
          if (_step > 0) SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: submitting
                  ? null
                  : (_step == 2 ? _submit : _next),
              icon: submitting
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _step == 2
                          ? Icons.verified_rounded
                          : Icons.arrow_forward_rounded,
                    ),
              label: Text(
                submitting
                    ? 'extra_092'.tr()
                    : (_step == 2
                        ? (widget.isEdit ? 'extra_091'.tr() : 'Create contract')
                        : 'extra_031'.tr()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormHero extends StatelessWidget {
  final bool isEdit;

  _FormHero({required this.isEdit});

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                isEdit ? Icons.edit_note_rounded : Icons.handshake_rounded,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Update the official record' : 'Create a secure deal record',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text('ui_190'.tr(),
                    style: TextStyle(color: Colors.white54, fontSize: 9.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _StepProgress extends StatelessWidget {
  final int currentStep;

  _StepProgress({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = ['ui_187'.tr(), 'extra_032'.tr(), 'extra_088'.tr()];
    return Padding(
      padding: EdgeInsets.fromLTRB(25.w, 4.h, 25.w, 12.h),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (index) {
          if (index.isOdd) {
            final active = currentStep >= (index + 1) ~/ 2;
            return Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                height: 2.h,
                color: active ? AppColors.secondary : Colors.white12,
              ),
            );
          }
          final step = index ~/ 2;
          final active = currentStep >= step;
          return Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 250),
                width: 29.r,
                height: 29.r,
                decoration: BoxDecoration(
                  color: active ? AppColors.secondary : Colors.white10,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${step + 1}',
                  style: TextStyle(
                    color: active ? Colors.black : Colors.white38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                labels[step],
                style: TextStyle(
                  color: active ? Colors.white : Colors.white38,
                  fontSize: 8.sp,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.secondary, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            child,
          ],
        ),
      );
}

class _ImageGrid extends StatelessWidget {
  final int count;
  final Widget Function(int index) itemBuilder;

  _ImageGrid({required this.count, required this.itemBuilder});

  @override
  Widget build(BuildContext context) => GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9.w,
          mainAxisSpacing: 9.h,
          childAspectRatio: 1.22,
        ),
        itemCount: count,
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: itemBuilder(index),
        ),
      );
}

class _ImageFallback extends StatelessWidget {
  _ImageFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white.withValues(alpha: 0.05),
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined, color: Colors.white24),
      );
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  _ReviewRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 11.h),
        margin: EdgeInsets.only(bottom: isLast ? 0 : 11.h),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
            Spacer(),
            Flexible(
              child: Text(
                value.trim().isEmpty ? '—' : value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}

String _typeLabel(String value) {
  return value.localized;
}
