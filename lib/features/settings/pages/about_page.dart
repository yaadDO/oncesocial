import 'package:flutter/material.dart';

import '../../../responsive/constrained_scaffold.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: Text('ABOUT'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Release Date: TBD'),
            SizedBox(height: 5),
            Text('Version: 1.1'),
            SizedBox(height: 5),
            Text('Published by: Once Software'),
          ],
        ),
      ),
    );
  }
}
