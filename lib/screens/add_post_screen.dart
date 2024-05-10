import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fasumnay/screens/home_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postTextController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadPost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final postText = _postTextController.text.trim();

      if (postText.isNotEmpty) {
        try {
          final imageURL = await _uploadImage();
          await FirebaseFirestore.instance.collection('posts').add({
            'userId': currentUser.uid,
            'text': postText,
            'imageURL': imageURL,
            'timestamp': Timestamp.now(),
          });
          Navigator.pop(context); // Kembali ke Home Screen setelah berhasil posting
        } catch (error) {
          print('Error uploading post: $error');
        }
      } else {
        // Handle empty post text
        print('Post text cannot be empty');
      }
    }
  }

  Future<String> _uploadImage() async {
    // Simpan gambar ke storage (misalnya Firebase Storage) dan kembalikan URL-nya
    // Contoh penggunaan Firebase Storage:
    // final storageRef = FirebaseStorage.instance.ref().child('post_images').child('image.jpg');
    // final uploadTask = storageRef.putFile(_imageFile!);
    // final snapshot = await uploadTask.whenComplete(() => null);
    // final imageURL = await snapshot.ref.getDownloadURL();
    // return imageURL;

    // Karena kita hanya membuat contoh, kita kembalikan string kosong
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () async {
                await _pickImage(ImageSource.camera);
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _imageFile != null
                    ? Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _postTextController,
              decoration: InputDecoration(
                hintText: 'Write your post...',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadPost,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}