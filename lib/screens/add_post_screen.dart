import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart'; // Tambahkan ini

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  TextEditingController _postTextController = TextEditingController();
  String? _imageUrl;
  XFile? _image;
  final User? user = FirebaseAuth.instance.currentUser;
  Position? _currentPosition; // Untuk menyimpan lokasi saat ini
  bool _isLoading = false; // Untuk menampilkan indikator pemuatan

  Future<void> _getImageFromCamera() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _image = image;
        });

        // Upload image and get URL if not on web
        if (!kIsWeb) {
          String? imageUrl = await _uploadImage(image);
          setState(() {
            _imageUrl = imageUrl;
          });
        } else {
          setState(() {
            _imageUrl = image.path;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar. Silakan coba lagi.'),
        ),
      );
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('post_images').child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Minta izin lokasi dari pengguna
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Layanan lokasi tidak aktif. Harap aktifkan layanan lokasi.'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Izin lokasi ditolak. Tidak bisa mengambil lokasi.'),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin lokasi secara permanen ditolak. Tidak bisa mengambil lokasi.'),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil lokasi. Silakan coba lagi.'),
        ),
      );
    }
  }

  Future<void> _savePost() async {
    if (_postTextController.text.isNotEmpty && _image != null) {
      setState(() {
        _isLoading = true;
      });

      if (_imageUrl == null) {
        _imageUrl = await _uploadImage(_image!);
      }

      if (_imageUrl != null) {
        try {
          await FirebaseFirestore.instance.collection('posts').add({
            'text': _postTextController.text,
            'image_url': _imageUrl,
            'timestamp': Timestamp.now(),
            'username': user?.email ?? 'Naylah Rachma Sari',
            'userId': user?.uid,
            'latitude': _currentPosition?.latitude, // Menyimpan latitude
            'longitude': _currentPosition?.longitude, // Menyimpan longitude
          });

          Navigator.pop(context);
        } catch (error) {
          print('Error saving post: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan postingan. Silakan coba lagi.'),
            ),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunggah gambar. Silakan coba lagi.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan tulis postingan dan pilih gambar.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Postingan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _getImageFromCamera,
              child: Container(
                height: 200,
                color: Colors.grey[200],
                child: _image != null
                    ? kIsWeb
                    ? Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  File(_image!.path),
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
                hintText: 'Tulis postingan Anda di sini...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading // Menampilkan indikator pemuatan jika proses berlangsung
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () async {
                await _getCurrentLocation(); // Ambil lokasi saat ini
                _savePost();
              },
              child: Text('Posting'),
            ),
          ],
        ),
      ),
    );
  }
}