import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;

  const FollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(25),
            backgroundColor: isFollowing
                ? Theme.of(context).colorScheme.secondary
                : Colors.lightBlue.shade300,
          ),
          icon: Icon(
            isFollowing ? Icons.person_remove_alt_1_outlined : Icons.add_reaction,
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 30,
          ),
          label: Text(
            isFollowing ? l10n.kick : l10n.follow,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        )
      ),
    );
  }
}
