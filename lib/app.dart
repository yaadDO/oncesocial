import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/auth/data/firebase_auth_repo.dart';
import 'package:oncesocial/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:oncesocial/features/auth/presentation/cubits/auth_states.dart';
import 'package:oncesocial/features/auth/presentation/pages/auth_page.dart';
import 'package:oncesocial/features/notifications/notification_page.dart';
import 'package:oncesocial/features/post/data/firebase_post_repo.dart';
import 'package:oncesocial/features/profile/data/firebase_profile_repo.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:oncesocial/features/settings/pages/about_page.dart';
import 'package:oncesocial/features/storage/data/firebase_storage_repo.dart';
import 'package:oncesocial/themes/themes_cubit.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/notifications/notifs.dart';
import 'features/post/presentation/cubits/post_cubit.dart';
import 'features/privateMessaging/data/firebase_msg_repo.dart';
import 'features/privateMessaging/presentation/cubits/msg_cubit.dart';
import 'features/privateMessaging/presentation/pages/messaging_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/publicChat/data/firebase_chat_repo.dart';
import 'features/publicChat/presentation/cubits/chat_cubit.dart';
import 'features/publicChat/presentation/pages/chat_page.dart';
import 'features/search/data/firebase_search_repo.dart';
import 'features/search/presentation/cubits/search_cubits.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final firebaseAuthRepo = FirebaseAuthRepo();

  final firebaseProfileRepo = FirebaseProfileRepo();

  final firebaseStorageRepo = FirebaseStorageRepo();

  final firebasePostRepo = FirebasePostRepo();

  final firebaseSearchRepo = FirebaseSearchRepo();

  @override
  void initState() {
    super.initState();
    // Initialize notifications on app startup.
    FirebaseApi.initNotifications();
    FirebaseApi.setupInteractedMessage();
  }

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
        BlocProvider<MsgCubit>(
          create: (context) => MsgCubit(
            msgRepo: FirebaseMsgRepo(),
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
              if (authState is Unauthenticated) return const AuthPage();
              if (authState is Authenticated) return const HomePage();
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              }
              else if (state is Authenticated) {
                final currentUserId = context.read<AuthCubit>().currentUser!.uid;
                context.read<ProfileCubit>().fetchUserProfile(currentUserId);
                FirebaseApi.updateFCMToken();
              }
            },
          ),
          routes: {
            '/AboutPage': (context) => const AboutPage(),
            '/ChatPage': (context) => const ChatPage(),
            '/profile': (context) => ProfilePage(
              uid: ModalRoute.of(context)!.settings.arguments as String,
            ),
            '/NotificationPage': (context) => const NotificationPage(),
            '/MessagingPage': (context) => const MessagingPage(),
          },
        ),
      ),
    );
  }
}
