import 'package:eco_system_things/classes/Manager.dart';
import 'package:eco_system_things/classes/UserManager.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final postsList = Manager().posts;
    final groupes = UserManager().groupes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Color(0xFF98ddd8),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: groupes.length,
          itemBuilder: (context, index) {
            final post = postsList[groupes[index]];
            if (post == null)
              return const SizedBox.shrink();
            return post.chatTile();
          },
        ),
      ),
    );
  }
}
