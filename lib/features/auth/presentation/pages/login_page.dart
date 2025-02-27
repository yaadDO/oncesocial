//todo implement a button to login with google account
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/auth/presentation/components/my_button.dart';
import 'package:oncesocial/features/auth/presentation/cubits/auth_cubit.dart';

import '../../../../responsive/constrained_scaffold.dart';
import '../components/my_text_field.dart';

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
    final String email = emailController.text;
    final String pw = pwController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter both email and password')));
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
                  'Welcome',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: pwController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                MyButton(
                  onTap: login,
                  text: 'Login',
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member? ',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        'Register Me',
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
                  'Sign in with Google',
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
