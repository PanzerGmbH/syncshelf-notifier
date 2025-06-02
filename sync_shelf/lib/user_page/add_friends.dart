import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddFriendWidget extends StatefulWidget {
  const AddFriendWidget({super.key});

  @override
  State<AddFriendWidget> createState() => _AddFriendWidgetState();
}

class _AddFriendWidgetState extends State<AddFriendWidget> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔥 Freunde per E-Mail hinzufügen
  void addFriendByEmail(String friendEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    try {
      // Überprüfen, ob der Freund existiert
      final friendQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('profile.email', isEqualTo: friendEmail)
          .get();

      if (friendQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User not found!"))
        );
        return;
      }

      // Freund zur Liste hinzufügen (E-Mail speichern)



      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Friend added!"))
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
      );
    }
  }

  void sendFriendRequest(String receiverEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Prüfen, ob bereits eine offene Anfrage existiert
      var existingRequest = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('sender', isEqualTo: currentUser.email)
          .where('receiver', isEqualTo: receiverEmail)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Friend request already sent!"))
        );
        return;
      }

      // Freundschaftsanfrage erstellen
      await FirebaseFirestore.instance.collection('friend_requests').add({
        "sender": currentUser.email,
        "receiver": receiverEmail,
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Friend request sent!"))
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Friends"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/friends'); // Zurück zur friends.dart Seite
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Suchleiste für Namen
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter friend\'s name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
            SizedBox(height: 20),

            // 🔍 Benutzerliste basierend auf Namen in Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: (searchQuery.isEmpty)
                    ? FirebaseFirestore.instance.collection('users').snapshots() // Falls leer, alle Nutzer laden
                    : FirebaseFirestore.instance
                    .collection('users')
                    .where('profile.name', isGreaterThanOrEqualTo: searchQuery)
                    .where('profile.name', isLessThanOrEqualTo: searchQuery + '\uf8ff') // Unicode-Trick für Name-Suche
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text('Search for users...'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No users found.'));
                  }

                  var users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      var userData = user.data() as Map<String, dynamic>;
                      var profile = userData['profile'] ?? {};

                      return ListTile(
                        title: Text(profile['name'] ?? 'No Name'),
                        subtitle: Text(profile['email'] ?? 'No Email'),
                        trailing: IconButton(
                          icon: Icon(Icons.person_add),
                          onPressed: () {
                            sendFriendRequest(profile['email']);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
