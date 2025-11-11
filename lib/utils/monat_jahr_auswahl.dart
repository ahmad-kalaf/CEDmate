import 'package:flutter/material.dart';

/// Monat-/Jahrauswahl mit optionalem Datumsbereich.
/// Nach Auswahl wird der Fokus entfernt (Dropdown schließt sich sauber).
class MonatJahrAuswahl extends StatefulWidget {
  final void Function(DateTime)? onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;
  final DateTime? resetDate;
  final void Function(DateTime)? onReset;
  final bool showResetButton;
  final String resetTooltip;
  final IconData resetIcon;

  MonatJahrAuswahl({
    super.key,
    this.onChanged,
    DateTime? firstDate,
    DateTime? lastDate,
    this.initialDate,
    this.resetDate,
    this.onReset,
    this.showResetButton = false,
    this.resetTooltip = 'Datum zurücksetzen',
    this.resetIcon = Icons.refresh,
  }) : firstDate = firstDate ?? DateTime(2015, 1),
       lastDate = lastDate ?? DateTime.now();

  @override
  State<MonatJahrAuswahl> createState() => _MonatJahrAuswahlState();
}

class _MonatJahrAuswahlState extends State<MonatJahrAuswahl> {
  late int _selectedMonth;
  late int _selectedYear;
  late final FocusNode _monatFocusNode;
  late final FocusNode _jahrFocusNode;

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
    final initialDate = _clampDate(widget.initialDate ?? DateTime.now());
    _selectedMonth = initialDate.month;
    _selectedYear = initialDate.year;
    _monatFocusNode = FocusNode();
    _jahrFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _monatFocusNode.dispose();
    _jahrFocusNode.dispose();
    super.dispose();
  }

  DateTime _clampDate(DateTime date) {
    var clamped = date;
    if (clamped.isBefore(widget.firstDate)) {
      clamped = widget.firstDate;
    }
    if (clamped.isAfter(widget.lastDate)) {
      clamped = widget.lastDate;
    }
    return DateTime(clamped.year, clamped.month);
  }

  DateTime _currentSelection() => DateTime(_selectedYear, _selectedMonth);

  void _notifyChange() {
    widget.onChanged?.call(_currentSelection());
  }

  void _resetSelection() {
    final target = _clampDate(widget.resetDate ?? DateTime.now());
    setState(() {
      _selectedMonth = target.month;
      _selectedYear = target.year;
    });
    _monatFocusNode.unfocus();
    _jahrFocusNode.unfocus();
    _notifyChange();
    widget.onReset?.call(_currentSelection());
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
      _selectedMonth = months.first;
    }

    FocusNode _monatFocusNode = FocusNode();
    FocusNode _jahrFocusNode = FocusNode();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Monat-Auswahl
          DropdownButton<int>(
            value: _selectedMonth,
            underline: const SizedBox(),
            focusNode: _monatFocusNode,
            isDense: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            items: months
                .map(
                  (m) =>
                      DropdownMenuItem(value: m, child: Text(_monate[m - 1])),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedMonth = val);
                widget.onChanged?.call(DateTime(_selectedYear, _selectedMonth));
                _notifyChange();
                _monatFocusNode.unfocus();
              }
            },
          ),
          const SizedBox(width: 4),
          // Jahr-Auswahl
          DropdownButton<int>(
            value: _selectedYear,
            underline: const SizedBox(),
            focusNode: _jahrFocusNode,
            isDense: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
            items: years
                .map(
                  (y) => DropdownMenuItem(value: y, child: Text(y.toString())),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedYear = val);
                widget.onChanged?.call(DateTime(_selectedYear, _selectedMonth));
                _notifyChange();
                _jahrFocusNode.unfocus();
              }
            },
          ),
          if (widget.showResetButton) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: IconButton(
                onPressed: _resetSelection,
                tooltip: widget.resetTooltip,
                iconSize: 16,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(widget.resetIcon),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
