import 'package:cedmate/models/stuhlgang.dart';
import 'package:cedmate/services/stuhlgang_service.dart';
import 'package:cedmate/utils/loesche_eintrag.dart';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:cedmate/widgets/icon_selector.dart';
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
  DateTime _eintrageZeitpunkt = DateTime.now(); // wird aktuell nicht benutzt
  bool _isSaving = false;
  final List<Icon> _stuhlformIcons = const [
    Icon(Icons.not_interested, color: Colors.brown),
    Icon(Cedmate.kons_1, color: Colors.brown),
    Icon(Cedmate.kons_2, color: Colors.brown),
    Icon(Cedmate.kons_3, color: Colors.brown),
    Icon(Cedmate.kons_4, color: Colors.brown),
    Icon(Cedmate.kons_5, color: Colors.brown),
    Icon(Cedmate.kons_6, color: Colors.brown),
    Icon(Cedmate.kons_7, color: Colors.brown),
  ];
  late final PageController _pageControllerKonsistenz;
  late final PageController _pageControllerSchmerzLevel;
  final List<Icon> _schmerzLevelIcons = const [
    Icon(Icons.sentiment_very_satisfied_outlined),
    Icon(Icons.sentiment_satisfied),
    Icon(Icons.sentiment_neutral),
    Icon(Icons.sentiment_dissatisfied),
    Icon(Icons.sentiment_very_dissatisfied),
    Icon(Icons.sentiment_very_dissatisfied_sharp),
  ];
  final List<String> _schmerzLevelDescriptions = const [
    'Kein Schmerz',
    'Leichter Schmerz',
    'Mittlerer Schmerz',
    'Starker Schmerz',
    'Sehr starker Schmerz',
    'Stärkster vorstellbarer Schmerz',
  ];

  bool get isEditMode => widget.stuhlgang != null;
  int _schmerzLevel = 1;

  @override
  void initState() {
    super.initState();

    final s = widget.stuhlgang;
    if (s != null) {
      _ausgewaehlteForm = s.konsistenz;
      _haeufigkeitController.text = s.haeufigkeit.toString();
      _notizenController.text = s.notizen ?? '';
      _eintrageZeitpunkt = s.eintragZeitpunkt;
      _schmerzLevel = s.schmerzLevel;
    }
    final initialIndexKonsistenz = BristolStuhlform.values.indexOf(
      _ausgewaehlteForm,
    );
    _pageControllerKonsistenz = PageController(
      initialPage: initialIndexKonsistenz < 0 ? 0 : initialIndexKonsistenz,
      viewportFraction: 0.25,
    );
    _pageControllerSchmerzLevel = PageController(
      initialPage: _schmerzLevel - 1,
      viewportFraction: 0.25,
    );
  }

  @override
  void dispose() {
    _haeufigkeitController.dispose();
    _notizenController.dispose();
    _pageControllerKonsistenz.dispose();
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
          schmerzLevel: _schmerzLevel,
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
          schmerzLevel: _schmerzLevel,
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
        showDrawer: false,
        title: isEditMode ? 'Eintrag bearbeiten' : 'Eintrag erfassen',
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ------------------------------
              // KONSISTENZ
              // ------------------------------
              IconSelector(
                pageController: _pageControllerKonsistenz,
                title: 'Typ - Konsistenz',
                selectedValue: _ausgewaehlteForm,
                values: BristolStuhlform.values,
                icons: _stuhlformIcons,
                onChanged: (value) {
                  setState(() {
                    _ausgewaehlteForm = value;
                    if (value == BristolStuhlform.typ0) {
                      _haeufigkeitController.text = '0';
                    } else if (_haeufigkeitController.text.isNotEmpty &&
                        int.tryParse(_haeufigkeitController.text)! < 1) {
                      _haeufigkeitController.text = '1';
                    }
                  });
                },
                description: _ausgewaehlteForm.beschreibung,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                ],
              ),
              const SizedBox(height: 16),
              // ------------------------------
              // HÄUFIGKEIT
              // ------------------------------
              TextFormField(
                onChanged: (value) {
                  if (value.isEmpty) return;
                  final parsed = int.tryParse(value);
                  if (parsed == null) return;
                  if (parsed == 0) {
                    setState(() {
                      _ausgewaehlteForm = BristolStuhlform.values[0];
                      _pageControllerKonsistenz.jumpToPage(0);
                    });
                  } else if (_ausgewaehlteForm == BristolStuhlform.typ0 &&
                      parsed > 0) {
                    setState(() {
                      _ausgewaehlteForm = BristolStuhlform.typ1;
                      _pageControllerKonsistenz.jumpToPage(1);
                    });
                  }
                },
                controller: _haeufigkeitController,
                decoration: const InputDecoration(
                  labelText: 'Häufigkeit pro Tag (min. 0)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final i = int.tryParse(v ?? '');
                  if (i == null || i < 0) {
                    return 'Bitte mindestens 0 eingeben.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              // ------------------------------
              // SCHMERZLEVEL
              // ------------------------------
              IconSelector(
                pageController: _pageControllerSchmerzLevel,
                title: 'Schmerzlevel',
                selectedValue: _schmerzLevel,
                description: _schmerzLevelDescriptions[_schmerzLevel - 1],
                values: [1, 2, 3, 4, 5, 6],
                icons: _schmerzLevelIcons,
                onChanged: (value) {
                  setState(() {
                    _schmerzLevel = value;
                  });
                },
                colors: [
                  Colors.green,
                  Colors.lightGreen,
                  Colors.yellow,
                  Colors.orange.shade400, // dunkleres Orange
                  Colors.orange.shade800, // sehr dunkles Orange
                  Colors.red.shade700,
                ],
              ),

              const SizedBox(height: 16),

              // ------------------------------
              // NOTIZEN
              // ------------------------------
              TextFormField(
                controller: _notizenController,
                decoration: const InputDecoration(
                  labelText: 'Notizen / Auffälligkeiten:',
                  hintText: 'z.B. Blut, Schleim etc.',
                  hintStyle: TextStyle(color: Colors.grey),
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
