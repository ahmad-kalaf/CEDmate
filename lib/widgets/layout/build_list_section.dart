import 'package:flutter/material.dart';

/// Baut einen Eingabeblock mit Textfeld + Liste
Widget buildListSection({
  required String title,
  required BuildContext context,
  required TextEditingController controller,
  required List<String> items,
  List<String>? suggestions,
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
          Autocomplete<String>(
            onSelected: (option) {
              controller.text = option;
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: options.map((option) {
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },

            optionsBuilder: (text) {
              if (text.text.isEmpty) return [];
              if (suggestions == null) return [];
              return suggestions.where(
                (s) => s.toLowerCase().contains(text.text.toLowerCase()),
              );
            },
            fieldViewBuilder:
                (context, textController, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Eintrag hinzufügen',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Wert in deinen externen Controller kopieren
                      controller.text = textController.text;
                      onAdd();
                      // Beide löschen
                      textController.clear();
                      controller.clear();
                    },
                  ),
                ),
                onChanged: (value) {
                  controller.text = value;
                },
                onFieldSubmitted: (value) {
                  controller.text = value;
                  onAdd();
                  textController.clear();
                  controller.clear();
                },
              );
            },
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
