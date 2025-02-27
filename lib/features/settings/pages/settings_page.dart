import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/themes/themes_cubit.dart';
import '../../../responsive/constrained_scaffold.dart';
import '../../auth/presentation/cubits/auth_cubit.dart';
import 'package:share_plus/share_plus.dart';

import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    bool isDarkMode = themeCubit.isDarkMode;

    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(4, 1, 4, 4),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Dark mode',
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
                'Share',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              trailing: Icon(Icons.share),
              onTap: () => Share.share('com.once.oncesocial.oncesocial'),
            ),
            ListTile(
                title: Text(
                  'About',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                trailing: Icon(Icons.info_outline),
                onTap: () {
                  Navigator.of(context).push(_createRoute());
                }
            ),
            const Spacer(),
            ListTile(
                title: Text(
                  'Logout',
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
                        title: const Text('Are you sure?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Logout'),
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