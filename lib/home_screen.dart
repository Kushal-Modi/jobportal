import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get();
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>?;
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: logout)],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : userData == null
              ? Center(child: Text("User data not found"))
              : userData!['role'] == 'job_seeker'
              ? JobSeekerView()
              : EmployerView(),
    );
  }
}

// Job Seeker View: Display Job Listings
class JobSeekerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No jobs available"));
        }
        return ListView(
          children:
              snapshot.data!.docs.map((doc) {
                var job = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(job['title']),
                  subtitle: Text(job['company']),
                );
              }).toList(),
        );
      },
    );
  }
}

// Employer View: Create Job Form
class EmployerView extends StatefulWidget {
  @override
  _EmployerViewState createState() => _EmployerViewState();
}

class _EmployerViewState extends State<EmployerView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();

  void postJob() async {
    if (titleController.text.isNotEmpty && companyController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': titleController.text,
        'company': companyController.text,
        'createdAt': Timestamp.now(),
      });
      titleController.clear();
      companyController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: "Job Title"),
          ),
          TextField(
            controller: companyController,
            decoration: InputDecoration(labelText: "Company Name"),
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: postJob, child: Text("Post Job")),
        ],
      ),
    );
  }
}
