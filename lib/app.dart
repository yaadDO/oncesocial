import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/auth/data/firebase_auth_repo.dart';
import 'package:oncesocial/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:oncesocial/features/auth/presentation/cubits/auth_states.dart';
import 'package:oncesocial/features/auth/presentation/pages/auth_page.dart';
import 'package:oncesocial/features/post/data/firebase_post_repo.dart';
import 'package:oncesocial/features/profile/data/firebase_profile_repo.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:oncesocial/features/settings/pages/about_page.dart';
import 'package:oncesocial/features/storage/data/firebase_storage_repo.dart';
import 'package:oncesocial/themes/themes_cubit.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/post/presentation/cubits/post_cubit.dart';
import 'features/publicChat/data/firebase_chat_repo.dart';
import 'features/publicChat/presentation/cubits/chat_cubit.dart';
import 'features/publicChat/presentation/pages/chat_page.dart';
import 'features/search/data/firebase_search_repo.dart';
import 'features/search/presentation/cubits/search_cubits.dart';

class MyApp extends StatelessWidget {
  final firebaseAuthRepo = FirebaseAuthRepo();

  final firebaseProfileRepo = FirebaseProfileRepo();

  final firebaseStorageRepo = FirebaseStorageRepo();

  final firebasePostRepo = FirebasePostRepo();

  final firebaseSearchRepo = FirebaseSearchRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) =>
              AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(
            chatRepo: FirebaseChatRepo(profileRepo: firebaseProfileRepo),
          ),
        ),
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasePostRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(searchRepo: firebaseSearchRepo),
        ),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, currentTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: currentTheme,
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              print(authState);
              if (authState is Unauthenticated) {
                return const AuthPage();
              }

              if (authState is Authenticated) {
                return const HomePage();
              } else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
          ),
          routes: {
            '/AboutPage': (context) => const AboutPage(),
            '/ChatPage': (context) => const ChatPage(),
          },
        ),
      ),
    );
  }
}
