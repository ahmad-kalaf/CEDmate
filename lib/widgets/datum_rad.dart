import 'dart:ui';
import 'package:cedmate/widgets/CEDColors.dart';
import 'package:flutter/material.dart';

/// Zeigt eine horizontale Scroll-Leiste mit allen Tagen eines Monats.
/// Ähnlich einem minimalistischen Kalender-Widget für CEDmate.
class DatumRad extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final int year;
  final int month;
  final int? initialDay;

  const DatumRad({
    super.key,
    this.onDateSelected,
    required this.year,
    required this.month,
    this.initialDay,
  });

  @override
  State<DatumRad> createState() => _DatumRadState();
}

class _DatumRadState extends State<DatumRad> {
  late final PageController _controller;
  late final List<DateTime> _dates;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final nextMonth = DateTime(widget.year, widget.month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1));

    _dates = List.generate(
      lastDay.day,
      (i) => DateTime(widget.year, widget.month, i + 1),
    );

    _currentIndex =
        (widget.initialDay != null &&
            widget.initialDay! >= 1 &&
            widget.initialDay! <= lastDay.day)
        ? widget.initialDay! - 1
        : 0;

    _controller = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.25,
    );
  }

  /// 🔹 Wenn sich der initialDay (z. B. durch neuen Monat oder Datumsauswahl) ändert:
  @override
  void didUpdateWidget(covariant DatumRad oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialDay != widget.initialDay ||
        oldWidget.month != widget.month ||
        oldWidget.year != widget.year) {
      // Prüfen, ob der neue Tag im gültigen Bereich liegt
      final newIndex =
          (widget.initialDay != null &&
              widget.initialDay! >= 1 &&
              widget.initialDay! <= _dates.length)
          ? widget.initialDay! - 1
          : 0;

      setState(() => _currentIndex = newIndex);

      // 🔹 Automatisch zu neuem Datum scrollen:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.animateToPage(
            newIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int visibleIndex = _currentIndex; // Sichtbarer Index getrennt verwalten

    return SizedBox(
      height: 70,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: PageView.builder(
          controller: _controller,
          itemCount: _dates.length,
          onPageChanged: (index) {
            // Nur merken, welcher Tag sichtbar ist, aber nichts auswählen
            visibleIndex = index;
          },
          itemBuilder: (context, index) {
            final date = _dates[index];
            final isSelected =
                index == _currentIndex; // Nur wenn wirklich getappt
            final isToday =
                date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;
            return GestureDetector(
              onTap: () {
                setState(() => _currentIndex = index); // Markiere als gewählt
                widget.onDateSelected?.call(_dates[index]);
                _controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.6,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CEDColors.surfaceDark
                        : isToday
                        ? CEDColors.primary
                        : CEDColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: CEDColors.primary.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          const [
                            'Mo',
                            'Di',
                            'Mi',
                            'Do',
                            'Fr',
                            'Sa',
                            'So',
                          ][date.weekday - 1],
                          style: TextStyle(
                            color: isToday ? CEDColors.textPrimary : CEDColors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${date.day}.${date.month}',
                          style: TextStyle(
                            color: isToday ? CEDColors.textPrimary : CEDColors.textPrimary,
                            fontSize: isSelected ? 16 : 14,
                            fontWeight: isSelected
                                ? FontWeight.w900
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
