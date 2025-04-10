////todo implement a button to register with google account
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/auth/presentation/components/my_button.dart';
import '../../../../web/constrained_scaffold.dart';
import '../components/my_text_field.dart';
import '../cubits/auth_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;

  const RegisterPage({
    super.key,
    required this.togglePages
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();
  late AnimationController _shakeController;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Modified shake animation to go left
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.1, 0), // Changed to negative value for left movement
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);

    // Start repeating the shake every 3 seconds
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

  void register() {
    final l10n = AppLocalizations.of(context);
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty &&
        name.isNotEmpty &&
        pw.isNotEmpty &&
        confirmPw.isNotEmpty) {

      if(pw == confirmPw) {
        authCubit.register(name, email, pw);
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.passwordsMismatch)));
      }
    }

    else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).completeAllFields)));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
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
                  l10n.joinCult,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 9),

                MyTextField(
                  controller: nameController,
                  hintText: l10n.username,
                  obscureText: false,
                ),

                const SizedBox(height: 5),

                MyTextField(
                  controller: emailController,
                  hintText: l10n.email, // Fixed: Changed from confirmPassword to email
                  obscureText: false,
                ),

                const SizedBox(height: 5),

                MyTextField(
                  controller: pwController,
                  hintText: l10n.password,
                  obscureText: true,
                ),

                const SizedBox(height: 5),

                MyTextField(
                  controller: confirmPwController,
                  hintText: l10n.confirmPassword,
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                MyButton(
                  onTap: register,
                  text: l10n.register,
                ),

                const SizedBox(height: 10),

                IconButton(
                  onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                  icon: Image.asset(
                    'assets/google_icon.png',
                    width: 37,
                    height: 37,
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
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SlideTransition(
                        position: _shakeAnimation,
                        child: GestureDetector(
                          onTap: widget.togglePages,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_left,
                                size: 30,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                              Text(
                                l10n.loginNow,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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