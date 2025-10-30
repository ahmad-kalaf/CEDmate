import 'dart:ui';
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

    final firstDay = DateTime(widget.year, widget.month, 1);
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
    return SizedBox(
      height: 100,
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
            setState(() => _currentIndex = index);
            widget.onDateSelected?.call(_dates[index]);
          },
          itemBuilder: (context, index) {
            final date = _dates[index];
            final isSelected = index == _currentIndex;
            final isToday =
                date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year;

            return GestureDetector(
              onTap: () {
                /// wenn auf ein datum geklickt wird, dieses auswählen und dahin scrollen
                _controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentIndex = index);
                widget.onDateSelected?.call(_dates[index]);
              },
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 300),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.blueAccent
                        : isSelected
                        ? Colors.blue[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue,
                              blurRadius: 8,
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
                            color: isToday ? Colors.white : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}.${date.month}',
                          style: TextStyle(
                            color: isToday ? Colors.white : Colors.black,
                            fontSize: isSelected ? 22 : 18,
                            fontWeight: isSelected
                                ? FontWeight.bold
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
