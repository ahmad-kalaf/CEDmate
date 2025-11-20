import 'package:flutter/material.dart';
import 'package:cedmate/widgets/CEDColors.dart';

class CEDLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const CEDLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),

      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
                border: Border.all(
                  color: CEDColors.border,
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Drawer
  // ---------------------------------------------------------------------------
  Widget _buildDrawer(BuildContext context) {
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
                  _drawerItem(context, 'Mein Profil', Icons.person, () {
                    Navigator.pushNamed(context, '/profil');
                  }),
                  _drawerItem(context, 'Symptom-Radar', Icons.show_chart, () {
                    Navigator.pushNamed(context, '/symptomeMonat');
                  }),
                  _drawerItem(context, 'Stuhl-Tagebuch', Icons.wc, () {
                    Navigator.pushNamed(context, '/stuhlMonat');
                  }),
                  _drawerItem(context, 'Ess-Tagebuch', Icons.restaurant, () {
                    Navigator.pushNamed(context, '/essenMonat');
                  }),
                  _drawerItem(context, 'Seelen-Log', Icons.sentiment_satisfied, () {
                    Navigator.pushNamed(context, '/stimmungMonat');
                  }),
                  _drawerItem(context, 'Toiletten finden', Icons.map, () {
                    Navigator.pushNamed(context, '/hilfeUnterwegs');
                  }),
                  _drawerItem(context, 'Impressum & Credits', Icons.info, () {
                    Navigator.pushNamed(context, '/credits');
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: CEDColors.iconPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Erfassen. Verstehen. Verbessern.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: CEDColors.iconSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: CEDColors.accent),
      title: Text(
        title,
        style: TextStyle(color: CEDColors.textPrimary),
      ),
      horizontalTitleGap: 12,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      selectedTileColor: CEDColors.surface,
    );
  }
}
