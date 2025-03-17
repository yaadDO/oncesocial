//Allows users to edit their profile information, including their profile image and bio.
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/profile/presentation/cubits/profile_states.dart';
import '../../../../web/constrained_scaffold.dart';
import '../../../auth/presentation/components/my_text_field.dart';
import '../../domain/entities/profile_user.dart';
import '../cubits/profile_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class EditProfilePage extends StatefulWidget {
  //Provides the current user details
  final ProfileUser user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //Stores the image file selected by the user
  PlatformFile? imagePickedFile;

  //Stores the image data in bytes for webPlatforms
  Uint8List? webImage;

  final bioTextController = TextEditingController();

  //Opens a file picker for users to select an image.
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      //Sets imagePickedFile for mobile platforms and webImage for web platforms.
      setState(() {
        imagePickedFile = result.files.first;

        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  //Gathers the updated bio and image data and calls the ProfileCubit's updateProfile method.
  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final String uid = widget.user.uid;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    } else {
      //Navigates back if no changes are detected
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        //Displays a loading indicator when ProfileState is ProfileLoading
        if (state is ProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text(AppLocalizations.of(context).uploading),
                ],
              ),
            ),
          );
        } else {
          //Shows the EditProfilePage when not loading.
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  //Displays the selected image if available or the current profile image using CachedNetworkImage.
  Widget buildEditPage() {
    return ConstrainedScaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: updateProfile,
          child: const Icon(Icons.save),
      ),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).editProfile,
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              //clipBehavior: Ensures that the image stays within the circular shape defined in the BoxDecoration of the container.
              //Crops any overflowing parts of the image to maintain a clean, circular profile picture
              clipBehavior: Clip.hardEdge,
              child:
                  //Determines the image source based on web or mobile
                  //mobile
                  (!kIsWeb && imagePickedFile != null)
                      ? Image.file(
                          File(imagePickedFile!.path!),
                          fit: BoxFit.cover,
                        )
                      :

                      //web
                      (kIsWeb && webImage != null)
                          ? Image.memory(
                              webImage!,
                              fit: BoxFit.cover,
                            )
                      //CachedNetworkImage: Displays the profile image from a network URL
                          : CachedNetworkImage(
                              imageUrl: widget.user.profileImageUrl,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 72,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              imageBuilder: (context, imageProvider) => Image(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: Text(AppLocalizations.of(context).pickImage),
            ),
          ),
          Text(AppLocalizations.of(context).bio),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
              controller: bioTextController,
              hintText: widget.user.bio,
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }
}
