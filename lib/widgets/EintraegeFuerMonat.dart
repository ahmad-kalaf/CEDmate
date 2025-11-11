import 'package:flutter/material.dart';
import '../utils/monat_jahr_auswahl.dart';

class EintraegeFuerMonat<T> extends StatefulWidget {
  final String title;
  final Stream<List<T>> Function(int month, int year) streamProvider;
  final Widget Function(BuildContext context, T element, int index) itemBuilder;

  const EintraegeFuerMonat({
    super.key,
    required this.title,
    required this.streamProvider,
    required this.itemBuilder,
  });

  @override
  State<EintraegeFuerMonat<T>> createState() => _EintraegeFuerMonatState<T>();
}

class _EintraegeFuerMonatState<T> extends State<EintraegeFuerMonat<T>> {
  DateTime _filterDatum = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: StreamBuilder<List<T>>(
                stream: widget.streamProvider(
                  _filterDatum.month,
                  _filterDatum.year,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Fehler: ${snapshot.error}'),
                    );
                  }
                  final data = snapshot.data ?? [];
                  if (data.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(child: Text('Keine Einträge gefunden.')),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemCount: data.length,
                    itemBuilder: (context, index) =>
                        widget.itemBuilder(context, data[index], index),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Card(
        child: MonatJahrAuswahl(
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          showResetButton: true,
          onChanged: (date) => setState(() => _filterDatum = date),
          onReset: (date) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Filter zurückgesetzt auf ${date.month}.${date.year}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            setState(() => _filterDatum = date);
          },
        ),
      ),
    );
  }
}
