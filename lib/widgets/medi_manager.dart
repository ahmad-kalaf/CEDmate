import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';
import 'medikament_form_screen.dart';

class MediManager extends StatefulWidget {
  const MediManager({super.key});

  @override
  State<MediManager> createState() => _MediManagerState();
}

class _MediManagerState extends State<MediManager> {
  bool erinnerungAktiv = false;

  final List<Map<String, dynamic>> dummyMedikamente = [
    {
      'name': 'Mesalazin',
      'dosis': '500 mg',
      'zeit': 'morgens & abends',
      'frequenz': '2× täglich',
      'reminder': true,
    },
    {
      'name': 'Azathioprin',
      'dosis': '50 mg',
      'zeit': 'morgens',
      'frequenz': '1× täglich',
      'reminder': false,
    },
    {
      'name': 'Prednisolon',
      'dosis': '20 mg',
      'zeit': 'morgens',
      'frequenz': '1× täglich',
      'reminder': true,
    },
    {
      'name': 'Pantoprazol',
      'dosis': '40 mg',
      'zeit': 'vor dem Frühstück',
      'frequenz': '1× täglich',
      'reminder': false,
    },
    {
      'name': 'Buscopan',
      'dosis': '10 mg',
      'zeit': 'nach Bedarf',
      'frequenz': 'bei Bedarf',
      'reminder': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CEDLayout(
      title: 'MediManager',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MedikamentFormScreen()),
            );
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedikamentFormScreen()),
              );
            },
            label: const Text('Medikament hinzufügen'),
          ),
          const SizedBox(height: 30),
          const Text(
            'Deine Medikation im Überblick',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dummyMedikamente.length,
            itemBuilder: (context, index) {
              final med = dummyMedikamente[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.medication),
                  title: Text(med['name']),
                  subtitle: Text('${med['dosis']} • ${med['zeit']}'),
                  trailing: Switch(
                    value: med['reminder'],
                    onChanged: (value) {
                      setState(() {
                        med['reminder'] = value;
                      });
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MedikamentFormScreen(medikament: med),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          const Text(
            'Hinweis: Alle Funktionen sind prototypisch.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
