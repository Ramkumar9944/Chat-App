import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() {
    return NewMessageState();
  }
}

class NewMessageState extends State<NewMessage> {
  late TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMessage = messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    messageController.clear();

    final currentUser = firebase.currentUser!;
    try {
      final userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>;

        FirebaseFirestore.instance.collection("chat").add({
          "text": enteredMessage,
          "created_at": Timestamp.now(),
          "userId": currentUser.uid,
          "username": data["username"],
          "userImage": data["image_url"],
        });
      } else {
        // Handle the case where user data does not exist
        print("User data does not exist ${currentUser.uid}");
      }
    } catch (error) {
      // Handle any errors that occur during Firestore operations
      print("Error submitting message: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: "Send Message"),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: submitMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
