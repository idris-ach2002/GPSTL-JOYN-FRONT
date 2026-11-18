import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';

Future<void> showPdfPreview(
  BuildContext context,
  ApiClient api,
  String path,
  String title,
) => showDialog<void>(
  context: context,
  builder: (_) => _PdfPreview(api: api, path: path, title: title),
);

class _PdfPreview extends StatefulWidget {
  const _PdfPreview({
    required this.api,
    required this.path,
    required this.title,
  });
  final ApiClient api;
  final String path;
  final String title;

  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  int _page = 1;
  int _total = 0;
  late Future<Image> _image;

  @override
  void initState() {
    super.initState();
    _image = _fetch();
  }

  Future<Image> _fetch() async {
    final page = _page;
    final result =
        await widget.api.getJson(widget.path, query: {'page': '$page'}) as Map;
    final bytes = base64Decode(result['pngBase64'] as String);
    if (mounted && page == _page) {
      setState(() => _total = result['totalPages'] as int);
    }
    return Image.memory(
      bytes,
      fit: BoxFit.contain,
      semanticLabel: '${widget.title}, page $page',
    );
  }

  void _navigate(int page) => setState(() {
    _page = page;
    _image = _fetch();
  });

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
        width: 850,
        height: viewport.height * .9,
        child: Column(
          children: [
            ListTile(
              title: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: 'Fermer',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _image,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: TextButton(
                        onPressed: () => _navigate(_page),
                        child: const Text('PDF indisponible · Réessayer'),
                      ),
                    );
                  }
                  return ColoredBox(
                    color: Colors.grey.shade200,
                    child: InteractiveViewer(
                      key: ValueKey(_page),
                      minScale: 1,
                      maxScale: 5,
                      child: Center(child: snapshot.data!),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Page précédente',
                  onPressed: _page > 1 ? () => _navigate(_page - 1) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(_total == 0 ? 'Page $_page' : 'Page $_page / $_total'),
                IconButton(
                  tooltip: 'Page suivante',
                  onPressed: _page < _total ? () => _navigate(_page + 1) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
