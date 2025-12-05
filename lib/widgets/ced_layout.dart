import 'package:cedmate/widgets/ced_drawer.dart';
import 'package:flutter/material.dart';
import 'package:cedmate/widgets/c_e_d_colors.dart';

class CEDLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showDrawer;

  const CEDLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: showDrawer == true ? const CEDDrawer() : null,

      appBar: AppBar(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        backgroundColor: CEDColors.surface,
        foregroundColor: CEDColors.textPrimary,
        elevation: 0,
        actions: actions,
      ),

      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CEDColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CEDColors.border, width: 1),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
