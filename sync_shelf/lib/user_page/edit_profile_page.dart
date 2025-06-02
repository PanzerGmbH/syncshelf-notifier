import 'dart:io'; // Import für Datei-Verarbeitung
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import für Bilder-Auswahl
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EditProfilePageWidget extends StatefulWidget {
  final String currentUsername;
  final String currentProfileImage;



  const EditProfilePageWidget({
    super.key,
    required this.currentUsername,
    required this.currentProfileImage,
  });

  @override
  State<EditProfilePageWidget> createState() => _EditProfilePageWidgetState();
}

class _EditProfilePageWidgetState extends State<EditProfilePageWidget> {
  late TextEditingController _usernameController;
  late TextEditingController _profileImageController;
  File? _selectedImage; // Variable für das ausgewählte Bild

  Future<void> _updateUserProfile() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update({
        'name': _usernameController.text,
        'profileImage': _selectedImage != null ? _selectedImage!.path : _profileImageController.text,
      });

      Navigator.pop(context, {
        'name': _usernameController.text,
        'profileImage': _selectedImage != null ? _selectedImage!.path : _profileImageController.text,
      });

    }
  }


  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    _profileImageController = TextEditingController(text: widget.currentProfileImage);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }

  //  Funktion, um ein Bild aus der Galerie auszuwählen
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            //  Profilbild-Anzeige mit Galerie-Funktion
            GestureDetector(
              onTap: _pickImage, // Öffnet die Galerie
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!) as ImageProvider
                    : NetworkImage(widget.currentProfileImage),
                child: _selectedImage == null
                    ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 10),

            // Eingabefeld für den Benutzernamen
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "name"),
            ),
            SizedBox(height: 20),

            // Speichern-Button
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text("Save Changes"),
            ),

          ],
        ),
      ),
    );
  }
}
