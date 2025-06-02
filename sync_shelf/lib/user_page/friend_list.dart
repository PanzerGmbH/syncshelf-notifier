import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FriendListWidget extends StatefulWidget {
  @override
  _FriendListWidgetState createState() => _FriendListWidgetState();
}

class _FriendListWidgetState extends State<FriendListWidget> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Friends"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/friends'); // Zurück zur friends.dart Seite
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>;
          var friends = userData['friends'] ?? [];

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('users')
                    .where('profile.email', isEqualTo: friends[index]).get(),
                builder: (context, friendSnapshot) {
                  if (!friendSnapshot.hasData || friendSnapshot.data!.docs.isEmpty) return Container();
                  var friendData = friendSnapshot.data!.docs.first.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(friendData['profile']['name']),
                    subtitle: Text(friendData['profile']['email']),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
