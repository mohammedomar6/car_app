import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsAppChat(BuildContext context, String? phone) async {
  final digits = _normalizePhone(phone);
  if (digits.isEmpty) {
    _showWhatsAppMessage(context, 'app_phone_unavailable'.tr());
    return;
  }

  final uri = Uri.https('wa.me', '/$digits');
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      _showWhatsAppMessage(context, 'app_whatsapp_unavailable'.tr());
    }
  } catch (_) {
    if (context.mounted) {
      _showWhatsAppMessage(context, 'app_whatsapp_unavailable'.tr());
    }
  }
}

String _normalizePhone(String? phone) {
  var digits = (phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  return digits;
}

void _showWhatsAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
