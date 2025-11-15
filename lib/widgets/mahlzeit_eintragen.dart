import 'package:cedmate/models/mahlzeit.dart';
import 'package:cedmate/services/mahlzeit_service.dart';
import 'package:cedmate/utils/build_list_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/loesche_eintrag.dart';

class MahlzeitEintragen extends StatefulWidget {
  final Mahlzeit? mahlzeit;

  const MahlzeitEintragen({super.key, this.mahlzeit});

  @override
  State<MahlzeitEintragen> createState() => _MahlzeitEintragenState();
}

class _MahlzeitEintragenState extends State<MahlzeitEintragen> {
  final _formKey = GlobalKey<FormState>();

  final _bezeichnungController = TextEditingController();
  final _zutatenController = TextEditingController();
  final _notizController = TextEditingController();
  final _unvertraeglichkeitenController = TextEditingController();

  final List<String> _zutaten = [];
  final List<String> _unvertraeglichkeiten = [];

  bool _isSaving = false;

  bool get isEditMode => widget.mahlzeit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final m = widget.mahlzeit!;
      _bezeichnungController.text = m.bezeichnung;
      _notizController.text = m.notiz ?? '';
      _zutaten.addAll(m.zutaten ?? []);
      _unvertraeglichkeiten.addAll(m.unvertraeglichkeiten ?? []);
    }
  }

  @override
  void dispose() {
    _bezeichnungController.dispose();
    _zutatenController.dispose();
    _notizController.dispose();
    _unvertraeglichkeitenController.dispose();
    super.dispose();
  }

  void _addItem(TextEditingController controller, List<String> list) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !list.contains(text)) {
      setState(() {
        list.add(text);
        controller.clear();
      });
    }
  }

  void _removeItem(List<String> list, String value) {
    setState(() => list.remove(value));
  }

  Future<void> _speichereEintrag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final mahlzeit = Mahlzeit(
      id: widget.mahlzeit?.id,
      bezeichnung: _bezeichnungController.text.trim(),
      zutaten: _zutaten.isEmpty ? null : List.from(_zutaten),
      notiz: _notizController.text.trim().isEmpty
          ? null
          : _notizController.text.trim(),
      unvertraeglichkeiten: _unvertraeglichkeiten.isEmpty
          ? null
          : List.from(_unvertraeglichkeiten),
      mahlzeitZeitpunkt: widget.mahlzeit?.mahlzeitZeitpunkt ?? DateTime.now(),
    );

    final mahlzeitService = context.read<MahlzeitService>();
    try {
      if (isEditMode) {
        await mahlzeitService.aktualisiereMahlzeit(mahlzeit);
      } else {
        await mahlzeitService.erfasseMahlzeit(mahlzeit);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? 'Eintrag aktualisiert' : 'Eintrag gespeichert',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
              title: const Text('Seite verlassen?'),
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
          title: Text(isEditMode ? 'Eintrag bearbeiten' : 'Mahlzeit erfassen'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _bezeichnungController,
                        decoration: const InputDecoration(
                          labelText: 'Bezeichnung der Mahlzeit',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Bitte eine Bezeichnung angeben';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      buildListSection(
                        title: 'Zutaten (optional)',
                        context: context,
                        controller: _zutatenController,
                        items: _zutaten,
                        onAdd: () => _addItem(_zutatenController, _zutaten),
                        onRemove: (val) => _removeItem(_zutaten, val),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notizController,
                        decoration: const InputDecoration(
                          labelText: 'Notizen (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      buildListSection(
                        title: 'Unverträglichkeiten (optional)',
                        context: context,
                        controller: _unvertraeglichkeitenController,
                        items: _unvertraeglichkeiten,
                        onAdd: () => _addItem(
                          _unvertraeglichkeitenController,
                          _unvertraeglichkeiten,
                        ),
                        onRemove: (val) =>
                            _removeItem(_unvertraeglichkeiten, val),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _speichereEintrag,
                        icon: const Icon(Icons.save),
                        label: Text(
                          isEditMode
                              ? 'Änderungen speichern'
                              : 'Eintrag speichern',
                        ),
                      ),
                      if (isEditMode) ...[
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete_forever),
                          label: Text('Löschen'),
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  final symptomService = context
                                      .read<MahlzeitService>();
                                  await deleteEntry(
                                    context,
                                    titel: 'Eintrag löschen',
                                    text:
                                        'Möchtest du diesen Eintrag wirklich löschen? Dieser Vorgang kann nicht rückgängig gemacht werden',
                                    deleteAction: () => symptomService
                                        .loescheMahlzeit(widget.mahlzeit!.id!),
                                  );
                                  if (mounted) Navigator.pop(context);
                                },
                        ),
                      ],
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
