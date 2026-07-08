import 'dart:io';
import 'dart:ui';
import 'package:car_app/core/constant/app_colors.dart';
import 'package:car_app/core/constant/app_strings.dart';
import 'package:car_app/features/auth/presentation/widgets/elevated_button_widget.dart';
import 'package:car_app/features/auth/presentation/widgets/text_field_widget.dart';
import 'package:car_app/features/brand/data/models/brand_model.dart';
import 'package:car_app/features/brand/data/models/brand_request_model.dart';
import 'package:car_app/features/brand/presentation/manager/brands_bloc.dart';
import 'package:car_app/features/home/presentation/widgets/container_brand.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constant/app_image.dart';
class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  TextEditingController brandController = TextEditingController();

  final List<String> cars = [
    AppImage.lamborghini,
    AppImage.ferrari,
    AppImage.porsche,
    AppImage.bmw,
  ];

  ImagePicker pick = ImagePicker();

  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          brandController.clear();
          image = null;
          showDialog(
            barrierColor: Colors.black26,
            context: context,
            builder: (context) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return BlocListener<BrandsBloc, BrandsState>(
                      listener: (context, state) {
                        if (state is AddBrandSuccess) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.addBrandModel.message!),
                            ),
                          );
                        } else if (state is AddBrandError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.massage)),
                          );
                        }
                      },
                      child: Form(
                        child: AlertDialog(
                          title: Text('Add New Brand'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFieldWidget(
                                  label: 'Brand Name',
                                  type: TextInputType.text,
                                  hint: 'Bmw , Odie',
                                  icon: Icons.car_crash,
                                  isPassword: false,
                                  controller: brandController,
                                  validator: (p0) {
                                    if (p0!.isEmpty) {
                                      return "Enter Brand ";
                                    }
                                    return null;
                                  },
                                  color: AppColors.darkGrey,
                                ),
                                DottedBorder(
                                  options: RectDottedBorderOptions(
                                    color: AppColors.textAuth,
                                    dashPattern: [3, 6],
                                  ),
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await pick.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          image = File(picked.path);
                                        });
                                      }
                                    },
                                    child:
                                        image == null
                                            ? Container(
                                              width: 250.w,
                                              height: 150.h,
                                              decoration: BoxDecoration(
                                                color: AppColors.darkGrey,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons.upload,
                                                    color: AppColors.textAuth,
                                                    size: 35.r,
                                                  ),
                                                  Text(
                                                    textAlign: TextAlign.center,
                                                    'DRAG & DROP LOGO ASSET OR BROWSE',
                                                    style:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .displayLarge,
                                                  ),
                                                ],
                                              ),
                                            )
                                            : Container(
                                              width: 250,
                                              height: 200,
                                              color: AppColors.darkGrey,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Stack(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  children: [
                                                    Image.file(
                                                      image!,

                                                      fit: BoxFit.cover,
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      left: 10,
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            image = null;
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.cancel,
                                                          color:
                                                              AppColors
                                                                  .secondary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                ElevatedButtonWidget(
                                  width: 250.w,
                                  height: 70.h,
                                  onPressed: () {
                                    context.read<BrandsBloc>().add(
                                      AddBrandEvent(
                                        brandModel: BrandRequestModel(
                                          brandName: brandController.text,
                                          imageFile: image!,
                                        ),
                                      ),
                                    );
                                  },
                                  label: 'Add Brand',
                                  icon: Icons.add,
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: 250.w,
                                  height: 70.h,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 50.h, left: 20.w, right: 20.w),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Text(
                AppStrings.brands,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.backgroundLight,
                  fontSize: 24.sp,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 10.h, left: 10),
                child: Text(
                  AppStrings.subtitleBrand,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textAuth),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 30.h)),
            BlocBuilder<BrandsBloc, BrandsState>(
              builder: (context, state) {
                if (state is GetAllBrandsError) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text(state.massage)),
                  );
                } else if (state is GetAllBrandsLoading) {
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is GetAllBrandsSuccess) {
                  return SliverGrid.builder(
                    itemCount: state.brands.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 10.r,
                      crossAxisSpacing: 10.r,
                      childAspectRatio: 0.9,
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return ContainerBrand(
                        image: state.brands[index].brandLogoUrl!,
                        text: state.brands[index].name,
                        onTap: () {
                          Navigator.pushNamed(context, '/cars_page', arguments: state.brands[index].brandId);
                        },

                      );
                    },
                  );
                } else {
                  return SliverToBoxAdapter(child: SizedBox.shrink());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
