import 'package:flutter/material.dart';

/// Baut einen Eingabeblock mit Textfeld + Liste
Widget buildListSection({
  required String title,
  required BuildContext context,
  required TextEditingController controller,
  required List<String> items,
  required VoidCallback onAdd,
  required void Function(String) onRemove,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Eintrag hinzufügen',
              border: const UnderlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: onAdd,
                tooltip: 'Hinzufügen',
              ),
            ),
            onFieldSubmitted: (_) => onAdd(),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Card(
              elevation: 2,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onRemove(item),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
