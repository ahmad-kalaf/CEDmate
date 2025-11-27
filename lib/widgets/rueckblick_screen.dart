import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';

import 'CEDColors.dart';

class RueckblickScreen extends StatelessWidget {
  const RueckblickScreen({super.key});

  @override
  Widget build(BuildContext context) {

    Widget rectCardItem({
      required IconData icon,
      required String text,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 110,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: CEDColors.surfaceDark, // ← NEW, darker background
              borderRadius: BorderRadius.circular(16),
              // no border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: CEDColors.iconPrimary, size: 30),
                const SizedBox(height: 10),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      );
    }

    return CEDLayout(
      title: 'Rückblick', child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Du kannst dir hier einen Überblick über deine Einträge der letzten Monate verschaffen:',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            rectCardItem(icon: Icons.show_chart, text: 'Symptom-Radar', onTap: (){
              Navigator.pushNamed(context, '/symptomeMonat');
            }),
            rectCardItem(icon: Icons.wc, text: 'Stuhl-Tagebuch', onTap: () {
              Navigator.pushNamed(context, '/stuhlMonat');
            }),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            rectCardItem(icon: Icons.restaurant,text: 'Ess-Tagebuch',onTap: () {
              Navigator.pushNamed(context, '/essenMonat');
            }),
            rectCardItem(
              icon:  Icons.sentiment_satisfied,
              text: 'Seelen-Log',
              onTap:() {
                Navigator.pushNamed(context, '/stimmungMonat');
              },
            ),
          ],
        )
      ],
    ),);
  }

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
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selectedTileColor: CEDColors.surface,
      ),
    );
  }
}
