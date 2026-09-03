import 'package:easy_localization/easy_localization.dart';

extension LocalizedValue on String {
  String get localized {
    switch (trim().toLowerCase()) {
      case 'all':
        return 'value_all'.tr();
      case 'pending':
        return 'value_pending'.tr();
      case 'approved':
        return 'value_approved'.tr();
      case 'rejected':
        return 'value_rejected'.tr();
      case 'completed':
        return 'value_completed'.tr();
      case 'canceled':
      case 'cancelled':
        return 'value_canceled'.tr();
      case 'available':
        return 'value_available'.tr();
      case 'rented':
        return 'value_rented'.tr();
      case 'sold':
        return 'value_sold'.tr();
      case 'for sale':
        return 'value_for_sale'.tr();
      case 'for rent':
        return 'value_for_rent'.tr();
      case 'buy':
        return 'value_buy'.tr();
      case 'rent':
        return 'value_rent'.tr();
      case 'installment':
        return 'value_installment'.tr();
      case 'deposit':
        return 'value_deposit'.tr();
      case 'fullpayment':
        return 'value_full_payment'.tr();
      case 'installmentpayment':
        return 'value_installment_payment'.tr();
      case 'refunded':
        return 'value_refunded'.tr();
      case 'failed':
        return 'value_failed'.tr();
      case 'petrol':
      case 'gasoline':
        return 'value_petrol'.tr();
      case 'diesel':
        return 'value_diesel'.tr();
      case 'electric':
        return 'value_electric'.tr();
      case 'hybrid':
        return 'value_hybrid'.tr();
      case 'automatic':
        return 'value_automatic'.tr();
      case 'manual':
        return 'value_manual'.tr();
      case 'black':
        return 'value_black'.tr();
      case 'tan':
        return 'value_tan'.tr();
      case 'cash':
        return 'value_cash'.tr();
      case 'bank transfer':
        return 'value_bank_transfer'.tr();
      case 'card':
        return 'value_card'.tr();
      case 'cheque':
      case 'check':
        return 'value_cheque'.tr();
      case 'user':
        return 'value_user'.tr();
      case 'admin':
        return 'value_admin'.tr();
      default:
        return this;
    }
  }
}
