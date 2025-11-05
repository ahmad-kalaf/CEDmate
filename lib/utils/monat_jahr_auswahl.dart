import 'package:flutter/material.dart';

/// Monat-/Jahrauswahl mit optionalem Datumsbereich.
/// Nach Auswahl wird der Fokus entfernt (Dropdown schließt sich sauber).
class MonatJahrAuswahl extends StatefulWidget {
  final void Function(DateTime)? onChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  MonatJahrAuswahl({
    super.key,
    this.onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
  }) : firstDate = firstDate ?? DateTime(2015, 1),
       lastDate = lastDate ?? DateTime.now();

  @override
  State<MonatJahrAuswahl> createState() => _MonatJahrAuswahlState();
}

class _MonatJahrAuswahlState extends State<MonatJahrAuswahl> {
  late int _selectedMonth;
  late int _selectedYear;

  final List<String> _monate = const [
    'Jan',
    'Feb',
    'Mär',
    'Apr',
    'Mai',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Okt',
    'Nov',
    'Dez',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    // Gültige Jahre
    final years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (i) => widget.firstDate.year + i,
    );

    // Gültige Monate je nach Jahr
    List<int> months;
    if (_selectedYear == widget.firstDate.year &&
        _selectedYear == widget.lastDate.year) {
      months = List.generate(
        widget.lastDate.month - widget.firstDate.month + 1,
        (i) => widget.firstDate.month + i,
      );
    } else if (_selectedYear == widget.firstDate.year) {
      months = List.generate(
        12 - widget.firstDate.month + 1,
        (i) => widget.firstDate.month + i,
      );
    } else if (_selectedYear == widget.lastDate.year) {
      months = List.generate(widget.lastDate.month, (i) => i + 1);
    } else {
      months = List.generate(12, (i) => i + 1);
    }

    // Falls aktueller Monat nicht mehr erlaubt ist
    if (!months.contains(_selectedMonth)) {
      _selectedMonth = months.last;
    }

    FocusNode _monatFocusNode = FocusNode();
    FocusNode _jahrFocusNode = FocusNode();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Monat-Auswahl
        DropdownButton<int>(
          value: _selectedMonth,
          underline: const SizedBox(),
          focusNode: _monatFocusNode,
          items: months
              .map(
                (m) => DropdownMenuItem(value: m, child: Text(_monate[m - 1])),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedMonth = val);
              widget.onChanged?.call(DateTime(_selectedYear, _selectedMonth));
              _monatFocusNode.unfocus();
            }
          },
        ),
        const SizedBox(width: 8),
        // Jahr-Auswahl
        DropdownButton<int>(
          value: _selectedYear,
          underline: const SizedBox(),
          focusNode: _jahrFocusNode,
          items: years
              .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedYear = val);
              widget.onChanged?.call(DateTime(_selectedYear, _selectedMonth));
              _jahrFocusNode.unfocus();
            }
          },
        ),
      ],
    );
  }
}
