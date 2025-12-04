import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';

class CEDWissenScreen extends StatelessWidget {
  const CEDWissenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CEDLayout(title: 'CED Wissen', child: Text('Neue Kategorien '));
  }
}
