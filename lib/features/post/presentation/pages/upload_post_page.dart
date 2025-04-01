import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/components/my_text_field.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../domain/entities/post.dart';
import '../cubits/post_cubit.dart';
import '../cubits/post_state.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final textController = TextEditingController();
  AppUser? currentUser;
  bool isTextPost = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  void uploadPost() {
    final l10n = AppLocalizations.of(context);
    if (isTextPost) {
      if (textController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.textRequired)),
        );
        return;
      }
    } else {
      if (imagePickedFile == null || textController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.bothRequired)),
        );
        return;
      }
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: '', // For a text post, imageUrl is empty.
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    final postCubit = context.read<PostCubit>();

    if (!isTextPost) {
      if (kIsWeb) {
        postCubit.createPost(newPost, imageBytes: imagePickedFile!.bytes);
      } else {
        postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
      }
    } else {
      postCubit.createPost(newPost);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostUploading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          // Once the posts are loaded, redirect to the HomePage.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
          );
        } else if (state is PostsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
    );
  }

  Widget buildUploadPage() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTextPost ? l10n.textPost : l10n.imagePost,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isTextPost ? Icons.image_rounded : Icons.text_fields_rounded,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 35,
            ),
            tooltip: isTextPost ? l10n.textPost : l10n.imagePost,
            onPressed: () {
              setState(() {
                isTextPost = !isTextPost;
                if (isTextPost) {
                  imagePickedFile = null;
                  webImage = null;
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 5),
              child: Column(
                children: [
                  if (!isTextPost) ...[
                    if (kIsWeb && webImage != null) Image.memory(webImage!),
                    if (!kIsWeb && imagePickedFile != null)
                      Image.file(File(imagePickedFile!.path!)),
                    IconButton(
                      onPressed: pickImage,
                      icon: Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MyTextField(
                      controller: textController,
                      obscureText: false,
                      hintText: isTextPost
                          ? l10n.whatsHappening
                          : l10n.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (context.watch<PostCubit>().state is PostUploading ||
              context.watch<PostCubit>().state is PostsLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadPost,
        child: Icon(
          Icons.upload,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
