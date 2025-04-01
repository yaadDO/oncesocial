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

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                ClipOval(
                  child: Image.asset(
                    'assets/icon.png', // Path to the image asset
                    width: 100, // Adjust the size as needed
                    height: 100,
                    fit: BoxFit.cover, // Ensures the image covers the circular area
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
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.notMember,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        l10n.registerMe,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                IconButton(
                  onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                  icon: Image.asset(
                    'assets/google_icon.png', // Add this asset to your project
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
