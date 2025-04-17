import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:oncesocial/features/auth/presentation/components/my_button.dart';
import 'package:oncesocial/features/auth/presentation/cubits/auth_cubit.dart';
import '../../../../web/constrained_scaffold.dart';
import '../components/my_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;

  const LoginPage({
    super.key,
    required this.togglePages,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  late AnimationController _owlController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _owlController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _playOwlAnimation();

    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _playOwlAnimation();
    });
  }

  void _playOwlAnimation() {
    _owlController
      ..reset()
      ..forward();
  }

  void login() {
    final l10n = AppLocalizations.of(context);
    final String email = emailController.text;
    final String pw = pwController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.loginError)));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    _owlController.dispose();
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _playOwlAnimation,
                  child: Lottie.asset(
                    'assets/animations/owl.json',
                    controller: _owlController,
                    width: 225,
                    height: 225,
                    fit: BoxFit.contain,
                    repeat: false,
                    animate: false,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error loading animation: $error');
                    },
                  ),
                ),
                Text(
                  l10n.welcome,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: l10n.email,
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: pwController,
                  hintText: l10n.password,
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                MyButton(
                  onTap: login,
                  text: l10n.login,
                ),
                const SizedBox(height: 25),
                IconButton(
                  onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                  icon: Image.asset(
                    'assets/images/google_icon.png',
                    width: 32,
                    height: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.signInWithGoogle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GestureDetector(
                        onTap: widget.togglePages,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IgnorePointer(
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  WavyAnimatedText(
                                    '${l10n.registerMe} >' ,
                                    textStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                    speed: const Duration(milliseconds: 200),
                                  ),
                                ],
                                repeatForever: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
