import 'package:cedmate/models/c_e_d_wissen.dart';
import 'package:cedmate/widgets/ced_layout.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WissenBeitragScreen extends StatelessWidget {
  final CEDWissen beitrag;

  const WissenBeitragScreen({super.key, required this.beitrag});

  @override
  Widget build(BuildContext context) {
    return CEDLayout(
      showDrawer: false,
      title: beitrag.titel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopContent(beitrag: beitrag),

          const SizedBox(height: 16),

          if (beitrag.format == WissenFormat.video) ...[
            Text(
              beitrag.beschreibung.isNotEmpty
                  ? beitrag.beschreibung
                  : 'Keine Beschreibung vorhanden',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 12),

          Text(
            beitrag.contentText ?? 'Kein Inhalt vorhanden',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (beitrag.fachgesellschaftLinks != null &&
              beitrag.fachgesellschaftLinks!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Quellen', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: beitrag.fachgesellschaftLinks!.map((url) {
                return InkWell(
                  onTap: () => _openUrl(url),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      url,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _TopContent extends StatelessWidget {
  final CEDWissen beitrag;

  const _TopContent({required this.beitrag});

  bool get hasVideo =>
      beitrag.contentUrl != null &&
      beitrag.contentUrl!.isNotEmpty &&
      beitrag.format == WissenFormat.video;

  @override
  Widget build(BuildContext context) {
    if (hasVideo) {
      return _VideoPlaceholder(url: beitrag.contentUrl!);
    }

    return _DescriptionCard(text: beitrag.beschreibung);
  }
}

class _DescriptionCard extends StatelessWidget {
  final String text;

  const _DescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 10 / 3, // ⬅️ quadratisch
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text.isNotEmpty ? text : 'Kein Video verfügbar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final String url;

  const _VideoPlaceholder({required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
        ),
      ),
    );
  }
}
