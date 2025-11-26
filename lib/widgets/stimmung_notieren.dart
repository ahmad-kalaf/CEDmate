import 'package:cedmate/models/enums/stimmung_level.dart';
import 'package:cedmate/services/stimmung_service.dart';
import 'package:cedmate/utils/build_list_section.dart';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stimmung.dart';
import '../utils/loesche_eintrag.dart';
import 'CEDColors.dart';

class StimmungNotieren extends StatefulWidget {
  final Stimmung? stimmung;

  const StimmungNotieren({super.key, this.stimmung});

  @override
  State<StimmungNotieren> createState() => _StimmungNotierenState();
}

class _StimmungNotierenState extends State<StimmungNotieren> {
  final _formKey = GlobalKey<FormState>();
  late StimmungLevel _stimmungLevel;
  final _stresslevelController = TextEditingController();
  final _notizController = TextEditingController();
  final _tagsController = TextEditingController();

  final List<String> _tags = [];
  bool _isSaving = false;

  bool get isEditMode => widget.stimmung != null;
  late final PageController _pageController;
  final List<String> _moodDescriptions = [
    'Sehr schlecht',
    'Schlecht',
    'Neutral',
    'Gut',
    'Sehr gut',
  ];

  @override
  void initState() {
    super.initState();
    // Falls wir bearbeiten, vorhandene Werte übernehmen
    if (isEditMode) {
      final s = widget.stimmung!;
      _stimmungLevel = s.level;
      _stresslevelController.text = s.stresslevel.toString() ?? '';
      _notizController.text = s.notiz ?? '';
      _tags.addAll(s.tags ?? []);
    } else {
      _stimmungLevel = StimmungLevel.neutral;
    }
    final initialIndex = widget.stimmung != null
        ? widget.stimmung!.level.index
        : 2;
    _pageController = PageController(
      viewportFraction: 0.3,
      initialPage: widget.stimmung != null
          ? (widget.stimmung!.level.index)
          : 2,
    );
  }

  @override
  void dispose() {
    _stresslevelController.dispose();
    _notizController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag(TextEditingController controller, List<String> list) {
    final text = controller.text.trim();
    if (text.isNotEmpty && !list.contains(text)) {
      setState(() {
        list.add(text);
        controller.clear();
      });
    }
  }

  void _removeTag(List<String> list, String value) {
    setState(() => list.remove(value));
  }

  Future<void> _speichereEintrag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // eintrag speichern
    final stimmung = Stimmung(
      id: widget.stimmung?.id,
      level: _stimmungLevel,
      stresslevel: int.parse(_stresslevelController.text),
      notiz: _notizController.text.trim().isEmpty
          ? null
          : _notizController.text.trim(),
      tags: _tags.isEmpty ? null : List.from(_tags),
      stimmungsZeitpunkt: widget.stimmung?.stimmungsZeitpunkt ?? DateTime.now(),
    );

    final stimmungService = context.read<StimmungService>();
    try {
      if (isEditMode) {
        await stimmungService.aktualisiereStimmung(stimmung);
      } else {
        await stimmungService.erfasseStimmung(stimmung);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? 'Eintrag aktualisiert' : 'Eintrag gespeichert',
          ),
        ),
      );
      if (mounted) Navigator.pop(context);
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
      child: CEDLayout(
        showDrawer: false,
        title: isEditMode ? 'Eintrag bearbeiten' : 'Eintrag erfassen',
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CEDColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CEDColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Stimmung',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: StimmungLevel.values.length,
                          onPageChanged: (page) {
                            setState(() {
                              _stimmungLevel =
                              StimmungLevel.values[page];
                            });
                          },
                          itemBuilder: (context, index) {
                            final mood = StimmungLevel.values[index];
                            final isSelected =
                                mood == _stimmungLevel;

                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                );
                                setState(() {
                                  _stimmungLevel = mood;
                                });
                              },
                              child: AnimatedOpacity(
                                opacity: isSelected ? 1.0 : 0.3,
                                duration: const Duration(milliseconds: 200),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: isSelected
                                        ? Border.all(
                                      color: Colors.black,
                                      width: 3,
                                    )
                                        : null,
                                    color: isSelected
                                        ? CEDColors.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _moodDescriptions[index],
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ---------- Beschreibung unten ----------
                      Center(
                        child: Text(
                          _moodDescriptions[_stimmungLevel.index],
                          style: Theme.of(context).textTheme.labelLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stresslevelController,
                  decoration: const InputDecoration(
                    labelText: 'Stresslevel (1–10)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final i = int.tryParse(v ?? '');
                    if (i == null || i < 1 || i > 10) {
                      return 'Wert zwischen 1 und 10';
                    }
                    return null;
                  },
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
                  title: 'Tags (optional)',
                  context: context,
                  controller: _tagsController,
                  items: _tags,
                  onAdd: () => _addTag(_tagsController, _tags),
                  onRemove: (val) => _removeTag(_tags, val),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _speichereEintrag,
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEditMode ? 'Änderungen speichern' : 'Eintrag speichern',
                  ),
                ),
                if (isEditMode) ...[
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete_forever),
                    label: Text('Löschen'),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final symptomService = context
                                .read<StimmungService>();
                            await deleteEntry(
                              context,
                              titel: 'Eintrag löschen',
                              text:
                                  'Möchtest du diesen Eintrag wirklich löschen? Dieser Vorgang kann nicht rückgängig gemacht werden',
                              deleteAction: () => symptomService
                                  .loescheStimmung(widget.stimmung!.id!),
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
    );
  }
}
