import 'package:flutter/material.dart';
import 'package:oncesocial/features/auth/presentation/pages/login_page.dart';
import 'package:oncesocial/features/auth/presentation/pages/register_page.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool showLoginPage = true;
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;
  Widget? _oldPage;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _audioPlayer = AudioPlayer();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _oldPage = null;
          _controller.reset();
        });
      }
    });
  }

  void togglePages() {
    if (_controller.isAnimating) return;

    _audioPlayer.play(AssetSource('sounds/flip.mp3'));
    final oldShowLogin = showLoginPage;
    final isForward =
        !oldShowLogin; // Determine direction based on current page

    setState(() {
      showLoginPage = !oldShowLogin;
      _isForward = isForward;
      _oldPage = oldShowLogin
          ? LoginPage(
              key: const ValueKey('login'),
              togglePages: togglePages,
            )
          : RegisterPage(
              key: const ValueKey('register'),
              togglePages: togglePages,
            );
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildFlipAnimation(Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        );

        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY((_isForward ? 1 : -1) * animation.value * pi / 1.5)
          ..translate(
            animation.value * 50 * (_isForward ? 1 : -1),
            // Modified Y translation
            animation.value * 20 * (_isForward ? 1 : -1),
            animation.value * 100,
          );

        return Transform(
          transform: matrix,
          alignment: _isForward ? Alignment.centerLeft : Alignment.centerRight,
          child: Opacity(
            opacity: 1 - animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        showLoginPage
            ? LoginPage(
                key: const ValueKey('login-main'),
                togglePages: togglePages,
              )
            : RegisterPage(
                key: const ValueKey('register-main'),
                togglePages: togglePages,
              ),
        if (_oldPage != null)
          IgnorePointer(
            child: _buildFlipAnimation(_oldPage!),
          ),
      ],
    );
  }
}
