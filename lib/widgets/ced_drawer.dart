import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cedmate/widgets/CEDColors.dart';

class CEDDrawer extends StatelessWidget {
  const CEDDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CEDColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(context, 'Dashboard', Icons.home, () {
                    Navigator.pushNamed(context, '/home');
                  }),
                  _drawerItem(context, 'Mein Profil', Icons.person, () {
                    Navigator.pushNamed(context, '/profil');
                  }),
                  _drawerItem(context, 'Rückblick', Icons.history_edu, () {
                    Navigator.pushNamed(context, '/rueckblick');
                  }),
                  _drawerItem(context, 'Toiletten finden', Icons.map, () {
                    Navigator.pushNamed(context, '/hilfeUnterwegs');
                  }),
                  _drawerItem(
                    context,
                    'Daten exportieren',
                    Icons.import_export,
                    () {
                      Navigator.pushNamed(context, '/export');
                    },
                  ),
                  _drawerItem(context, 'Kalender', Icons.calendar_month, () {
                    Navigator.pushNamed(context, '/kalender');
                  }),
                  _drawerItem(context, 'Statistiken', Icons.bar_chart, () {
                    Navigator.pushNamed(context, '/statistiken');
                  }),
                  _drawerItem(context, 'Impressum & Credits', Icons.info, () {
                    Navigator.pushNamed(context, '/credits');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: CEDColors.surface,
      child: Row(
        children: [
          Icon(Icons.analytics, size: 40, color: CEDColors.iconPrimary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CEDmate',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: CEDColors.iconPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Erfassen. Verstehen. Verbessern.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: CEDColors.iconSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- ITEM ----------------

  Widget _drawerItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CEDColors.background.withValues(alpha: 0.65),
            CEDColors.background.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: BoxBorder.all(color: CEDColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: CEDColors.iconPrimary),
        title: Text(title, style: TextStyle(color: CEDColors.textPrimary)),
        horizontalTitleGap: 12,
        onTap: () {
          Navigator.pop(context); // Close the drawer
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedTileColor: CEDColors.surface,
      ),
    );
  }
}
