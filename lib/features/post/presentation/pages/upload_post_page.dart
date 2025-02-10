import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/components/my_text_field.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
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

  // Add a flag to indicate which post type the user wants to create.
  // When true, we will create a text post (no image)
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
    // For a text post, we require text input; for an image post, both are required.
    if (isTextPost) {
      if (textController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Text is required for a text post')),
        );
        return;
      }
    } else {
      if (imagePickedFile == null || textController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Both image and caption are required')),
        );
        return;
      }
    }

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      // For a text post, imageUrl is an empty string.
      imageUrl: isTextPost ? '' : '',
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
      // For text posts, you can simply call createPost without an image.
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
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
      },
    );
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTextPost ? 'Text Post' : 'Image Post',
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
            tooltip: isTextPost ? 'Switch to Image Post' : 'Switch to Text Post',
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
                      hintText:
                      isTextPost ? 'What\'s happening?' : 'Caption',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overlay the loading indicator if uploading
          if (context.watch<PostCubit>().state is PostUploading ||
              context.watch<PostCubit>().state is PostsLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
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
