import 'package:cedmate/models/c_e_d_wissen.dart';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';

class WissenBeitragScreen extends StatelessWidget {
  final CEDWissen beitrag;

  const WissenBeitragScreen({super.key, required this.beitrag});

  @override
  Widget build(BuildContext context) {
    return CEDLayout(
      showDrawer: false,
      title: beitrag.titel,
      // TODO hier werden die Inhalte angezeigt
      child: Text(beitrag.contentText ?? 'Kein Inhalt'),
    );
  }
}
