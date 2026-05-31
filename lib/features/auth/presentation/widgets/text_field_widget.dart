import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constant/app_colors.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    required this.label,
    required this.type,
    required this.hint,
    required this.icon,
    required this.isPassword,
    required this.controller,
    required this.validator
  });

  final String label;
  final TextInputType type;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: 10.h),
        Container(
          margin: EdgeInsets.only(bottom: 15.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            border: Border(bottom: BorderSide(color: AppColors.textFieldFont)),
          ),
          height: 80.h,
          width: double.infinity,
          child: TextFormField(
            controller: widget.controller,
autovalidateMode:AutovalidateMode.disabled ,
            validator: widget.validator,
            obscureText: widget.isPassword ? obscureText : false,
            keyboardType: widget.type,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 20.h),
              suffixIcon:
                  widget.isPassword
                      ? IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                      )
                      : null,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,

              hintText: widget.hint,

              prefixIcon: Icon(widget.icon),
            ),
            style: Theme.of(context).textTheme.bodySmall,
            showCursor: true,
          ),
        ),
      ],
    );
  }
}
