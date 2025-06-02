import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FriendRequestsPage extends StatefulWidget {
  @override
  _FriendRequestsPageState createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {

  // 🔥 Anfrage akzeptieren und Freund hinzufügen
  void acceptRequest(String requestId, String senderEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Anfrage als "accepted" markieren
      await FirebaseFirestore.instance.collection('friend requests').doc(requestId).update({
        "status": "accepted"
      });

      // Beide User in die Freunde-Liste aufnehmen
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        "friends": FieldValue.arrayUnion([senderEmail])
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Friend request accepted!"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
      );
    }
  }

  // ❌ Anfrage ablehnen
  void declineRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('friend requests').doc(requestId).update({
        "status": "declined"
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Friend request declined!"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Friend Requests"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // Zurück zur friends.dart Seite
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend requests')
            .where('receiver', isEqualTo: currentUser?.email)
            .where('status', isEqualTo: "pending") // Nur offene Anfragen anzeigen
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var requests = snapshot.data!.docs;

          if (requests.isEmpty) return Center(child: Text("No pending requests."));

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              var requestData = request.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(requestData['sender']),
                subtitle: Text("wants to be your friend"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        acceptRequest(request.id, requestData['sender']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        declineRequest(request.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
