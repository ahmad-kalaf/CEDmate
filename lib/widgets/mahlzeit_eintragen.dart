import 'package:cedmate/models/mahlzeit.dart';
import 'package:cedmate/services/mahlzeit_service.dart';
import 'package:cedmate/utils/build_list_section.dart';
import 'package:cedmate/widgets/ced_layout.dart';
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

    final service = context.read<MahlzeitService>();

    try {
      if (isEditMode) {
        await service.aktualisiereMahlzeit(mahlzeit);
      } else {
        await service.erfasseMahlzeit(mahlzeit);
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
          final bool? confirm = await showDialog(
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

          if (confirm == true && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: CEDLayout(
        showDrawer: false,
        title: isEditMode ? 'Eintrag bearbeiten' : 'Mahlzeit erfassen',
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // -------------------------
              // BEZEICHNUNG
              // -------------------------
              TextFormField(
                controller: _bezeichnungController,
                decoration: const InputDecoration(
                  labelText: 'Bezeichnung der Mahlzeit',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Bitte eine Bezeichnung angeben';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // -------------------------
              // ZUTATEN
              // -------------------------
              buildListSection(
                title: 'Zutaten (optional)',
                context: context,
                controller: _zutatenController,
                items: _zutaten,
                onAdd: () => _addItem(_zutatenController, _zutaten),
                onRemove: (v) => _removeItem(_zutaten, v),
              ),

              const SizedBox(height: 16),

              // -------------------------
              // NOTIZ
              // -------------------------
              TextFormField(
                controller: _notizController,
                decoration: const InputDecoration(
                  labelText: 'Notizen (optional)',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // -------------------------
              // UNVERTRÄGLICHKEITEN
              // -------------------------
              buildListSection(
                title: 'Unverträglichkeiten (optional)',
                context: context,
                controller: _unvertraeglichkeitenController,
                items: _unvertraeglichkeiten,
                onAdd: () => _addItem(
                  _unvertraeglichkeitenController,
                  _unvertraeglichkeiten,
                ),
                onRemove: (v) => _removeItem(_unvertraeglichkeiten, v),
              ),

              const SizedBox(height: 24),

              // -------------------------
              // SPEICHERN BUTTON
              // -------------------------
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _speichereEintrag,
                icon: const Icon(Icons.save),
                label: Text(
                  isEditMode ? 'Änderungen speichern' : 'Eintrag speichern',
                ),
              ),

              // -------------------------
              // LÖSCHEN BUTTON
              // -------------------------
              if (isEditMode) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade300,
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Löschen'),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final service = context.read<MahlzeitService>();

                          await deleteEntry(
                            context,
                            titel: 'Eintrag löschen',
                            text:
                                'Möchtest du diesen Eintrag wirklich löschen? Dieser Vorgang kann nicht rückgängig gemacht werden',
                            deleteAction: () =>
                                service.loescheMahlzeit(widget.mahlzeit!.id!),
                          );

                          if (mounted) Navigator.pop(context);
                        },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
