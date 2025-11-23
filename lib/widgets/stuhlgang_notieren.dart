import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/utils/loesche_eintrag.dart';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cedmate_icons.dart';
import '../models/enums/bristol_stuhlform.dart';
import 'CEDColors.dart';

class StuhlgangNotieren extends StatefulWidget {
  final Stuhlgang? stuhlgang;

  const StuhlgangNotieren({super.key, this.stuhlgang});

  @override
  State<StuhlgangNotieren> createState() => _StuhlgangNotierenState();
}

class _StuhlgangNotierenState extends State<StuhlgangNotieren> {
  final _formKey = GlobalKey<FormState>();

  BristolStuhlform _ausgewaehlteForm = BristolStuhlform.typ4;
  final _haeufigkeitController = TextEditingController();
  final _notizenController = TextEditingController();

  DateTime _eintrageZeitpunkt = DateTime.now();
  bool _isSaving = false;
  final List<Icon> _stuhlformIcons = const [
    Icon(Cedmate.kons_1),
    Icon(Cedmate.kons_2),
    Icon(Cedmate.kons_3),
    Icon(Cedmate.kons_4),
    Icon(Cedmate.kons_5),
    Icon(Cedmate.kons_6),
    Icon(Cedmate.kons_7),
  ];
  late final PageController _pageController;

  bool get isEditMode => widget.stuhlgang != null;

  @override
  void initState() {
    super.initState();

    final s = widget.stuhlgang;
    if (s != null) {
      _ausgewaehlteForm = s.konsistenz;
      _haeufigkeitController.text = s.haeufigkeit.toString();
      _notizenController.text = s.notizen ?? '';
      _eintrageZeitpunkt = s.eintragZeitpunkt;
    }
    final initialIndex = BristolStuhlform.values.indexOf(_ausgewaehlteForm);
    _pageController = PageController(
      initialPage: initialIndex < 0 ? 0 : initialIndex,
      viewportFraction: 0.25,
    );
  }

  @override
  void dispose() {
    _haeufigkeitController.dispose();
    _notizenController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _speichereEintrag() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final service = context.read<StuhlgangService>();

      final haeufigkeit = int.parse(_haeufigkeitController.text.trim());
      final notizen = _notizenController.text.trim().isEmpty
          ? null
          : _notizenController.text.trim();

      if (isEditMode) {
        final aktualisiert = widget.stuhlgang!.copyWith(
          konsistenz: _ausgewaehlteForm,
          haeufigkeit: haeufigkeit,
          notizen: notizen,
        );

        await service.aktualisiereStuhlgang(aktualisiert);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Eintrag aktualisiert.')),
          );
        }
      } else {
        await service.erfasseStuhlgang(
          konsistenz: _ausgewaehlteForm,
          haeufigkeit: haeufigkeit,
          notizen: notizen,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Eintrag gespeichert.')));
        }
      }

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
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final verlassen = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verlassen bestätigen'),
            content: const Text(
              'Wenn du die Seite verlässt, werden deine Eingaben NICHT gespeichert.',
            ),
            actions: [
              TextButton(
                child: const Text('Abbrechen'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Ja, verlassen'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );

        if (verlassen == true && mounted) Navigator.pop(context);
      },
      child: CEDLayout(
        title: isEditMode ? 'Eintrag bearbeiten' : 'Eintrag erfassen',
        child: Form(
          key: _formKey,
          child: Column(
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
                        'Typ – Konsistenz',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: BristolStuhlform.values.length,
                        onPageChanged: (page) {
                          setState(() {
                            _ausgewaehlteForm = BristolStuhlform.values[page];
                          });
                        },
                        itemBuilder: (context, index) {
                          final form = BristolStuhlform.values[index];
                          final isSelected = form == _ausgewaehlteForm;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                              setState(() {
                                _ausgewaehlteForm = form;
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
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  _stuhlformIcons[index].icon,
                                  size: 60,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        _ausgewaehlteForm.beschreibung.substring(8),
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ------------------------------
              // HÄUFIGKEIT
              // ------------------------------
              TextFormField(
                controller: _haeufigkeitController,
                decoration: const InputDecoration(
                  labelText: 'Häufigkeit pro Tag (min. 1)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final i = int.tryParse(v ?? '');
                  if (i == null || i < 1) {
                    return 'Bitte mindestens 1 eingeben.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ------------------------------
              // NOTIZEN
              // ------------------------------
              TextFormField(
                controller: _notizenController,
                decoration: const InputDecoration(
                  labelText: 'Notizen (optional)',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 26),

              // ------------------------------
              // SPEICHERN BUTTON
              // ------------------------------
              ElevatedButton.icon(
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isEditMode ? 'Aktualisieren' : 'Speichern'),
                onPressed: _isSaving ? null : _speichereEintrag,
              ),

              // ------------------------------
              // LÖSCHEN BUTTON (nur im Edit-Modus)
              // ------------------------------
              if (isEditMode) ...[
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Löschen'),
                  onPressed: () async {
                    final service = context.read<StuhlgangService>();

                    await deleteEntry(
                      context,
                      titel: 'Eintrag löschen',
                      text:
                          'Diesen Eintrag wirklich löschen? Dies kann nicht rückgängig gemacht werden.',
                      deleteAction: () =>
                          service.loescheStuhlgang(widget.stuhlgang!.id!),
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
