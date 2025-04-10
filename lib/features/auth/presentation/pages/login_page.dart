//todo implement a button to login with google account
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    _startShakeTimer();
  }

  void _startShakeTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _shakeController.forward(from: 0).then((_) {
          _startShakeTimer(); // Repeat after shake completes
        });
      }
    });
  }

  void login() {
    final l10n = AppLocalizations.of(context);
    final String email = emailController.text;
    final String pw = pwController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.loginError)));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    _shakeController.dispose();
    super.dispose();
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
                const SizedBox(height: 5),
                ClipOval(
                  child: Image.asset(
                    'assets/icon.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 15),
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
                    'assets/google_icon.png',
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SlideTransition(
                        position: _shakeAnimation,
                        child: GestureDetector(
                          onTap: widget.togglePages,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.registerMe,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Icon(
                                Icons.arrow_right,
                                size: 30,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                            ],
                          ),
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