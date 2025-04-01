import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../web/constrained_scaffold.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedScaffold(
      appBar: AppBar(
        title: Text(l10n.about),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.releaseDate}: TBD'),
            const SizedBox(height: 5,),
            Text('${l10n.version}: 1.1'),
            const SizedBox(height: 5,),
            Text('${l10n.publishedBy}: Once Software'),
          ],
        ),
      ),
    );
  }
}
