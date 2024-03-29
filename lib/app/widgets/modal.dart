import 'package:free_wifi/app/core/theme/color_theme.dart';
import 'package:flutter/material.dart';

class FGBPDialog extends StatelessWidget {
  const FGBPDialog(
      {Key? key, required this.child, this.borderColor = AppColorTheme.white})
      : super(key: key);

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 2,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColorTheme.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    );
  }
}

class CustomFGBPDialog extends StatelessWidget {
  const CustomFGBPDialog(
      {Key? key,
      required this.title,
      required this.content,
      this.actions,
      this.borderColor = AppColorTheme.white})
      : super(key: key);

  final Widget title;
  final Widget content;
  final List<Widget>? actions;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return FGBPDialog(
      borderColor: borderColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            title,
            const SizedBox(height: 8),
            content,
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions ?? [],
            )
          ],
        ),
      ),
    );
  }
}

class FGBPSimpleDialog extends StatelessWidget {
  const FGBPSimpleDialog(
      {Key? key,
      required this.title,
      required this.content,
      this.borderColor = AppColorTheme.white})
      : super(key: key);

  final String title;
  final String content;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomFGBPDialog(
      borderColor: borderColor,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
