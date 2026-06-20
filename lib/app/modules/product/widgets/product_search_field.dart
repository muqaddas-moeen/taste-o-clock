import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_o_clock/app/core/utils/input_validators.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_decorations.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class ProductSearchField extends StatefulWidget {
  const ProductSearchField({
    super.key,
    this.initialQuery = '',
    required this.onChanged,
    required this.onClear,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<ProductSearchField> createState() => _ProductSearchFieldState();
}

class _ProductSearchFieldState extends State<ProductSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.searchField(),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        maxLength: InputValidators.maxSearchLength,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
            null,
        decoration: InputDecoration(
          hintText: 'Search dishes, cravings...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.kPrimary.withValues(alpha: 0.85),
            size: 22.sp,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: _handleClear,
                icon: Icon(Icons.close_rounded, size: 20.sp),
                color: AppColors.kTextMuted,
              );
            },
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
        ),
        style: AppFontStyle.kMulishTextStyle(
          fontSize: 15,
          c: AppColors.kTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
