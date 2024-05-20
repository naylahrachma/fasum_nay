import 'package:flutter/material.dart';
import 'package:fasumnay/screens/add_post_screen.dart';
import 'package:fasumnay/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final postData = post.data() as Map<String, dynamic>;
              final imageUrl = postData['image_url'] ?? '';
              final postText = postData['text'] ?? '';
              final timestamp = postData['timestamp'] as Timestamp;
              final formattedTime = DateFormat.yMMMd().add_jm().format(timestamp.toDate());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(imageUrl)
                          : const Icon(Icons.image_not_supported),
                      const SizedBox(height: 8.0),
                      Text('Posted by User', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(formattedTime, style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8.0),
                      Text(postText),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Fasum Nay'),
            ),
            ListTile(
              title: const Text('Sign Out'),
              onTap: () {
                _signOut(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}