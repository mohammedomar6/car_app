import 'package:easy_localization/easy_localization.dart';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/core/routes/app_routes.dart';
import 'package:car_app/features/brand/data/models/brand_model.dart';
import 'package:car_app/features/brand/presentation/manager/brands_bloc.dart';
import 'package:car_app/features/brand/presentation/widgets/brand_action_menu.dart';
import 'package:car_app/features/brand/presentation/widgets/brand_dialog.dart';
import 'package:car_app/features/home/presentation/widgets/container_brand.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/image_helper.dart';
import '../../../../core/utils/secure_storage.dart';

class BrandsPage extends StatefulWidget {
  BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  // ============================================================
  // CHECK ROLE
  // ============================================================

  Future<void> _checkRole() async {
    final role = await SecureStorageService.getRole();

    if (!mounted) return;

    setState(() {
      isAdmin = role?.toLowerCase() == 'admin';
    });
  }

  // ============================================================
  // ADD BRAND
  // ============================================================

  void _openAddBrandDialog() {
    showDialog(
      context: context,
      builder: (_) => BrandDialog(),
    );
  }

  // ============================================================
  // EDIT BRAND
  // ============================================================

  void _openEditBrandDialog(BrandModel brand) {
    showDialog(
      context: context,
      builder: (_) => BrandDialog(
        brandId: brand.brandId,
        brandName: brand.name,
        brandImage: brand.brandLogoUrl,
      ),
    );
  }

  // ============================================================
  // DELETE BRAND
  // ============================================================

  void _showDeleteDialog(BrandModel brand) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('ui_096'.tr()),
          content: Text(
            style: TextStyle(color:AppColors.textAuth ),
            'Are you sure you want to delete "${brand.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('ui_055'.tr()),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BrandsBloc>().add(
                  DeleteBrandEvent(
                    brandId: brand.brandId!,
                  ),
                );

                Navigator.pop(dialogContext);
              },
              child: Text('ui_094'.tr()),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<BrandsBloc, BrandsState>(
      listener: _handleBlocState,
      child: Scaffold(
        floatingActionButton: isAdmin
            ? FloatingActionButton(
          onPressed: _openAddBrandDialog,
          child: Icon(Icons.add),
        )
            : null,
        body: Padding(
          padding: EdgeInsets.only(
            top: 50.h,
            left: 20.w,
            right: 20.w,
          ),
          child: CustomScrollView(
            slivers: [
              _buildHeader(),

              SliverToBoxAdapter(
                child: SizedBox(height: 30.h),
              ),

              _buildBrands(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BLOC LISTENER
  // ============================================================

  void _handleBlocState(
      BuildContext context,
      BrandsState state,
      ) {
    if (state is DeleteBrandSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ui_051'.tr()),
        ),
      );
    }

    if (state is DeleteBrandError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.massage),
        ),
      );
    }
  }

  // ============================================================
  // HEADER
  // ============================================================

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.brands,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(
              color: AppColors.backgroundLight,
              fontSize: 24.sp,
            ),
          ),

          SizedBox(height: 10.h),

          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text(
              AppStrings.subtitleBrand,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: AppColors.textAuth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BRANDS
  // ============================================================

  Widget _buildBrands() {
    return BlocBuilder<BrandsBloc, BrandsState>(
      builder: (context, state) {
        if (state is GetAllBrandsLoading) {
          return SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is GetAllBrandsError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(state.massage),
            ),
          );
        }

        if (state is GetAllBrandsSuccess) {
          if (state.brands.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Text('ui_155'.tr()),
              ),
            );
          }

          return SliverGrid.builder(
            itemCount: state.brands.length,
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20.r,
              crossAxisSpacing: 10.r,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return _buildBrandItem(
                state.brands[index],
              );
            },
          );
        }

        return SliverToBoxAdapter(
          child: SizedBox.shrink(),
        );
      },
    );
  }

  // ============================================================
  // BRAND ITEM
  // ============================================================

  Widget _buildBrandItem(brand) {
    return Stack(
      children: [
        ContainerBrand(
          image: brand.brandLogoUrl != null &&
              brand.brandLogoUrl!.isNotEmpty
              ? ImageUrlHelper.getUrl(
            brand.brandLogoUrl!,
          )
              : '',
          text: brand.name,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.cars,
              arguments: brand.brandId,
            );
          },
        ),

        if (isAdmin)
          BrandActionMenu(
            onEdit: () {
              _openEditBrandDialog(brand);
            },
            onDelete: () {
              _showDeleteDialog(brand);
            },
          ),
      ],
    );
  }
}
