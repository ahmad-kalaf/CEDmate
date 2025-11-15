import 'package:flutter/material.dart';

Future<bool> deleteEntry(
  BuildContext context, {
  required String titel,
  required String text,
  required Future<void> Function() deleteAction,
}) async {
  // Bestätigung anzeigen
  final bestaetigt = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titel),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Abbrechen"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Löschen"),
        ),
      ],
    ),
  );

  if (bestaetigt != true) return false;

  // Aktion ausführen
  try {
    await deleteAction();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("gelöscht")));
    }

    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fehler: $e")));
    }
    return false;
  }
}
