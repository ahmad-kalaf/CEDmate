import 'package:cedmate/models/enums/stimmung_level.dart';
import 'package:cedmate/utils/build_list_section.dart';
import 'package:flutter/material.dart';

import '../models/stimmung.dart';

class StimmungEintragen extends StatefulWidget {
  final Stimmung? stimmung;

  const StimmungEintragen({super.key, this.stimmung});

  @override
  State<StimmungEintragen> createState() => _StimmungEintragenState();
}

class _StimmungEintragenState extends State<StimmungEintragen> {
  final _formKey = GlobalKey<FormState>();
  StimmungLevel _stimmungLevel = StimmungLevel.neutral;
  final _stresslevelController = TextEditingController();
  final _notizController = TextEditingController();
  final _tagsController = TextEditingController();

  final List<String> _tags = [];

  bool _isSaving = false;

  bool get isEditMode => widget.stimmung != null;

  /// Allgemeine Hilfsfunktion zum Hinzufügen eines Eintrags zu einer Liste
  void _addTag(TextEditingController controller, List<String> list) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !list.contains(text)) {
      setState(() {
        list.add(text);
        controller.clear();
      });
    }
  }

  /// Entfernt ein Element aus einer Liste
  void _removeTag(List<String> list, String value) {
    setState(() => list.remove(value));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final bool? verlassenBestaetigt = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Symptom bearbeiten'),
              content: const Text(
                'Wenn du die Seite verlässt, werden deine Eingaben NICHT gespeichert!',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Ja, verlassen'),
                ),
              ],
            ),
          );
          if (verlassenBestaetigt == true && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Eintrag bearbeiten' : 'Eintrag erfassen'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton(
                        items: StimmungLevel.values.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      TextFormField(
                        controller: _stresslevelController,
                        decoration: const InputDecoration(
                          labelText: 'Intensität (1–10)',
                        ),
                        validator: (v) {
                          final i = int.tryParse(v ?? '');
                          if (i == null || i < 1 || i > 10) {
                            return 'Wert zwischen 1 und 10';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _notizController,
                        decoration: const InputDecoration(
                          labelText: 'Notizen (optional)',
                        ),
                        maxLines: 3,
                      ),
                      buildListSection(
                        title: 'Tags (optional)',
                        context: context,
                        controller: _tagsController,
                        items: _tags,
                        onAdd: () => _addTag(_tagsController, _tags),
                        onRemove: (val) => _removeTag(_tags, val),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
