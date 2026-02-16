import 'package:cedmate/widgets/layout/ced_layout.dart';
import 'package:flutter/material.dart';

class MedikamentFormScreen extends StatefulWidget {
  final Map<String, dynamic>? medikament;

  const MedikamentFormScreen({super.key, this.medikament});

  @override
  State<MedikamentFormScreen> createState() => _MedikamentFormScreenState();
}

class _MedikamentFormScreenState extends State<MedikamentFormScreen> {
  late TextEditingController nameController;
  late TextEditingController dosisController;
  late TextEditingController zeitController;
  late TextEditingController frequenzController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.medikament?['name'] ?? '',
    );
    dosisController = TextEditingController(
      text: widget.medikament?['dosis'] ?? '',
    );
    zeitController = TextEditingController(
      text: widget.medikament?['zeit'] ?? '',
    );
    frequenzController = TextEditingController(
      text: widget.medikament?['frequenz'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.medikament != null;

    return CEDLayout(
      title: isEdit ? 'Medikament bearbeiten' : 'Neues Medikament',
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Medikamentenname'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: dosisController,
              decoration: const InputDecoration(labelText: 'Dosis'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: zeitController,
              decoration: const InputDecoration(labelText: 'Einnahmezeit'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: frequenzController,
              decoration: const InputDecoration(labelText: 'Frequenz'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(isEdit ? 'Änderungen speichern' : 'Speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
