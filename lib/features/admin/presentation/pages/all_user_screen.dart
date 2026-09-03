import 'dart:ui';

import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/localization/localized_value.dart';
import 'package:car_app/core/utils/whatsapp_launcher.dart';
import 'package:car_app/features/admin/presentation/manager/users/users_bloc.dart';
import 'package:car_app/features/auth/presentation/widgets/elevated_button_widget.dart';
import 'package:car_app/features/profile/data/models/profile_response_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllUserScreen extends StatefulWidget {
  const AllUserScreen({super.key});

  @override
  State<AllUserScreen> createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(GetAllUser());
  }

  Future<void> _showDeleteDialog(int userId) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<UsersBloc>(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: BlocBuilder<UsersBloc, UsersState>(
            builder: (context, state) {
              final deleting = state.deleteStatus == UsersStatus.loading;
              return AlertDialog(
                icon: Icon(
                  Icons.person_remove_rounded,
                  color: const Color(0xFFFF6B76),
                  size: 36.r,
                ),
                title: Text('ui_303'.tr()),
                content: deleting
                    ? SizedBox(
                        height: 70.h,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : Text(
                        'ui_036'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: deleting
                    ? const []
                    : [
                        ElevatedButtonWidget(
                          width: 92.w,
                          height: 45.h,
                          onPressed: () => context.read<UsersBloc>().add(
                                DeleteUserEvent(userId: userId),
                              ),
                          label: 'ui_308'.tr(),
                        ),
                        ElevatedButtonWidget(
                          width: 92.w,
                          height: 45.h,
                          onPressed: () => Navigator.pop(dialogContext),
                          label: 'ui_153'.tr(),
                        ),
                      ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showUserDetails(ProfileResponseModel user) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF171919),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (sheetContext) => _UserDetailsSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () async {
          final bloc = context.read<UsersBloc>()..add(GetAllUser());
          await bloc.stream.firstWhere(
            (state) => state.status != UsersStatus.loading,
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text('ui_289'.tr()),
            ),
            BlocConsumer<UsersBloc, UsersState>(
              listener: (context, state) {
                if (state.deleteStatus == UsersStatus.success) {
                  if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.massageModel?.message ?? 'ui_287'.tr(),
                      ),
                    ),
                  );
                }
                if (state.deleteStatus == UsersStatus.failure) {
                  if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: const Color(0xFF8B3038),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == UsersStatus.loading && state.users.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state.status == UsersStatus.failure && state.users.isEmpty) {
                  return SliverFillRemaining(
                    child: _UsersMessage(
                      icon: Icons.cloud_off_rounded,
                      title: state.message.replaceFirst('Exception: ', ''),
                      subtitle: '',
                    ),
                  );
                }

                final users = state.users
                    .where((user) => user.role?.toLowerCase() == 'user')
                    .toList();
                if (users.isEmpty) {
                  return SliverFillRemaining(
                    child: _UsersMessage(
                      icon: Icons.group_off_rounded,
                      title: 'app_no_users'.tr(),
                      subtitle: 'app_no_users_hint'.tr(),
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 28.h),
                  sliver: SliverList.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => SizedBox(height: 11.h),
                    itemBuilder: (context, index) => _UserCard(
                      user: users[index],
                      onTap: () => _showUserDetails(users[index]),
                      onDelete: users[index].userId == null
                          ? null
                          : () => _showDeleteDialog(users[index].userId!),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final ProfileResponseModel user;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Ink(
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.045),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.secondary,
                    size: 30.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayValue(user.fullName, 'app_unknown_user'.tr()),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        _displayValue(user.email),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                      ),
                      SizedBox(height: 7.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 5.h,
                        children: [
                          _MiniBadge(
                            icon: Icons.tag_rounded,
                            text: '${user.userId ?? '—'}',
                          ),
                          _MiniBadge(
                            icon: Icons.badge_outlined,
                            text: _displayValue(user.role).localized,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'ui_096'.tr(),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFFFF6B76),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 15),
              ],
            ),
          ),
        ),
      );
}

class _UserDetailsSheet extends StatelessWidget {
  final ProfileResponseModel user;

  const _UserDetailsSheet({required this.user});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
        child: Column(
          children: [
            Container(
              width: 46.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
            SizedBox(height: 22.h),
            Container(
              width: 76.r,
              height: 76.r,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppColors.secondary,
                size: 42.r,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              _displayValue(user.fullName, 'app_unknown_user'.tr()),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'dyn_user_number'.tr(namedArgs: {'id': '${user.userId ?? '—'}'}),
              style: TextStyle(color: Colors.white54, fontSize: 11.sp),
            ),
            SizedBox(height: 22.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'app_contact_details'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'ui_125'.tr(),
                    value: user.fullName,
                  ),
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: 'ui_113'.tr(),
                    value: user.email,
                  ),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'ui_013'.tr(),
                    value: user.address,
                  ),
                  _DetailRow(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'app_role'.tr(),
                    value: _displayValue(user.role).localized,
                  ),
                  _DetailRow(
                    icon: Icons.numbers_rounded,
                    label: 'ui_286'.tr(),
                    value: '${user.userId ?? '—'}',
                  ),
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: 'ui_196'.tr(),
                    value: user.phone,
                    isLast: true,
                    actionIcon: Icons.chat_rounded,
                    actionColor: const Color(0xFF25D366),
                    onTap: () => openWhatsAppChat(context, user.phone),
                  ),
                ],
              ),
            ),
            SizedBox(height: 11.h),
            Text(
              'app_whatsapp_hint'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 9.sp),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.black,
                ),
                onPressed: () => openWhatsAppChat(context, user.phone),
                icon: const Icon(Icons.chat_rounded),
                label: Text('app_open_whatsapp'.tr()),
              ),
            ),
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isLast;
  final IconData? actionIcon;
  final Color? actionColor;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
    this.actionIcon,
    this.actionColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 13.h),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.secondary, size: 20.r),
              SizedBox(width: 10.w),
              SizedBox(
                width: 78.w,
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                ),
              ),
              Expanded(
                child: Text(
                  _displayValue(value),
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.white, fontSize: 11.sp),
                ),
              ),
              if (actionIcon != null) ...[
                SizedBox(width: 8.w),
                Icon(actionIcon, color: actionColor, size: 21.r),
              ],
            ],
          ),
        ),
      );
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.secondary, size: 12.r),
            SizedBox(width: 4.w),
            Text(
              text,
              style: TextStyle(color: Colors.white70, fontSize: 8.sp),
            ),
          ],
        ),
      );
}

class _UsersMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _UsersMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.all(30.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.secondary, size: 52.r),
              SizedBox(height: 14.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                ),
              ],
            ],
          ),
        ),
      );
}

String _displayValue(String? value, [String fallback = '—']) {
  final trimmed = (value ?? '').trim();
  return trimmed.isEmpty ? fallback : trimmed;
}
