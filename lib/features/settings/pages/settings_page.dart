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
    //Manages theme cubit
    //context.watch<ThemeCubit>() Retrieves the current instance of ThemeCubit and listens for any changes in the theme state.
    final themeCubit = context.watch<ThemeCubit>();

    bool isDarkMode = themeCubit.isDarkMode;
    //A boolean value indicating whether dark mode is currently enabled.

    return ConstrainedScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 4, 4),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Dark mode',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              //A CupertinoSwitch (iOS-style switch)
              //When the switch is toggled, the toggleTheme() method in ThemeCubit is called to switch between dark and light themes.
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
              trailing: Icon(Icons.logout),
              onTap: () => context.read<AuthCubit>().logout(),
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

