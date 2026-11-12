import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'studio_components.dart';

Future<void> studioExport(
  BuildContext context, {
  required String name,
  required String text,
  required String extension,
}) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text('Exporter · $name'),
    content: SizedBox(
      width: 600,
      height: 360,
      child: SingleChildScrollView(child: SelectableText(text)),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Fermer'),
      ),
      TextButton.icon(
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: text));
          if (ctx.mounted) studioToast(ctx, 'Contenu copié.');
        },
        icon: const Icon(Icons.copy),
        label: const Text('Copier'),
      ),
      FilledButton.icon(
        onPressed: () async {
          try {
            final result = await FilePicker.saveFile(
              dialogTitle: 'Enregistrer l’export',
              fileName: name,
              type: FileType.custom,
              allowedExtensions: [extension],
              bytes: Uint8List.fromList(utf8.encode(text)),
            );
            if (result != null && ctx.mounted) {
              studioToast(ctx, 'Export enregistré.');
            }
          } catch (_) {
            if (ctx.mounted) {
              studioToast(
                ctx,
                'Enregistrement indisponible. Vous pouvez copier le contenu.',
              );
            }
          }
        },
        icon: const Icon(Icons.download_outlined),
        label: const Text('Enregistrer'),
      ),
    ],
  ),
);
