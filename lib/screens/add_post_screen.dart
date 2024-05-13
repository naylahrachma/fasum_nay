import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  TextEditingController _postTextController = TextEditingController();
  String? _imageUrl;

  Future<void> _getImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _imageUrl = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                _getImageFromCamera();
              },
              child: Container(
                height: 200,
                color: Colors.grey[200],
                child: _imageUrl != null
                    ? Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.camera_alt,
                  size: 100,
                  color: Colors.grey[400],
                ),
                alignment: Alignment.center,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _postTextController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Write your post here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Cek apakah ada teks post dan gambar telah dipilih
                if (_postTextController.text.isNotEmpty && _imageUrl != null) {
                  // Menyimpan pos ke Firestore
                  FirebaseFirestore.instance.collection('posts').add({
                    'text': _postTextController.text,
                    'image_url': _imageUrl,
                    'timestamp': Timestamp.now(),
                  }).then((_) {
                    // Jika penyimpanan berhasil, kembali ke layar sebelumnya
                    Navigator.pop(context);
                  }).catchError((error) {
                    // Jika terjadi kesalahan, tampilkan pesan error
                    print('Error saving post: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save post. Please try again.'),
                      ),
                    );
                  });
                } else {
                  // Jika teks post atau gambar tidak tersedia, tampilkan pesan
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please write a post and select an image.'),
                    ),
                  );
                }
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}