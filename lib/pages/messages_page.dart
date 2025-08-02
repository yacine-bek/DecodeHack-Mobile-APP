import 'package:eco_system_things/classes/Manager.dart';
import 'package:eco_system_things/classes/UserManager.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groupes = UserManager().groupes;
    print(groupes);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Color(0xFF98ddd8),
      ),
      body: Center(
        child: groupes.isEmpty
            ? const Text(
                'You are not in any group yet',
                style: TextStyle(fontSize: 16),
              )
            : ListView.builder(
                itemCount: groupes.length,
                itemBuilder: (context, index) {
                  final post = Manager().posts[groupes[index]];
                  if (post == null) return const SizedBox.shrink();
                  return post.chatTile();
                },
              ),
      ),
    );
  }
}
