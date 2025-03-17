import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/themes/themes_cubit.dart';
import '../../../web/constrained_scaffold.dart';
import '../../auth/presentation/cubits/auth_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeCubit = context.watch<ThemeCubit>();
    bool isDarkMode = themeCubit.isDarkMode;

    return ConstrainedScaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(4, 1, 4, 4),
        child: Column(
          children: [
            ListTile(
              title: Text(
                l10n.darkMode,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              trailing: CupertinoSwitch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeCubit.toggleTheme();
                  }),
            ),
            const SizedBox(height: 5),
            ListTile(
              title: Text(
                l10n.share,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              trailing: const Icon(Icons.share),
              onTap: () => Share.share('com.once.oncesocial'),
            ),
            ListTile(
                title: Text(
                  l10n.about,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                trailing: const Icon(Icons.info_outline),
                onTap: () {
                  Navigator.of(context).push(_createRoute());
                }
            ),
            const Spacer(),
            ListTile(
                title: Text(
                  l10n.logout,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                trailing: const Icon(Icons.logout),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(l10n.confirmLogout),
                        actions: <Widget>[
                          TextButton(
                            child: Text(l10n.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(l10n.logout),
                            onPressed: () {
                              context.read<AuthCubit>().logout();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const AboutPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const blueBackground = Color(0xFF607D8B); // Blue color
      final scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      );

      return Stack(
        children: [
          FadeTransition(
            opacity: animation,
            child: Container(
              color: blueBackground,
            ),
          ),
          ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        ],
      );
    },
    transitionDuration: const Duration(milliseconds: 1000),
  );
}