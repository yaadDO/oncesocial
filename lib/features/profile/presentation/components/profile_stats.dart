import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;
  final void Function()? onTap;

  const ProfileStats({
      super.key,
      required this.postCount,
      required this.followerCount,
      required this.followingCount,
      required this.onTap,
      });

  @override
  Widget build(BuildContext context) {
    var textStyleForCount = TextStyle(
        fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary);

    var textStyleForText =
        TextStyle(color: Theme.of(context).colorScheme.inversePrimary);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  postCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  'Posts',
                  style: textStyleForText,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  followerCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  'Followers',
                  style: textStyleForText,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  followingCount.toString(),
                  style: textStyleForCount,
                ),
                Text(
                  'Following',
                  style: textStyleForText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
