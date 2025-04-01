import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),

      width: double.infinity,

      child: Text(
        text.isNotEmpty ? text : l10n.emptybio,
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
    );
  }
}
