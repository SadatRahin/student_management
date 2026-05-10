/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Use your working local IP
const String baseUrl = "http://192.168.100.151:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // Start at Login
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save to SharedPreferences (Mobile equivalent of localStorage)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);

        if (!mounted) return;

        // Navigate based on role
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

// --- 2. STUDENT DASHBOARD (Fetches My Subjects) ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUserDataAndFetchSubjects();
  }

  Future<void> loadUserDataAndFetchSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('userEmail') ?? "";

    if (email.isNotEmpty) {
      try {
        // Adjust this endpoint if your Spring Boot controller uses a different path for getMySubjects
        final response = await http.get(
          Uri.parse("$baseUrl/my-subjects?email=$email"),
        );
        if (response.statusCode == 200) {
          setState(() {
            mySubjects = json.decode(response.body);
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mySubjects.isEmpty
          ? const Center(child: Text("No subjects assigned yet."))
          : ListView.builder(
              itemCount: mySubjects.length,
              itemBuilder: (context, index) {
                final subject = mySubjects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(subject['name'] ?? "Unknown"),
                    subtitle: Text("ID: ${subject['id']}"),
                  ),
                );
              },
            ),
    );
  }
}

// --- 3. TEACHER DASHBOARD (Your old HomeScreen) ---
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Teacher Dashboard"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => logout(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "All Students"),
              Tab(icon: Icon(Icons.book), text: "All Subjects"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Reusing your existing DataListScreen logic (which you can paste below)
            Center(child: Text("Teacher: View Students Here")),
            Center(child: Text("Teacher: View Subjects Here")),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Ensure this matches your Ubuntu IP
const String baseUrl = "http://192.168.100.151:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);

        print("Saved email to storage: ${emailController.text.trim()}");

        if (!mounted) return;
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (!mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login Failed")));
      }
    } catch (e) {
      if (!mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

// --- 2. STUDENT DASHBOARD ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMySubjects();
  }

  Future<void> fetchMySubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    // Debugging: Check if email was actually saved
    print("Attempting to fetch subjects for: $email");

    if (email == null || email.isEmpty) {
      print("Error: No email found in SharedPreferences");
      setState(() => isLoading = false);
      return;
    }

    try {
      // We try the endpoint you used in Web
      final url = Uri.parse("$baseUrl/my-subjects?email=$email");
      print("Requesting URL: $url");

      final response = await http.get(url);

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          mySubjects = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Server returned an error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Connection Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mySubjects.isEmpty
          ? const Center(child: Text("No subjects assigned yet."))
          : ListView.builder(
              itemCount: mySubjects.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.book),
                title: Text(mySubjects[index]['name']),
              ),
            ),
    );
  }
}

// --- 3. TEACHER DASHBOARD (Fixed placeholders) ---
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Teacher Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Students"),
              Tab(text: "Subjects"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            DataListScreen(type: "students"), // FIXED: No longer placeholder
            DataListScreen(type: "subjects"), // FIXED: No longer placeholder
          ],
        ),
      ),
    );
  }
}

// --- 4. DATA LIST SCREEN (For Teacher View) ---
class DataListScreen extends StatefulWidget {
  final String type;
  const DataListScreen({super.key, required this.type});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/${widget.type}"));
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item['name'] ?? item['email']),
          subtitle: Text(
            widget.type == "students"
                ? "Tap to see subjects"
                : "Tap to see students",
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsScreen(
                id: item['id'],
                name: item['name'] ?? item['email'],
                type: widget.type,
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- 5. DETAILS SCREEN (To see relationships and Assign) ---
class DetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final String type;
  const DetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List related = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    String endpoint = widget.type == "students"
        ? "/student-subjects/student/${widget.id}"
        : "/student-subjects/subject-details/${widget.id}";
    try {
      final response = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          related = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: related.length,
              itemBuilder: (context, index) =>
                  ListTile(title: Text(related[index]['name'])),
            ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Use your Ubuntu IP address
const String baseUrl = "http://192.168.100.151:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Save user data for dashboard personalization
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);

        if (!mounted) return;
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (!mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
        }
      }
    } catch (e) {
      if (!mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Connection Error: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

// --- 2. STUDENT DASHBOARD (Personalized View) ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMySubjects();
  }

  Future<void> fetchMySubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');

    try {
      // Fixed: URL now includes /management to match ManagementController
      final url = Uri.parse("$baseUrl/management/my-subjects?email=$email");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          mySubjects = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mySubjects.isEmpty
          ? const Center(child: Text("No subjects assigned yet."))
          : ListView.builder(
              itemCount: mySubjects.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(mySubjects[index]['name']),
                  ),
                );
              },
            ),
    );
  }
}

// --- 3. TEACHER DASHBOARD (Management View) ---
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Teacher Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Students"),
              Tab(text: "Subjects"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            DataListScreen(type: "students"),
            DataListScreen(type: "subjects"),
          ],
        ),
      ),
    );
  }
}

// --- 4. REUSABLE DATA LIST (For Teachers) ---
class DataListScreen extends StatefulWidget {
  final String type;
  const DataListScreen({super.key, required this.type});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fixed: URL now includes /management
      final response = await http.get(
        Uri.parse("$baseUrl/management/${widget.type}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(item['name'] ?? item['email'] ?? "Unknown"),
          subtitle: Text(
            widget.type == "students"
                ? "View enrolled courses"
                : "View enrolled students",
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsScreen(
                id: item['id'],
                name: item['name'] ?? item['email'],
                type: widget.type,
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- 5. DETAILS SCREEN (Relationship View) ---
class DetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final String type;
  const DetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List related = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    // These paths match your existing student-subjects endpoints
    String endpoint = widget.type == "students"
        ? "/student-subjects/student/${widget.id}"
        : "/student-subjects/subject-details/${widget.id}";
    try {
      final response = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          related = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : related.isEmpty
          ? const Center(child: Text("No assignments found."))
          : ListView.builder(
              itemCount: related.length,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(
                  widget.type == "students" ? Icons.book : Icons.person,
                ),
                title: Text(related[index]['name'] ?? "Unknown"),
              ),
            ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Use your Ubuntu IP address
const String baseUrl = "http://192.168.100.151:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);

        if (!mounted) return;
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (!mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login Failed")));
      }
    } catch (e) {
      if (!mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

// --- 2. RESTORED TEACHER DASHBOARD (Your Original Tab Layout) ---
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Teacher Dashboard"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Students"),
              Tab(icon: Icon(Icons.book), text: "Subjects"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataListScreen(type: "students"),
            DataListScreen(type: "subjects"),
          ],
        ),
      ),
    );
  }
}

// --- 3. STUDENT DASHBOARD (The one that was fine) ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMySubjects();
  }

  Future<void> fetchMySubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/my-subjects?email=$email"),
      );
      if (response.statusCode == 200) {
        setState(() {
          mySubjects = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mySubjects.isEmpty
          ? const Center(child: Text("No subjects assigned yet."))
          : ListView.builder(
              itemCount: mySubjects.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.book),
                title: Text(mySubjects[index]['name']),
              ),
            ),
    );
  }
}

// --- 4. REUSABLE DATA LIST SCREEN ---
class DataListScreen extends StatefulWidget {
  final String type;
  const DataListScreen({super.key, required this.type});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/${widget.type}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(
            widget.type == "students" ? Icons.person : Icons.menu_book,
          ),
          title: Text(item['name'] ?? item['email'] ?? "Unknown"),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsScreen(
                id: item['id'],
                name: item['name'] ?? item['email'],
                type: widget.type,
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- 5. DETAILS SCREEN ---
class DetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final String type;
  const DetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List related = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    String endpoint = widget.type == "students"
        ? "/student-subjects/student/${widget.id}"
        : "/student-subjects/subject-details/${widget.id}";
    try {
      final response = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          related = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: related.length,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(
                  widget.type == "students" ? Icons.book : Icons.person_outline,
                ),
                title: Text(related[index]['name'] ?? "Unknown"),
              ),
            ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Your Ubuntu IP and Spring Boot API base
const String baseUrl = "http://192.168.100.151:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUP Student Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Save session data
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);

        if (!mounted) return;

        // Route based on role from Backend
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (!mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid Login Details")),
          );
      }
    } catch (e) {
      if (!mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Connection Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Portal Login"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: login,
                      child: const Text("LOG IN"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// --- 2. TEACHER DASHBOARD (Fixed & Perfected) ---
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Teacher Dashboard"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.deepPurple,
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Students"),
              Tab(icon: Icon(Icons.book), text: "Subjects"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataListScreen(type: "students"),
            DataListScreen(type: "subjects"),
          ],
        ),
      ),
    );
  }
}

// --- 3. STUDENT DASHBOARD ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMySubjects();
  }

  Future<void> fetchMySubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    try {
      // Corrected path to /management/
      final response = await http.get(
        Uri.parse("$baseUrl/management/my-subjects?email=$email"),
      );
      if (response.statusCode == 200) {
        setState(() {
          mySubjects = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mySubjects.isEmpty
          ? const Center(child: Text("You have no assigned subjects yet."))
          : ListView.builder(
              itemCount: mySubjects.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.menu_book,
                    color: Colors.deepPurple,
                  ),
                  title: Text(
                    mySubjects[index]['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
    );
  }
}

// --- 4. REUSABLE DATA LIST (Students/Subjects List) ---
class DataListScreen extends StatefulWidget {
  final String type;
  const DataListScreen({super.key, required this.type});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Uses /management/students or /management/subjects
      final response = await http.get(
        Uri.parse("$baseUrl/management/${widget.type}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            child: Icon(
              widget.type == "students" ? Icons.person : Icons.library_books,
              color: Colors.deepPurple,
            ),
          ),
          title: Text(item['name'] ?? item['email'] ?? "Unknown"),
          subtitle: Text(
            widget.type == "students"
                ? "Student ID: ${item['id']}"
                : "Course Code: ${item['id']}",
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsScreen(
                id: item['id'],
                name: item['name'] ?? item['email'],
                type: widget.type,
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- 5. DETAILS SCREEN (Fixed URLs to /management) ---
class DetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final String type;
  const DetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List related = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    // FIXED: Now uses /management prefix instead of old /student-subjects
    String endpoint = widget.type == "students"
        ? "/management/student-details/${widget.id}"
        : "/management/subject-details/${widget.id}";

    try {
      final response = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          related = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.deepPurple.shade50,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : related.isEmpty
          ? const Center(child: Text("No data found for this selection."))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.type == "students"
                        ? "Enrolled Subjects:"
                        : "Enrolled Students:",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: related.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: Icon(
                        widget.type == "students"
                            ? Icons.book
                            : Icons.person_outline,
                      ),
                      title: Text(related[index]['name'] ?? "Unknown Item"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
*/

/*
//all functionality works but no UI

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://192.168.100.151:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUP Portal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);

        if (!mounted) return;
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login Failed")));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Teacher Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Students"),
              Tab(icon: Icon(Icons.book), text: "Subjects"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataListScreen(type: "students"),
            DataListScreen(type: "subjects"),
          ],
        ),
      ),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMySubjects();
  }

  Future<void> fetchMySubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/my-subjects?email=$email"),
      );
      if (response.statusCode == 200) {
        setState(() {
          mySubjects = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: mySubjects.length,
              itemBuilder: (context, index) => ListTile(
                leading: const Icon(Icons.book),
                title: Text(mySubjects[index]['name']),
              ),
            ),
    );
  }
}

class DataListScreen extends StatefulWidget {
  final String type;
  const DataListScreen({super.key, required this.type});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/${widget.type}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: Icon(
            widget.type == "students" ? Icons.person : Icons.menu_book,
          ),
          title: Text(item['name'] ?? item['email'] ?? "Unknown"),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsScreen(
                id: item['id'],
                name: item['name'] ?? item['email'],
                type: widget.type,
              ),
            ),
          ),
        );
      },
    );
  }
}

class DetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final String type;
  const DetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List related = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    String endpoint = widget.type == "students"
        ? "/management/student-details/${widget.id}"
        : "/management/subject-details/${widget.id}";
    try {
      final response = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          related = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: related.length,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(
                  widget.type == "students" ? Icons.book : Icons.person,
                ),
                title: Text(
                  related[index]['name'] ??
                      related[index]['email'] ??
                      "Unknown",
                ),
              ),
            ),
    );
  }
}
*/

/*
//Ui + functions

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://192.168.100.151:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUP Student Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Professional Deep Blue
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFFFA000), // Professional Gold accent
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);

        if (!mounted) return;
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Connection Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "BUP PORTAL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 40),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: login,
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. TEACHER DASHBOARD ---
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Management Panel",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFA000),
            indicatorWeight: 4,
            tabs: [
              Tab(icon: Icon(Icons.group), text: "Students"),
              Tab(icon: Icon(Icons.menu_book), text: "Subjects"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataListScreen(type: "students"),
            DataListScreen(type: "subjects"),
          ],
        ),
      ),
    );
  }
}

// --- 3. STUDENT DASHBOARD ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMySubjects();
  }

  Future<void> fetchMySubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/my-subjects?email=$email"),
      );
      if (response.statusCode == 200) {
        setState(() {
          mySubjects = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Curriculum"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : mySubjects.isEmpty
          ? const Center(child: Text("No subjects enrolled yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mySubjects.length,
              itemBuilder: (context, index) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1A237E),
                    child: Icon(Icons.book, color: Colors.white),
                  ),
                  title: Text(
                    mySubjects[index]['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Credit Course"),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
    );
  }
}

// --- 4. DATA LIST SCREEN (REUSABLE) ---
class DataListScreen extends StatefulWidget {
  final String type;
  const DataListScreen({super.key, required this.type});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/${widget.type}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.type == "students"
                  ? Colors.blue.shade50
                  : Colors.orange.shade50,
              child: Icon(
                widget.type == "students" ? Icons.person : Icons.menu_book,
                color: widget.type == "students" ? Colors.blue : Colors.orange,
              ),
            ),
            title: Text(
              item['name'] ?? item['email'] ?? "Unknown",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailsScreen(
                  id: item['id'],
                  name: item['name'] ?? item['email'],
                  type: widget.type,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- 5. DETAILS SCREEN ---
class DetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final String type;
  const DetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List related = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    String endpoint = widget.type == "students"
        ? "/management/student-details/${widget.id}"
        : "/management/subject-details/${widget.id}";
    try {
      final response = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          related = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(fontSize: 18)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey.shade50,
                  child: Text(
                    widget.type == "students"
                        ? "Assigned Subject List"
                        : "Enrolled Student List",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: related.length,
                    separatorBuilder: (c, i) => const Divider(),
                    itemBuilder: (context, index) => ListTile(
                      leading: Icon(
                        widget.type == "students"
                            ? Icons.book_outlined
                            : Icons.person_outline,
                      ),
                      title: Text(
                        related[index]['name'] ??
                            related[index]['email'] ??
                            "Unknown",
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Your current local API endpoint
const String baseUrl = "http://192.168.0.7:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUP Student Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // BUP Blue
          primary: const Color.fromARGB(255, 254, 255, 255),
          secondary: const Color(0xFFFFA000), // Professional Gold
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- 1. LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);

        if (!mounted) return;
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Failed: Invalid Credentials")),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Connection Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 70, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    "BUP PORTAL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                children: [
                  const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: login,
                          child: const Text("LOGIN"),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. TEACHER DASHBOARD ---
class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Management Console"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFFFFA000),
            tabs: [
              Tab(icon: Icon(Icons.people_alt), text: "Students"),
              Tab(icon: Icon(Icons.collections_bookmark), text: "Subjects"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataListScreen(type: "students"),
            DataListScreen(type: "subjects"),
          ],
        ),
      ),
    );
  }
}

// --- 3. STUDENT DASHBOARD ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMySubjects();
  }

  Future<void> fetchMySubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/my-subjects?email=$email"),
      );
      if (response.statusCode == 200) {
        setState(() {
          mySubjects = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mySubjects.length,
              itemBuilder: (context, index) => Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.book, color: Color(0xFF1A237E)),
                  title: Text(
                    mySubjects[index]['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
    );
  }
}

// --- 4. DATA LIST SCREEN (WITH ASSIGNMENT LOGIC) ---
class DataListScreen extends StatefulWidget {
  final String type;
  const DataListScreen({super.key, required this.type});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  List items = [];
  List allSubjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    if (widget.type == "students") fetchSubjectsList();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/${widget.type}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Pre-fetch subjects so the assignment picker is instant
  Future<void> fetchSubjectsList() async {
    final response = await http.get(Uri.parse("$baseUrl/management/subjects"));
    if (response.statusCode == 200) {
      allSubjects = json.decode(response.body);
    }
  }

  Future<void> assignSubjectToStudent(int studentId, int subjectId) async {
    final response = await http.post(
      Uri.parse(
        "$baseUrl/management/assign?studentId=$studentId&subjectId=$subjectId",
      ),
    );

    if (!mounted) return;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Success: Subject Assigned"),
        ),
      );
      Navigator.pop(context); // Close bottom sheet
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error: Could not assign subject"),
        ),
      );
    }
  }

  void openAssignSheet(dynamic student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assign Subject to:",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            Text(
              student['name'] ?? student['email'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),
            const Text(
              "Select Subject",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            allSubjects.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No subjects available."),
                  )
                : SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: allSubjects.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.blue,
                        ),
                        title: Text(allSubjects[index]['name']),
                        onTap: () => assignSubjectToStudent(
                          student['id'],
                          allSubjects[index]['id'],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: widget.type == "students"
                  ? Colors.blue.shade50
                  : Colors.orange.shade50,
              child: Icon(
                widget.type == "students" ? Icons.person : Icons.menu_book,
                color: widget.type == "students" ? Colors.blue : Colors.orange,
              ),
            ),
            title: Text(
              item['name'] ?? item['email'] ?? "Unknown",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: widget.type == "students"
                ? IconButton(
                    icon: const Icon(
                      Icons.assignment_add,
                      color: Color(0xFF1A237E),
                    ),
                    onPressed: () => openAssignSheet(item),
                  )
                : const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailsScreen(
                  id: item['id'],
                  name: item['name'] ?? item['email'],
                  type: widget.type,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- 5. DETAILS SCREEN ---
class DetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final String type;
  const DetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List related = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    String endpoint = widget.type == "students"
        ? "/management/student-details/${widget.id}"
        : "/management/subject-details/${widget.id}";
    try {
      final response = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          related = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(fontSize: 18)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  color: Colors.grey.shade50,
                  child: Text(
                    widget.type == "students"
                        ? "Current Course Load"
                        : "Enrolled Students",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: related.length,
                    separatorBuilder: (c, i) => const Divider(),
                    itemBuilder: (context, index) => ListTile(
                      leading: Icon(
                        widget.type == "students"
                            ? Icons.book_outlined
                            : Icons.person_pin,
                      ),
                      title: Text(
                        related[index]['name'] ??
                            related[index]['email'] ??
                            "Unknown",
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://192.168.0.2:8080/api";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUP Student Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFFFA000),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// 1. LOGIN SCREEN
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailController.text.trim());
        await prefs.setString('userRole', data['role']);
        if (!mounted) return;
        if (data['role'] == 'TEACHER') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboard()),
          );
        }
      } else {
        if (mounted)
          _showSnack("Login Failed: Invalid Credentials", isError: true);
      }
    } catch (e) {
      if (mounted) _showSnack("Connection Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 70, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    "BUP PORTAL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                children: [
                  const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 40),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: login,
                          child: const Text("LOGIN"),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2. TEACHER DASHBOARD
// ─────────────────────────────────────────────
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_rounded, label: "Overview"),
    _NavItem(icon: Icons.person_add_alt_1_rounded, label: "Add Student"),
    _NavItem(icon: Icons.library_add_rounded, label: "Add Subject"),
    _NavItem(icon: Icons.assignment_ind_rounded, label: "Assign"),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OverviewTab(),
      const AddStudentTab(),
      const AddSubjectTab(),
      const AssignSubjectTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_selectedIndex].label),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF1A237E).withOpacity(0.12),
        destinations: _navItems
            .map(
              (n) => NavigationDestination(
                icon: Icon(n.icon),
                selectedIcon: Icon(n.icon, color: const Color(0xFF1A237E)),
                label: n.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─────────────────────────────────────────────
// 3. OVERVIEW TAB
// ─────────────────────────────────────────────
class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  List students = [];
  List subjects = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final sRes = await http.get(Uri.parse("$baseUrl/management/students"));
      final subRes = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (sRes.statusCode == 200 && subRes.statusCode == 200) {
        setState(() {
          students = jsonDecode(sRes.body);
          subjects = jsonDecode(subRes.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          error = "Failed to load data.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Connection error.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetchAll, child: const Text("Retry")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _StatCard(
                icon: Icons.people_alt_rounded,
                label: "Students",
                value: students.length.toString(),
                color: const Color(0xFF1A237E),
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.menu_book_rounded,
                label: "Subjects",
                value: subjects.length.toString(),
                color: const Color(0xFFFFA000),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: "Students & Their Subjects"),
          const SizedBox(height: 10),
          ...students.map((s) => _StudentSubjectCard(student: s)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentSubjectCard extends StatefulWidget {
  final dynamic student;
  const _StudentSubjectCard({required this.student});

  @override
  State<_StudentSubjectCard> createState() => _StudentSubjectCardState();
}

class _StudentSubjectCardState extends State<_StudentSubjectCard> {
  List subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    try {
      final res = await http.get(
        Uri.parse(
          "$baseUrl/management/student-details/${widget.student['id']}",
        ),
      );
      if (res.statusCode == 200) {
        setState(() {
          subjects = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.student['name'];
    final email = widget.student['email'] ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE8EAF6),
                  child: Icon(Icons.person, color: Color(0xFF1A237E), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name != null && name.toString().isNotEmpty
                            ? name
                            : email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (name != null && name.toString().isNotEmpty)
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : subjects.isEmpty
                ? Text(
                    "No subjects assigned",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: subjects
                        .map(
                          (sub) => Chip(
                            label: Text(
                              sub['name'] ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: const Color(0xFFFFF3E0),
                            side: const BorderSide(
                              color: Color(0xFFFFA000),
                              width: 0.8,
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 4. ADD STUDENT TAB
// ─────────────────────────────────────────────
class AddStudentTab extends StatefulWidget {
  const AddStudentTab({super.key});

  @override
  State<AddStudentTab> createState() => _AddStudentTabState();
}

class _AddStudentTabState extends State<AddStudentTab> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  List students = [];
  bool studentsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => studentsLoading = true);
    try {
      final res = await http.get(Uri.parse("$baseUrl/management/students"));
      if (res.statusCode == 200) {
        setState(() {
          students = jsonDecode(res.body);
          studentsLoading = false;
        });
      } else {
        setState(() => studentsLoading = false);
      }
    } catch (_) {
      setState(() => studentsLoading = false);
    }
  }

  Future<void> _addStudent() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    final name = nameCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showSnack("Email and password are required.", isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final body = <String, dynamic>{
        "email": email,
        "password": password,
        "role": "STUDENT",
      };
      if (name.isNotEmpty) body["name"] = name;

      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _showSnack("Student added successfully!");
        emailCtrl.clear();
        passwordCtrl.clear();
        nameCtrl.clear();
        _fetchStudents();
      } else {
        _showSnack(
          response.body.isNotEmpty ? response.body : "Failed to add student.",
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) _showSnack("Connection error: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteStudent(dynamic student) async {
    final nameOrEmail = student['name'] ?? student['email'];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text('Delete "$nameOrEmail"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/management/users/${student['id']}"),
      );
      if (!mounted) return;
      if (res.statusCode == 204) {
        _showSnack("$nameOrEmail deleted.");
        _fetchStudents();
      } else {
        _showSnack("Failed to delete student.", isError: true);
      }
    } catch (e) {
      if (mounted) _showSnack("Connection error: $e", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Add form ──
        const _FormHeader(
          icon: Icons.person_add_alt_1_rounded,
          title: "Add New Student",
          subtitle: "Create a student account",
        ),
        const SizedBox(height: 20),
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Full Name (optional)",
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Student Email *",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: passwordCtrl,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            labelText: "Password *",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => obscurePassword = !obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 20),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
                onPressed: _addStudent,
                icon: const Icon(Icons.add),
                label: const Text("ADD STUDENT"),
              ),

        // ── Existing students list ──
        const SizedBox(height: 32),
        Row(
          children: [
            const _SectionHeader(title: "All Students"),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                students.length.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        studentsLoading
            ? const Center(child: CircularProgressIndicator())
            : students.isEmpty
            ? _EmptyState(
                icon: Icons.person_off_outlined,
                message: "No students yet.",
              )
            : Column(
                children: students
                    .map(
                      (s) => _PersonTile(
                        name: s['name'],
                        email: s['email'],
                        icon: Icons.person,
                        iconColor: const Color(0xFF1A237E),
                        iconBg: const Color(0xFFE8EAF6),
                        onDelete: () => _deleteStudent(s),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 5. ADD SUBJECT TAB
// ─────────────────────────────────────────────
class AddSubjectTab extends StatefulWidget {
  const AddSubjectTab({super.key});

  @override
  State<AddSubjectTab> createState() => _AddSubjectTabState();
}

class _AddSubjectTabState extends State<AddSubjectTab> {
  final nameCtrl = TextEditingController();
  bool isLoading = false;

  List subjects = [];
  bool subjectsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    setState(() => subjectsLoading = true);
    try {
      final res = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (res.statusCode == 200) {
        setState(() {
          subjects = jsonDecode(res.body);
          subjectsLoading = false;
        });
      } else {
        setState(() => subjectsLoading = false);
      }
    } catch (_) {
      setState(() => subjectsLoading = false);
    }
  }

  Future<void> _addSubject() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      _showSnack("Subject name is required.", isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/subjects"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name}),
      );
      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack("Subject \"$name\" added!");
        nameCtrl.clear();
        _fetchSubjects();
      } else {
        _showSnack(
          "Failed to add subject. (${response.statusCode})",
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) _showSnack("Connection error: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteSubject(dynamic subject) async {
    final name = subject['name'] ?? 'this subject';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Subject"),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/subjects/${subject['id']}"),
      );
      if (!mounted) return;
      if (res.statusCode == 204) {
        _showSnack("\"$name\" deleted.");
        _fetchSubjects();
      } else {
        _showSnack("Failed to delete subject.", isError: true);
      }
    } catch (e) {
      if (mounted) _showSnack("Connection error: $e", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _FormHeader(
          icon: Icons.library_add_rounded,
          title: "Add New Subject",
          subtitle: "Create a subject to assign to students",
        ),
        const SizedBox(height: 20),
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: "Subject Name *",
            prefixIcon: Icon(Icons.menu_book_outlined),
          ),
        ),
        const SizedBox(height: 20),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
                onPressed: _addSubject,
                icon: const Icon(Icons.add),
                label: const Text("ADD SUBJECT"),
              ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFFFA000), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "After adding, go to Assign to assign this subject to students.",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),

        // ── Existing subjects list ──
        const SizedBox(height: 32),
        Row(
          children: [
            const _SectionHeader(title: "All Subjects"),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA000).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                subjects.length.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFA000),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        subjectsLoading
            ? const Center(child: CircularProgressIndicator())
            : subjects.isEmpty
            ? _EmptyState(
                icon: Icons.book_outlined,
                message: "No subjects yet.",
              )
            : Column(
                children: subjects
                    .map(
                      (s) => _PersonTile(
                        name: s['name'],
                        email: null,
                        icon: Icons.menu_book,
                        iconColor: const Color(0xFFFFA000),
                        iconBg: const Color(0xFFFFF3E0),
                        onDelete: () => _deleteSubject(s),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 6. ASSIGN SUBJECT TAB
// ─────────────────────────────────────────────
class AssignSubjectTab extends StatefulWidget {
  const AssignSubjectTab({super.key});

  @override
  State<AssignSubjectTab> createState() => _AssignSubjectTabState();
}

class _AssignSubjectTabState extends State<AssignSubjectTab> {
  List students = [];
  List subjects = [];
  dynamic selectedStudent;
  dynamic selectedSubject;
  bool isLoading = true;
  bool isAssigning = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final sRes = await http.get(Uri.parse("$baseUrl/management/students"));
      final subRes = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (sRes.statusCode == 200 && subRes.statusCode == 200) {
        setState(() {
          students = jsonDecode(sRes.body);
          subjects = jsonDecode(subRes.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          error = "Failed to load data.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Connection error.";
      });
    }
  }

  Future<void> _assign() async {
    if (selectedStudent == null || selectedSubject == null) {
      _showSnack("Please select both a student and a subject.", isError: true);
      return;
    }
    setState(() => isAssigning = true);
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/management/assign?studentId=${selectedStudent['id']}&subjectId=${selectedSubject['id']}",
        ),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _showSnack(
          "\"${selectedSubject['name']}\" assigned to ${selectedStudent['name'] ?? selectedStudent['email']}!",
        );
        setState(() {
          selectedSubject = null;
        });
      } else {
        _showSnack("Failed to assign subject.", isError: true);
      }
    } catch (e) {
      if (mounted) _showSnack("Connection error: $e", isError: true);
    } finally {
      if (mounted) setState(() => isAssigning = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetchData, child: const Text("Retry")),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FormHeader(
            icon: Icons.assignment_ind_rounded,
            title: "Assign Subject",
            subtitle: "Select a student and a subject to assign",
          ),
          const SizedBox(height: 24),

          const Text(
            "Select Student",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                value: selectedStudent,
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("-- Select Student --"),
                ),
                items: students
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 18,
                                color: Color(0xFF1A237E),
                              ),
                              const SizedBox(width: 8),
                              Text(s['name'] ?? s['email'] ?? 'Unknown'),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() {
                  selectedStudent = v;
                  selectedSubject = null;
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Select Subject",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                value: selectedSubject,
                isExpanded: true,
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("-- Select Subject --"),
                ),
                items: subjects
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.menu_book,
                                size: 18,
                                color: Color(0xFFFFA000),
                              ),
                              const SizedBox(width: 8),
                              Text(s['name'] ?? 'Unknown'),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedSubject = v),
              ),
            ),
          ),

          if (selectedStudent != null && selectedSubject != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF1A237E),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Assign \"${selectedSubject!['name']}\" to ${selectedStudent!['name'] ?? selectedStudent!['email']}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          isAssigning
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _assign,
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text("ASSIGN SUBJECT"),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 7. STUDENT DASHBOARD
// ─────────────────────────────────────────────
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List mySubjects = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMySubjects();
  }

  Future<void> fetchMySubjects() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('userEmail');
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/management/my-subjects?email=$email"),
      );
      if (response.statusCode == 200) {
        setState(() {
          mySubjects = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          error = "Could not load subjects.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Connection error.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: fetchMySubjects,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : mySubjects.isEmpty
          ? const Center(
              child: Text(
                "No subjects assigned yet.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mySubjects.length,
              itemBuilder: (context, index) => Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.book, color: Color(0xFF1A237E)),
                  title: Text(
                    mySubjects[index]['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// 8. SHARED WIDGETS
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A237E),
      ),
    );
  }
}

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _FormHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1A237E), size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Reusable tile used for both student and subject lists
class _PersonTile extends StatelessWidget {
  final String? name;
  final String? email;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onDelete;

  const _PersonTile({
    required this.name,
    required this.email,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primary = (name != null && name!.isNotEmpty)
        ? name!
        : email ?? 'Unknown';
    final secondary = (name != null && name!.isNotEmpty) ? email : null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          primary,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: secondary != null
            ? Text(
                secondary,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
          tooltip: "Delete",
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 9. DETAILS SCREEN
// ─────────────────────────────────────────────
class DetailsScreen extends StatefulWidget {
  final int id;
  final String name;
  final String type;
  const DetailsScreen({
    super.key,
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List related = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    final endpoint = widget.type == "students"
        ? "/management/student-details/${widget.id}"
        : "/management/subject-details/${widget.id}";
    try {
      final response = await http.get(Uri.parse("$baseUrl$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          related = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(fontSize: 18)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  color: Colors.grey.shade50,
                  child: Text(
                    widget.type == "students"
                        ? "Current Course Load"
                        : "Enrolled Students",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: related.length,
                    separatorBuilder: (c, i) => const Divider(),
                    itemBuilder: (context, index) => ListTile(
                      leading: Icon(
                        widget.type == "students"
                            ? Icons.book_outlined
                            : Icons.person_pin,
                      ),
                      title: Text(
                        related[index]['name'] ??
                            related[index]['email'] ??
                            "Unknown",
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
*/

/*

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://192.168.0.8:8080/api";

// ── Design tokens ──────────────────────────────
const kBg = Color(0xFF0F0F13);
const kSurface = Color(0xFF1A1A22);
const kSurfaceHi = Color(0xFF242430);
const kBorder = Color(0xFF2E2E3A);
const kGold = Color(0xFFD4A853);
const kGoldLight = Color(0xFFF0C97A);
const kGoldDim = Color(0xFF8A6C30);
const kCream = Color(0xFFF5F0E8);
const kCreamDim = Color(0xFF9A9489);
const kRed = Color(0xFFE05C5C);
const kGreen = Color(0xFF5CBF8A);
const kBlue = Color(0xFF7C9EF0);

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

// ─────────────────────────────────────────────────────────
// APP
// ─────────────────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BUP Portal',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(
          surface: kSurface,
          primary: kGold,
          secondary: kCream,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurfaceHi,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kGold, width: 1.5),
          ),
          labelStyle: const TextStyle(color: kCreamDim, fontSize: 13),
          prefixIconColor: kGoldDim,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kGold,
            foregroundColor: kBg,
            minimumSize: const Size(double.infinity, 52),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────

// BUP monogram badge
Widget _bupBadge({double size = 30, double font = 13}) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    color: kGold,
    borderRadius: BorderRadius.circular(size * 0.24),
  ),
  child: Center(
    child: Text(
      "B",
      style: TextStyle(color: kBg, fontWeight: FontWeight.w900, fontSize: font),
    ),
  ),
);

// Gold horizontal rule
Widget _rule() => Container(
  height: 1,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.transparent, kGold, Colors.transparent],
      stops: [0, 0.5, 1],
    ),
  ),
);

// Section title with gold left bar
class _SectionTitle extends StatelessWidget {
  final String title;
  final int? count;
  const _SectionTitle({required this.title, this.count});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: kGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: kCream,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: kGold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Card surface wrapper
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kBorder),
    ),
    child: child,
  );
}

// Label in all-caps
Widget _lbl(String t) => Text(
  t,
  style: const TextStyle(
    color: kCreamDim,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  ),
);

// Gold CTA button
class _GoldBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;
  const _GoldBtn({
    required this.label,
    required this.icon,
    this.onTap,
    this.loading = false,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: kBg, strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
    ),
  );
}

// Inline status banner
class _Banner extends StatelessWidget {
  final String message;
  final bool isError;
  const _Banner({required this.message, required this.isError});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: (isError ? kRed : kGreen).withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: (isError ? kRed : kGreen).withOpacity(0.35)),
    ),
    child: Row(
      children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          size: 15,
          color: isError ? kRed : kGreen,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: isError ? kRed : kGreen,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// Logout pill button
Widget _logoutBtn(BuildContext context) => GestureDetector(
  onTap: () => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  ),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: kSurfaceHi,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: kBorder),
    ),
    child: const Row(
      children: [
        Icon(Icons.logout_rounded, color: kCreamDim, size: 14),
        SizedBox(width: 5),
        Text("Logout", style: TextStyle(color: kCreamDim, fontSize: 12)),
      ],
    ),
  ),
);

// Item tile (student or subject row)
class _Tile extends StatelessWidget {
  final String primary;
  final String? secondary;
  final IconData icon;
  final Color accent;
  final VoidCallback onDelete;
  const _Tile({
    required this.primary,
    this.secondary,
    required this.icon,
    required this.accent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: kSurfaceHi,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kBorder),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: const TextStyle(
                  color: kCream,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (secondary != null)
                Text(
                  secondary!,
                  style: const TextStyle(color: kCreamDim, fontSize: 12),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: kRed,
              size: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 36, color: kBorder),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: kCreamDim, fontSize: 13)),
        ],
      ),
    ),
  );
}

class _ErrorRetry extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded, color: kCreamDim, size: 40),
        const SizedBox(height: 12),
        Text(msg, style: const TextStyle(color: kCreamDim, fontSize: 14)),
        const SizedBox(height: 16),
        SizedBox(
          width: 140,
          child: ElevatedButton(onPressed: onRetry, child: const Text("RETRY")),
        ),
      ],
    ),
  );
}

void _snack(BuildContext ctx, String msg, {bool err = false}) =>
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              err ? Icons.error_outline : Icons.check_circle_outline,
              color: err ? kRed : kGreen,
              size: 15,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: kCream, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: kSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: err ? kRed : kGreen, width: 0.5),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );

Future<bool> _confirm(BuildContext ctx, String title, String body) async =>
    await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: kBorder),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: kCream,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(color: kCreamDim, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Cancel", style: TextStyle(color: kCreamDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: kRed),
            child: const Text(
              "Delete",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ) ??
    false;

// ─────────────────────────────────────────────────────────
// 1. LOGIN SCREEN
// ─────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false, obscure = true;

  Future<void> _login() async {
    setState(() => loading = true);
    try {
      final r = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailCtrl.text.trim(),
          "password": passCtrl.text.trim(),
        }),
      );
      if (!mounted) return;
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailCtrl.text.trim());
        await prefs.setString('userRole', data['role']);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => data['role'] == 'TEACHER'
                ? const TeacherDashboard()
                : const StudentDashboard(),
          ),
        );
      } else {
        _snack(context, "Invalid credentials", err: true);
      }
    } catch (_) {
      if (mounted) _snack(context, "Connection error", err: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // Ambient glow top-right
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kGold.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),
          // Ambient glow bottom-left
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kGold.withOpacity(0.05), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  _bupBadge(size: 56, font: 16),
                  const SizedBox(height: 36),
                  const Text(
                    "Welcome\nback.",
                    style: TextStyle(
                      color: kCream,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign in to your portal",
                    style: TextStyle(color: kCreamDim, fontSize: 15),
                  ),
                  const SizedBox(height: 48),
                  _lbl("EMAIL ADDRESS"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: kCream, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "you@university.edu",
                      hintStyle: TextStyle(color: kCreamDim),
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _lbl("PASSWORD"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passCtrl,
                    obscureText: obscure,
                    style: const TextStyle(color: kCream, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "••••••••",
                      hintStyle: const TextStyle(color: kCreamDim),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: kCreamDim,
                          size: 18,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _GoldBtn(
                    label: "SIGN IN",
                    icon: Icons.arrow_forward_rounded,
                    onTap: _login,
                    loading: loading,
                  ),
                  const SizedBox(height: 40),
                  _rule(),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Bangladesh University of Professionals",
                      style: TextStyle(
                        color: kCreamDim.withOpacity(0.5),
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 2. TEACHER DASHBOARD SHELL
// ─────────────────────────────────────────────────────────
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _idx = 0;
  static const _tabs = [
    (icon: Icons.grid_view_rounded, label: "Overview"),
    (icon: Icons.person_add_alt_1_rounded, label: "Students"),
    (icon: Icons.library_add_rounded, label: "Subjects"),
    (icon: Icons.link_rounded, label: "Assign"),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OverviewTab(),
      const AddStudentTab(),
      const AddSubjectTab(),
      const AssignSubjectTab(),
    ];
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            _bupBadge(),
            const SizedBox(width: 10),
            Text(
              _tabs[_idx].label,
              style: const TextStyle(
                color: kCream,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _logoutBtn(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: pages[_idx],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final sel = _idx == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _idx = i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? kGold.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _tabs[i].icon,
                            color: sel ? kGold : kCreamDim,
                            size: 20,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _tabs[i].label,
                            style: TextStyle(
                              color: sel ? kGold : kCreamDim,
                              fontSize: 10,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 3. OVERVIEW TAB
// ─────────────────────────────────────────────────────────
class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});
  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  List students = [], subjects = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final r1 = await http.get(Uri.parse("$baseUrl/management/students"));
      final r2 = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (r1.statusCode == 200 && r2.statusCode == 200) {
        setState(() {
          students = jsonDecode(r1.body);
          subjects = jsonDecode(r2.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          error = "Failed to load.";
        });
      }
    } catch (_) {
      setState(() {
        loading = false;
        error = "Connection error.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(child: CircularProgressIndicator(color: kGold));
    if (error != null) return _ErrorRetry(msg: error!, onRetry: _load);
    return RefreshIndicator(
      color: kGold,
      backgroundColor: kSurface,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stat cards
          Row(
            children: [
              _stat(
                students.length,
                "Students",
                Icons.people_alt_rounded,
                kGold,
              ),
              const SizedBox(width: 12),
              _stat(
                subjects.length,
                "Subjects",
                Icons.auto_stories_rounded,
                kBlue,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: "Roster", count: students.length),
          const SizedBox(height: 12),
          ...students.map((s) => _StudentCard(student: s)),
        ],
      ),
    );
  }

  Widget _stat(int val, String lbl, IconData icon, Color accent) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                val.toString(),
                style: TextStyle(
                  color: accent,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(lbl, style: const TextStyle(color: kCreamDim, fontSize: 12)),
            ],
          ),
        ],
      ),
    ),
  );
}

// Student card in overview
class _StudentCard extends StatefulWidget {
  final dynamic student;
  const _StudentCard({required this.student});
  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard> {
  List subs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await http.get(
        Uri.parse(
          "$baseUrl/management/student-details/${widget.student['id']}",
        ),
      );
      if (r.statusCode == 200) {
        setState(() {
          subs = jsonDecode(r.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.student['name'];
    final email = widget.student['email'] ?? '';
    final hasName = name != null && name.toString().isNotEmpty;
    final initials = hasName
        ? name.toString()[0].toUpperCase()
        : email.isNotEmpty
        ? email[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: kGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? name.toString() : email,
                      style: const TextStyle(
                        color: kCream,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (hasName)
                      Text(
                        email,
                        style: const TextStyle(color: kCreamDim, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  loading ? "…" : "${subs.length} courses",
                  style: const TextStyle(
                    color: kGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (!loading && subs.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(height: 0.5, color: kBorder),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: subs
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kSurfaceHi,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kBorder),
                      ),
                      child: Text(
                        s['name'] ?? '',
                        style: const TextStyle(
                          color: kCreamDim,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (!loading && subs.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              "No subjects assigned yet",
              style: TextStyle(
                color: kCreamDim,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 4. ADD STUDENT TAB
// ─────────────────────────────────────────────────────────
class AddStudentTab extends StatefulWidget {
  const AddStudentTab({super.key});
  @override
  State<AddStudentTab> createState() => _AddStudentTabState();
}

class _AddStudentTabState extends State<AddStudentTab> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool adding = false, obscure = true;
  String? msg;
  bool? isErr;

  List students = [];
  bool listLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => listLoading = true);
    try {
      final r = await http.get(Uri.parse("$baseUrl/management/students"));
      if (r.statusCode == 200) {
        setState(() {
          students = jsonDecode(r.body);
          listLoading = false;
        });
      } else {
        setState(() => listLoading = false);
      }
    } catch (_) {
      setState(() => listLoading = false);
    }
  }

  Future<void> _add() async {
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      setState(() {
        msg = "Email and password are required.";
        isErr = true;
      });
      return;
    }
    setState(() {
      adding = true;
      msg = null;
    });
    try {
      final body = <String, dynamic>{
        "email": emailCtrl.text.trim(),
        "password": passCtrl.text.trim(),
        "role": "STUDENT",
      };
      if (nameCtrl.text.trim().isNotEmpty) body["name"] = nameCtrl.text.trim();
      final r = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (!mounted) return;
      if (r.statusCode == 200) {
        setState(() {
          msg = "Student added!";
          isErr = false;
          nameCtrl.clear();
          emailCtrl.clear();
          passCtrl.clear();
        });
        _loadStudents();
      } else {
        setState(() {
          msg = r.body.isNotEmpty ? r.body : "Failed.";
          isErr = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          msg = "Connection error.";
          isErr = true;
        });
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  Future<void> _delete(dynamic s) async {
    final label = s['name'] ?? s['email'];
    final ok = await _confirm(
      context,
      "Delete student?",
      "\"$label\" will be permanently removed.",
    );
    if (!ok) return;
    try {
      final r = await http.delete(
        Uri.parse("$baseUrl/management/users/${s['id']}"),
      );
      if (!mounted) return;
      if (r.statusCode == 204) {
        setState(() {
          msg = "Deleted.";
          isErr = false;
        });
        _loadStudents();
      } else {
        setState(() {
          msg = "Failed to delete.";
          isErr = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          msg = "Connection error.";
          isErr = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: "Add New Student"),
              const SizedBox(height: 20),
              _lbl("FULL NAME"),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: kCream, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Optional",
                  hintStyle: TextStyle(color: kCreamDim),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 14),
              _lbl("EMAIL ADDRESS"),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: kCream, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "student@bup.edu.bd",
                  hintStyle: TextStyle(color: kCreamDim),
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              const SizedBox(height: 14),
              _lbl("PASSWORD"),
              const SizedBox(height: 6),
              TextField(
                controller: passCtrl,
                obscureText: obscure,
                style: const TextStyle(color: kCream, fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Set a password",
                  hintStyle: const TextStyle(color: kCreamDim),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kCreamDim,
                      size: 18,
                    ),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
              ),
              if (msg != null) ...[
                const SizedBox(height: 14),
                _Banner(message: msg!, isError: isErr ?? false),
              ],
              const SizedBox(height: 20),
              _GoldBtn(
                label: "ADD STUDENT",
                icon: Icons.person_add_rounded,
                onTap: _add,
                loading: adding,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(title: "All Students", count: students.length),
        const SizedBox(height: 12),
        if (listLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: kGold),
            ),
          )
        else if (students.isEmpty)
          const _Empty(message: "No students yet")
        else
          ...students.map((s) {
            final hasName =
                s['name'] != null && s['name'].toString().isNotEmpty;
            return _Tile(
              primary: hasName ? s['name'] : s['email'] ?? 'Unknown',
              secondary: hasName ? s['email'] : null,
              icon: Icons.person_rounded,
              accent: kGold,
              onDelete: () => _delete(s),
            );
          }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// 5. ADD SUBJECT TAB
// ─────────────────────────────────────────────────────────
class AddSubjectTab extends StatefulWidget {
  const AddSubjectTab({super.key});
  @override
  State<AddSubjectTab> createState() => _AddSubjectTabState();
}

class _AddSubjectTabState extends State<AddSubjectTab> {
  final nameCtrl = TextEditingController();
  bool adding = false;
  String? msg;
  bool? isErr;

  List subjects = [];
  bool listLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() => listLoading = true);
    try {
      final r = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (r.statusCode == 200) {
        setState(() {
          subjects = jsonDecode(r.body);
          listLoading = false;
        });
      } else {
        setState(() => listLoading = false);
      }
    } catch (_) {
      setState(() => listLoading = false);
    }
  }

  Future<void> _add() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() {
        msg = "Subject name is required.";
        isErr = true;
      });
      return;
    }
    setState(() {
      adding = true;
      msg = null;
    });
    try {
      final r = await http.post(
        Uri.parse("$baseUrl/subjects"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name}),
      );
      if (!mounted) return;
      if (r.statusCode == 200 || r.statusCode == 201) {
        setState(() {
          msg = "\"$name\" added!";
          isErr = false;
          nameCtrl.clear();
        });
        _loadSubjects();
      } else {
        setState(() {
          msg = "Failed. (${r.statusCode})";
          isErr = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          msg = "Connection error.";
          isErr = true;
        });
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  Future<void> _delete(dynamic s) async {
    final ok = await _confirm(
      context,
      "Delete subject?",
      "\"${s['name']}\" will be permanently removed.",
    );
    if (!ok) return;
    try {
      final r = await http.delete(Uri.parse("$baseUrl/subjects/${s['id']}"));
      if (!mounted) return;
      if (r.statusCode == 204) {
        setState(() {
          msg = "Deleted.";
          isErr = false;
        });
        _loadSubjects();
      } else {
        setState(() {
          msg = "Failed to delete.";
          isErr = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          msg = "Connection error.";
          isErr = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: "Add New Subject"),
              const SizedBox(height: 20),
              _lbl("SUBJECT NAME"),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: kCream, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "e.g. Quantum Computing",
                  hintStyle: TextStyle(color: kCreamDim),
                  prefixIcon: Icon(Icons.auto_stories_rounded),
                ),
              ),
              if (msg != null) ...[
                const SizedBox(height: 14),
                _Banner(message: msg!, isError: isErr ?? false),
              ],
              const SizedBox(height: 20),
              _GoldBtn(
                label: "ADD SUBJECT",
                icon: Icons.add_rounded,
                onTap: _add,
                loading: adding,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kGold.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kGold.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: kGoldDim, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "After adding, go to Assign to enroll students.",
                        style: TextStyle(color: kCreamDim, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(title: "All Subjects", count: subjects.length),
        const SizedBox(height: 12),
        if (listLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: kGold),
            ),
          )
        else if (subjects.isEmpty)
          const _Empty(message: "No subjects yet")
        else
          ...subjects.map(
            (s) => _Tile(
              primary: s['name'] ?? 'Unknown',
              icon: Icons.auto_stories_rounded,
              accent: kBlue,
              onDelete: () => _delete(s),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// 6. ASSIGN SUBJECT TAB
// ─────────────────────────────────────────────────────────
class AssignSubjectTab extends StatefulWidget {
  const AssignSubjectTab({super.key});
  @override
  State<AssignSubjectTab> createState() => _AssignSubjectTabState();
}

class _AssignSubjectTabState extends State<AssignSubjectTab> {
  List students = [], subjects = [];
  dynamic selStu, selSub;
  bool loading = true, assigning = false;
  String? msg;
  bool? isErr;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      msg = null;
    });
    try {
      final r1 = await http.get(Uri.parse("$baseUrl/management/students"));
      final r2 = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (r1.statusCode == 200 && r2.statusCode == 200) {
        setState(() {
          students = jsonDecode(r1.body);
          subjects = jsonDecode(r2.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _assign() async {
    if (selStu == null || selSub == null) {
      setState(() {
        msg = "Select both a student and a subject.";
        isErr = true;
      });
      return;
    }
    setState(() {
      assigning = true;
      msg = null;
    });
    try {
      final r = await http.post(
        Uri.parse(
          "$baseUrl/management/assign?studentId=${selStu['id']}&subjectId=${selSub['id']}",
        ),
      );
      if (!mounted) return;
      if (r.statusCode == 200) {
        setState(() {
          msg = "\"${selSub['name']}\" → ${selStu['name'] ?? selStu['email']}";
          isErr = false;
          selSub = null;
        });
      } else {
        setState(() {
          msg = "Failed to assign.";
          isErr = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          msg = "Connection error.";
          isErr = true;
        });
    } finally {
      if (mounted) setState(() => assigning = false);
    }
  }

  Widget _dropdown({
    required String hint,
    required List items,
    required dynamic value,
    required String Function(dynamic) labelOf,
    required void Function(dynamic) onChange,
    required IconData icon,
    required Color accent,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(
      color: kSurfaceHi,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: value != null ? accent.withOpacity(0.5) : kBorder,
        width: value != null ? 1.5 : 1,
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<dynamic>(
        value: value,
        isExpanded: true,
        dropdownColor: kSurface,
        icon: const Icon(Icons.expand_more_rounded, color: kCreamDim, size: 18),
        hint: Row(
          children: [
            Icon(icon, color: kCreamDim, size: 16),
            const SizedBox(width: 10),
            Text(hint, style: const TextStyle(color: kCreamDim, fontSize: 13)),
          ],
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Row(
                  children: [
                    Icon(icon, color: accent, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      labelOf(item),
                      style: const TextStyle(color: kCream, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => onChange(v)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(child: CircularProgressIndicator(color: kGold));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(title: "Assign Subject"),
              const SizedBox(height: 20),
              _lbl("STUDENT"),
              const SizedBox(height: 8),
              _dropdown(
                hint: "Select student",
                items: students,
                value: selStu,
                labelOf: (s) => s['name'] ?? s['email'] ?? 'Unknown',
                onChange: (v) {
                  selStu = v;
                  selSub = null;
                },
                icon: Icons.person_rounded,
                accent: kGold,
              ),
              const SizedBox(height: 16),
              _lbl("SUBJECT"),
              const SizedBox(height: 8),
              _dropdown(
                hint: "Select subject",
                items: subjects,
                value: selSub,
                labelOf: (s) => s['name'] ?? 'Unknown',
                onChange: (v) => selSub = v,
                icon: Icons.auto_stories_rounded,
                accent: kBlue,
              ),
              if (selStu != null && selSub != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: kGold,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Assign \"${selSub!['name']}\" to "
                          "${selStu!['name'] ?? selStu!['email']}",
                          style: const TextStyle(
                            color: kGoldLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (msg != null) ...[
                const SizedBox(height: 14),
                _Banner(message: msg!, isError: isErr ?? false),
              ],
              const SizedBox(height: 20),
              _GoldBtn(
                label: "CONFIRM ASSIGNMENT",
                icon: Icons.link_rounded,
                onTap: _assign,
                loading: assigning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// 7. STUDENT DASHBOARD
// ─────────────────────────────────────────────────────────
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List subjects = [];
  bool loading = true;
  String? error, email;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('userEmail');
    try {
      final r = await http.get(
        Uri.parse("$baseUrl/management/my-subjects?email=$email"),
      );
      if (r.statusCode == 200) {
        setState(() {
          subjects = jsonDecode(r.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          error = "Could not load.";
        });
      }
    } catch (_) {
      setState(() {
        loading = false;
        error = "Connection error.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kGold.withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      _bupBadge(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Courses",
                              style: TextStyle(
                                color: kCream,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (email != null)
                              Text(
                                email!,
                                style: const TextStyle(
                                  color: kCreamDim,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _logoutBtn(context),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _rule(),
                ),
                // Content
                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(color: kGold),
                        )
                      : error != null
                      ? _ErrorRetry(msg: error!, onRetry: _load)
                      : subjects.isEmpty
                      ? const _Empty(message: "No subjects assigned yet")
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: subjects.length,
                          itemBuilder: (ctx, i) {
                            final s = subjects[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: kSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: kGold.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${i + 1}",
                                        style: const TextStyle(
                                          color: kGold,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      s['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: kCream,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: kCreamDim,
                                    size: 18,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://192.168.0.8:8080/api";

// ── Tokens ─────────────────────────────────
const kBg = Color(0xFF0F0F13);
const kSurface = Color(0xFF1A1A22);
const kSurfaceHi = Color(0xFF242430);
const kBorder = Color(0xFF2E2E3A);
const kGold = Color(0xFFD4A853);
const kGoldLight = Color(0xFFF0C97A);
const kGoldDim = Color(0xFF8A6C30);
const kCream = Color(0xFFF5F0E8);
const kCreamDim = Color(0xFF9A9489);
const kRed = Color(0xFFE05C5C);
const kGreen = Color(0xFF5CBF8A);
const kBlue = Color(0xFF7C9EF0);
const kPurple = Color(0xFFB48EF0);

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'BUP Portal',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(surface: kSurface, primary: kGold),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceHi,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kGold, width: 1.5),
        ),
        labelStyle: const TextStyle(color: kCreamDim, fontSize: 13),
        prefixIconColor: kGoldDim,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGold,
          foregroundColor: kBg,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
      ),
    ),
    home: const LoginScreen(),
  );
}

// ─────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────

Widget _bupBadge({double size = 30, double font = 13}) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    color: kGold,
    borderRadius: BorderRadius.circular(size * 0.24),
  ),
  child: Center(
    child: Text(
      "B",
      style: TextStyle(color: kBg, fontWeight: FontWeight.w900, fontSize: font),
    ),
  ),
);

Widget _rule() => Container(
  height: 1,
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.transparent, kGold, Colors.transparent],
      stops: [0, .5, 1],
    ),
  ),
);

Widget _lbl(String t) => Text(
  t,
  style: const TextStyle(
    color: kCreamDim,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  ),
);

class _SectionTitle extends StatelessWidget {
  final String title;
  final int? count;
  const _SectionTitle({required this.title, this.count});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
          color: kGold,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(
          color: kCream,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (count != null) ...[
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: kGold.withOpacity(.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: kGold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ],
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kBorder),
    ),
    child: child,
  );
}

class _GoldBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool loading;
  const _GoldBtn({
    required this.label,
    required this.icon,
    this.onTap,
    this.loading = false,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: kBg, strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
    ),
  );
}

class _Banner extends StatelessWidget {
  final String message;
  final bool isError;
  const _Banner({required this.message, required this.isError});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: (isError ? kRed : kGreen).withOpacity(.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: (isError ? kRed : kGreen).withOpacity(.35)),
    ),
    child: Row(
      children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          size: 15,
          color: isError ? kRed : kGreen,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: isError ? kRed : kGreen,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Tile extends StatelessWidget {
  final String primary;
  final String? secondary;
  final IconData icon;
  final Color accent;
  final VoidCallback onDelete;
  const _Tile({
    required this.primary,
    this.secondary,
    required this.icon,
    required this.accent,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: kSurfaceHi,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kBorder),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: const TextStyle(
                  color: kCream,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (secondary != null)
                Text(
                  secondary!,
                  style: const TextStyle(color: kCreamDim, fontSize: 12),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kRed.withOpacity(.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: kRed,
              size: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 36, color: kBorder),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: kCreamDim, fontSize: 13)),
        ],
      ),
    ),
  );
}

class _ErrorRetry extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded, color: kCreamDim, size: 40),
        const SizedBox(height: 12),
        Text(msg, style: const TextStyle(color: kCreamDim, fontSize: 14)),
        const SizedBox(height: 16),
        SizedBox(
          width: 140,
          child: ElevatedButton(onPressed: onRetry, child: const Text("RETRY")),
        ),
      ],
    ),
  );
}

Widget _logoutBtn(BuildContext context) => GestureDetector(
  onTap: () => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  ),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: kSurfaceHi,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: kBorder),
    ),
    child: const Row(
      children: [
        Icon(Icons.logout_rounded, color: kCreamDim, size: 14),
        SizedBox(width: 5),
        Text("Logout", style: TextStyle(color: kCreamDim, fontSize: 12)),
      ],
    ),
  ),
);

void _snack(BuildContext ctx, String msg, {bool err = false}) =>
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              err ? Icons.error_outline : Icons.check_circle_outline,
              color: err ? kRed : kGreen,
              size: 15,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: kCream, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: kSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: err ? kRed : kGreen, width: .5),
        ),
        margin: const EdgeInsets.all(12),
      ),
    );

Future<bool> _confirm(BuildContext ctx, String title, String body) async =>
    await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: kBorder),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: kCream,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          body,
          style: const TextStyle(color: kCreamDim, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text("Cancel", style: TextStyle(color: kCreamDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: kRed),
            child: const Text(
              "Delete",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ) ??
    false;

// Modal helper
void _showModal(BuildContext context, Widget content) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: content,
    ),
  );
}

// ─────────────────────────────────────────
// 1. LOGIN
// ─────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false, obscure = true;

  Future<void> _login() async {
    setState(() => loading = true);
    try {
      final r = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailCtrl.text.trim(),
          "password": passCtrl.text.trim(),
        }),
      );
      if (!mounted) return;
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', emailCtrl.text.trim());
        await prefs.setString('userRole', data['role']);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => data['role'] == 'TEACHER'
                ? const TeacherDashboard()
                : const StudentDashboard(),
          ),
        );
      } else {
        _snack(context, "Invalid credentials", err: true);
      }
    } catch (_) {
      if (mounted) _snack(context, "Connection error", err: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kGold.withOpacity(.08), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kGold.withOpacity(.05), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  _bupBadge(size: 56, font: 16),
                  const SizedBox(height: 36),
                  const Text(
                    "Welcome\nback.",
                    style: TextStyle(
                      color: kCream,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign in to your portal",
                    style: TextStyle(color: kCreamDim, fontSize: 15),
                  ),
                  const SizedBox(height: 48),
                  _lbl("EMAIL ADDRESS"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: kCream, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "you@university.edu",
                      hintStyle: TextStyle(color: kCreamDim),
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _lbl("PASSWORD"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passCtrl,
                    obscureText: obscure,
                    style: const TextStyle(color: kCream, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "••••••••",
                      hintStyle: const TextStyle(color: kCreamDim),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: kCreamDim,
                          size: 18,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  _GoldBtn(
                    label: "SIGN IN",
                    icon: Icons.arrow_forward_rounded,
                    onTap: _login,
                    loading: loading,
                  ),
                  const SizedBox(height: 40),
                  _rule(),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Bangladesh University of Professionals",
                      style: TextStyle(
                        color: kCreamDim.withOpacity(.5),
                        fontSize: 11,
                        letterSpacing: .8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 2. TEACHER DASHBOARD SHELL
// ─────────────────────────────────────────
class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});
  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _idx = 0;
  static const _tabs = [
    (icon: Icons.grid_view_rounded, label: "Dashboard"),
    (icon: Icons.people_alt_rounded, label: "Students"),
    (icon: Icons.auto_stories_rounded, label: "Subjects"),
    (icon: Icons.link_rounded, label: "Assign"),
    (icon: Icons.bar_chart_rounded, label: "Stats"),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardTab(),
      const StudentsTab(),
      const SubjectsTab(),
      const AssignTab(),
      const StatsTab(),
    ];
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            _bupBadge(),
            const SizedBox(width: 10),
            Text(
              _tabs[_idx].label,
              style: const TextStyle(
                color: kCream,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _logoutBtn(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorder),
        ),
      ),
      body: pages[_idx],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(top: BorderSide(color: kBorder)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final sel = _idx == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _idx = i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: sel
                            ? kGold.withOpacity(.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _tabs[i].icon,
                            color: sel ? kGold : kCreamDim,
                            size: 19,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _tabs[i].label,
                            style: TextStyle(
                              color: sel ? kGold : kCreamDim,
                              fontSize: 9,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 3. DASHBOARD TAB (landing)
// ─────────────────────────────────────────
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  List students = [], subjects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r1 = await http.get(Uri.parse("$baseUrl/management/students"));
      final r2 = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (r1.statusCode == 200 && r2.statusCode == 200) {
        setState(() {
          students = jsonDecode(r1.body);
          subjects = jsonDecode(r2.body);
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  int get _totalEnrolments => students.fold(
    0,
    (s, e) => s + ((e['subjects'] as List?)?.length ?? 0) as int,
  );
  String get _avgPerStudent => students.isEmpty
      ? '0'
      : (_totalEnrolments / students.length).toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(child: CircularProgressIndicator(color: kGold));
    return RefreshIndicator(
      color: kGold,
      backgroundColor: kSurface,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI row
          Row(
            children: [
              _kpi(students.length, "Students", kGold),
              const SizedBox(width: 10),
              _kpi(subjects.length, "Subjects", kBlue),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kpi(_totalEnrolments, "Enrolments", kGreen),
              const SizedBox(width: 10),
              _kpiStr(_avgPerStudent, "Avg/Student", kPurple),
            ],
          ),
          const SizedBox(height: 24),
          // Quick actions
          const _SectionTitle(title: "Quick Actions"),
          const SizedBox(height: 12),
          _actionCard(
            context,
            Icons.person_add_alt_1_rounded,
            "Add Student",
            "Create a student account",
            kGold,
            () => _showModal(context, const _AddStudentForm()),
          ),
          _actionCard(
            context,
            Icons.library_add_rounded,
            "Add Subject",
            "Add to the academic catalogue",
            kBlue,
            () => _showModal(context, const _AddSubjectForm()),
          ),
          _actionCard(
            context,
            Icons.link_rounded,
            "Assign Subject",
            "Duplicate-safe enrolment",
            kGreen,
            () => _showModal(context, const _AssignForm()),
          ),
          _actionCard(
            context,
            Icons.bar_chart_rounded,
            "View Statistics",
            "Charts and analytics",
            kPurple,
            null,
          ),
          const SizedBox(height: 24),
          // Recent students preview
          const _SectionTitle(title: "Recent Students"),
          const SizedBox(height: 12),
          ...students.take(4).map((s) {
            final name = s['name'];
            final email = s['email'] ?? '';
            final subs = (s['subjects'] as List?) ?? [];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kGold.withOpacity(.15),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Text(
                        (name ?? email).isNotEmpty
                            ? (name ?? email)[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: kGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? email,
                          style: const TextStyle(
                            color: kCream,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (name != null)
                          Text(
                            email,
                            style: const TextStyle(
                              color: kCreamDim,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kGold.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${subs.length} courses",
                      style: const TextStyle(
                        color: kGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _kpi(int val, String lbl, Color accent) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            val.toString(),
            style: TextStyle(
              color: accent,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Text(lbl, style: const TextStyle(color: kCreamDim, fontSize: 12)),
        ],
      ),
    ),
  );

  Widget _kpiStr(String val, String lbl, Color accent) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            val,
            style: TextStyle(
              color: accent,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Text(lbl, style: const TextStyle(color: kCreamDim, fontSize: 12)),
        ],
      ),
    ),
  );

  Widget _actionCard(
    BuildContext ctx,
    IconData icon,
    String title,
    String desc,
    Color accent,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kCream,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(color: kCreamDim, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: kCreamDim,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 4. STUDENTS TAB
// ─────────────────────────────────────────
class StudentsTab extends StatefulWidget {
  const StudentsTab({super.key});
  @override
  State<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  List students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r = await http.get(Uri.parse("$baseUrl/management/students"));
      if (r.statusCode == 200)
        setState(() {
          students = jsonDecode(r.body);
          loading = false;
        });
      else
        setState(() => loading = false);
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _delete(dynamic s) async {
    final ok = await _confirm(
      context,
      "Delete student?",
      "\"${s['name'] ?? s['email']}\" will be removed.",
    );
    if (!ok) return;
    final r = await http.delete(
      Uri.parse("$baseUrl/management/users/${s['id']}"),
    );
    if (!mounted) return;
    if (r.statusCode == 204) {
      _snack(context, "Deleted.");
      _load();
    } else
      _snack(context, "Failed.", err: true);
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(child: CircularProgressIndicator(color: kGold));
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGold,
        foregroundColor: kBg,
        onPressed: () => _showModal(context, _AddStudentForm(onDone: _load)),
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        color: kGold,
        backgroundColor: kSurface,
        onRefresh: _load,
        child: students.isEmpty
            ? const _Empty(message: "No students yet")
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: students.length,
                itemBuilder: (_, i) {
                  final s = students[i];
                  final hasName =
                      s['name'] != null && s['name'].toString().isNotEmpty;
                  return _Tile(
                    primary: hasName ? s['name'] : s['email'] ?? 'Unknown',
                    secondary: hasName ? s['email'] : null,
                    icon: Icons.person_rounded,
                    accent: kGold,
                    onDelete: () => _delete(s),
                  );
                },
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 5. SUBJECTS TAB
// ─────────────────────────────────────────
class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});
  @override
  State<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<SubjectsTab> {
  List subjects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (r.statusCode == 200)
        setState(() {
          subjects = jsonDecode(r.body);
          loading = false;
        });
      else
        setState(() => loading = false);
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _delete(dynamic s) async {
    final ok = await _confirm(
      context,
      "Delete subject?",
      "\"${s['name']}\" will be removed.",
    );
    if (!ok) return;
    final r = await http.delete(Uri.parse("$baseUrl/subjects/${s['id']}"));
    if (!mounted) return;
    if (r.statusCode == 204) {
      _snack(context, "Deleted.");
      _load();
    } else
      _snack(context, "Failed.", err: true);
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(child: CircularProgressIndicator(color: kGold));
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGold,
        foregroundColor: kBg,
        onPressed: () => _showModal(context, _AddSubjectForm(onDone: _load)),
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        color: kGold,
        backgroundColor: kSurface,
        onRefresh: _load,
        child: subjects.isEmpty
            ? const _Empty(message: "No subjects yet")
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subjects.length,
                itemBuilder: (_, i) {
                  final s = subjects[i];
                  return _Tile(
                    primary: s['name'] ?? 'Unknown',
                    icon: Icons.auto_stories_rounded,
                    accent: kBlue,
                    onDelete: () => _delete(s),
                  );
                },
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 6. ASSIGN TAB
// ─────────────────────────────────────────
class AssignTab extends StatefulWidget {
  const AssignTab({super.key});
  @override
  State<AssignTab> createState() => _AssignTabState();
}

class _AssignTabState extends State<AssignTab> {
  List students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r = await http.get(Uri.parse("$baseUrl/management/students"));
      if (r.statusCode == 200)
        setState(() {
          students = jsonDecode(r.body);
          loading = false;
        });
      else
        setState(() => loading = false);
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(child: CircularProgressIndicator(color: kGold));
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGold,
        foregroundColor: kBg,
        onPressed: () => _showModal(context, _AssignForm(onDone: _load)),
        child: const Icon(Icons.link_rounded),
      ),
      body: RefreshIndicator(
        color: kGold,
        backgroundColor: kSurface,
        onRefresh: _load,
        child: students.isEmpty
            ? const _Empty(message: "No students yet")
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _SectionTitle(title: "Student Enrolment Overview"),
                  const SizedBox(height: 12),
                  ...students.map((s) {
                    final subs = (s['subjects'] as List?) ?? [];
                    final name = s['name'];
                    final email = s['email'] ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: kGold.withOpacity(.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    (name ?? email).isNotEmpty
                                        ? (name ?? email)[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: kGold,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name ?? email,
                                      style: const TextStyle(
                                        color: kCream,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (name != null)
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          color: kCreamDim,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: kGold.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${subs.length} courses",
                                  style: const TextStyle(
                                    color: kGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (subs.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(height: .5, color: kBorder),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 5,
                              children: subs
                                  .map(
                                    (sub) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kSurfaceHi,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: kBorder),
                                      ),
                                      child: Text(
                                        sub['name'] ?? '',
                                        style: const TextStyle(
                                          color: kCreamDim,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if (subs.isEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              "No subjects assigned yet",
                              style: TextStyle(
                                color: kCreamDim,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 7. STATS TAB
// ─────────────────────────────────────────
class StatsTab extends StatefulWidget {
  const StatsTab({super.key});
  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  List students = [], subjects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r1 = await http.get(Uri.parse("$baseUrl/management/students"));
      final r2 = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (r1.statusCode == 200 && r2.statusCode == 200) {
        setState(() {
          students = jsonDecode(r1.body);
          subjects = jsonDecode(r2.body);
          loading = false;
        });
      } else
        setState(() => loading = false);
    } catch (_) {
      setState(() => loading = false);
    }
  }

  int get _totalEnrolments => students.fold(
    0,
    (s, e) => s + ((e['subjects'] as List?)?.length ?? 0) as int,
  );

  List<Map<String, dynamic>> get _subjectPopularity {
    final counts = <int, int>{};
    for (final s in students) {
      for (final sub in (s['subjects'] as List?) ?? []) {
        counts[sub['id']] = (counts[sub['id']] ?? 0) + 1;
      }
    }
    final result = subjects
        .map(
          (s) => {
            'name': s['name'],
            'id': s['id'],
            'count': counts[s['id']] ?? 0,
          },
        )
        .toList();
    result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return result;
  }

  List<Map<String, dynamic>> get _studentLoad {
    return students
        .map(
          (s) => {
            'name': s['name'] ?? s['email'] ?? '?',
            'count': (s['subjects'] as List?)?.length ?? 0,
          },
        )
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(child: CircularProgressIndicator(color: kGold));
    final pop = _subjectPopularity;
    final load = _studentLoad;
    final maxPop = pop.isEmpty
        ? 1
        : math.max(1, pop.map((e) => e['count'] as int).reduce(math.max));
    final maxLoad = load.isEmpty
        ? 1
        : math.max(1, load.map((e) => e['count'] as int).reduce(math.max));

    return RefreshIndicator(
      color: kGold,
      backgroundColor: kSurface,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI cards
          Row(
            children: [
              _kpi(students.length, "Students", kGold),
              const SizedBox(width: 10),
              _kpi(subjects.length, "Subjects", kBlue),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _kpi(_totalEnrolments, "Enrolments", kGreen),
              const SizedBox(width: 10),
              _kpi(
                students.isEmpty
                    ? 0
                    : (_totalEnrolments / students.length).round(),
                "Avg/Student",
                kPurple,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Subject popularity
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: "Subject Popularity"),
                const SizedBox(height: 4),
                Text(
                  "Enrolment count per subject",
                  style: const TextStyle(color: kCreamDim, fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (pop.isEmpty) const _Empty(message: "No data yet"),
                ...pop.map(
                  (d) => _barRow(d['name'], d['count'] as int, maxPop, kGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Student course load
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: "Student Course Load"),
                const SizedBox(height: 4),
                const Text(
                  "Subjects per student",
                  style: TextStyle(color: kCreamDim, fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (load.isEmpty) const _Empty(message: "No data yet"),
                ...load.map(
                  (d) => _barRow(d['name'], d['count'] as int, maxLoad, kBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Distribution
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: "Enrolment Distribution"),
                const SizedBox(height: 4),
                const Text(
                  "Students grouped by course load",
                  style: TextStyle(color: kCreamDim, fontSize: 12),
                ),
                const SizedBox(height: 16),
                ..._distData().map((d) => _distRow(d)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top subject spotlight
          if (pop.isNotEmpty)
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _SectionTitle(title: "Top Subject"),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _RingPainter(
                        pct: students.isEmpty
                            ? 0
                            : (pop[0]['count'] as int) / students.length,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${students.isEmpty ? 0 : ((pop[0]['count'] as int) / students.length * 100).round()}%",
                              style: const TextStyle(
                                color: kGold,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pop[0]['name'],
                    style: const TextStyle(
                      color: kGoldLight,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${pop[0]['count']} students enrolled",
                    style: const TextStyle(color: kCreamDim, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _kpi(int val, String lbl, Color accent) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            val.toString(),
            style: TextStyle(
              color: accent,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          Text(lbl, style: const TextStyle(color: kCreamDim, fontSize: 12)),
        ],
      ),
    ),
  );

  Widget _barRow(String label, int count, int max, Color accent) {
    final pct = max == 0 ? 0.0 : count / max;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: kCreamDim, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 22,
                color: kSurfaceHi,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: pct.clamp(0.0, 1.0),
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent.withOpacity(.5), accent],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: TextStyle(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _distData() {
    final d = {'0': 0, '1–2': 0, '3–4': 0, '5+': 0};
    for (final s in students) {
      final n = (s['subjects'] as List?)?.length ?? 0;
      if (n == 0)
        d['0'] = d['0']! + 1;
      else if (n <= 2)
        d['1–2'] = d['1–2']! + 1;
      else if (n <= 4)
        d['3–4'] = d['3–4']! + 1;
      else
        d['5+'] = d['5+']! + 1;
    }
    final colors = [kRed, kGold, kBlue, kGreen];
    int i = 0;
    return d.entries
        .map(
          (e) => {
            'label': '${e.key} subjects',
            'count': e.value,
            'color': colors[i++],
          },
        )
        .toList();
  }

  Widget _distRow(Map<String, dynamic> d) {
    final pct = students.isEmpty ? 0.0 : (d['count'] as int) / students.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: d['color'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              d['label'],
              style: const TextStyle(color: kCreamDim, fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 24,
            child: Text(
              (d['count'] as int).toString(),
              style: const TextStyle(
                color: kCream,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 8,
                color: kSurfaceHi,
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: pct.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: d['color'] as Color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Ring painter for stats
class _RingPainter extends CustomPainter {
  final double pct;
  const _RingPainter({required this.pct});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = (size.width - 16) / 2;
    final bg = Paint()
      ..color = kSurfaceHi
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = kGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bg);
    final sweep = 2 * math.pi * pct.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pct != pct;
}

// ─────────────────────────────────────────
// MODAL FORMS
// ─────────────────────────────────────────
class _AddStudentForm extends StatefulWidget {
  final VoidCallback? onDone;
  const _AddStudentForm({this.onDone});
  @override
  State<_AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<_AddStudentForm> {
  final nameCtrl = TextEditingController(),
      emailCtrl = TextEditingController(),
      passCtrl = TextEditingController();
  bool loading = false, obscure = true;
  String? msg;
  bool? isErr;

  Future<void> _add() async {
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      setState(() {
        msg = "Email and password are required.";
        isErr = true;
      });
      return;
    }
    setState(() {
      loading = true;
      msg = null;
    });
    try {
      final body = <String, dynamic>{
        "email": emailCtrl.text.trim(),
        "password": passCtrl.text.trim(),
        "role": "STUDENT",
      };
      if (nameCtrl.text.trim().isNotEmpty) body["name"] = nameCtrl.text.trim();
      final r = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (!mounted) return;
      if (r.statusCode == 200) {
        setState(() {
          msg = "Student added!";
          isErr = false;
          nameCtrl.clear();
          emailCtrl.clear();
          passCtrl.clear();
        });
        widget.onDone?.call();
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          msg = r.body.isNotEmpty ? r.body : "Failed.";
          isErr = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          msg = "Connection error.";
          isErr = true;
        });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle(title: "Add New Student"),
      const SizedBox(height: 20),
      _lbl("FULL NAME"),
      const SizedBox(height: 6),
      TextField(
        controller: nameCtrl,
        style: const TextStyle(color: kCream, fontSize: 14),
        decoration: const InputDecoration(
          hintText: "Optional",
          hintStyle: TextStyle(color: kCreamDim),
          prefixIcon: Icon(Icons.badge_outlined),
        ),
      ),
      const SizedBox(height: 14),
      _lbl("EMAIL *"),
      const SizedBox(height: 6),
      TextField(
        controller: emailCtrl,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: kCream, fontSize: 14),
        decoration: const InputDecoration(
          hintText: "student@bup.edu.bd",
          hintStyle: TextStyle(color: kCreamDim),
          prefixIcon: Icon(Icons.alternate_email_rounded),
        ),
      ),
      const SizedBox(height: 14),
      _lbl("PASSWORD *"),
      const SizedBox(height: 6),
      TextField(
        controller: passCtrl,
        obscureText: obscure,
        style: const TextStyle(color: kCream, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Set a password",
          hintStyle: const TextStyle(color: kCreamDim),
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: kCreamDim,
              size: 18,
            ),
            onPressed: () => setState(() => obscure = !obscure),
          ),
        ),
      ),
      if (msg != null) ...[
        const SizedBox(height: 14),
        _Banner(message: msg!, isError: isErr ?? false),
      ],
      const SizedBox(height: 20),
      _GoldBtn(
        label: "ADD STUDENT",
        icon: Icons.person_add_rounded,
        onTap: _add,
        loading: loading,
      ),
    ],
  );
}

class _AddSubjectForm extends StatefulWidget {
  final VoidCallback? onDone;
  const _AddSubjectForm({this.onDone});
  @override
  State<_AddSubjectForm> createState() => _AddSubjectFormState();
}

class _AddSubjectFormState extends State<_AddSubjectForm> {
  final nameCtrl = TextEditingController();
  bool loading = false;
  String? msg;
  bool? isErr;

  Future<void> _add() async {
    if (nameCtrl.text.trim().isEmpty) {
      setState(() {
        msg = "Name required.";
        isErr = true;
      });
      return;
    }
    setState(() {
      loading = true;
      msg = null;
    });
    try {
      final r = await http.post(
        Uri.parse("$baseUrl/subjects"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": nameCtrl.text.trim()}),
      );
      if (!mounted) return;
      if (r.statusCode == 200 || r.statusCode == 201) {
        setState(() {
          msg = "Subject added!";
          isErr = false;
          nameCtrl.clear();
        });
        widget.onDone?.call();
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          msg = "Failed. (${r.statusCode})";
          isErr = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          msg = "Connection error.";
          isErr = true;
        });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _SectionTitle(title: "Add New Subject"),
      const SizedBox(height: 20),
      _lbl("SUBJECT NAME *"),
      const SizedBox(height: 6),
      TextField(
        controller: nameCtrl,
        style: const TextStyle(color: kCream, fontSize: 14),
        decoration: const InputDecoration(
          hintText: "e.g. Quantum Computing",
          hintStyle: TextStyle(color: kCreamDim),
          prefixIcon: Icon(Icons.auto_stories_rounded),
        ),
      ),
      if (msg != null) ...[
        const SizedBox(height: 14),
        _Banner(message: msg!, isError: isErr ?? false),
      ],
      const SizedBox(height: 20),
      _GoldBtn(
        label: "ADD SUBJECT",
        icon: Icons.add_rounded,
        onTap: _add,
        loading: loading,
      ),
    ],
  );
}

class _AssignForm extends StatefulWidget {
  final VoidCallback? onDone;
  const _AssignForm({this.onDone});
  @override
  State<_AssignForm> createState() => _AssignFormState();
}

class _AssignFormState extends State<_AssignForm> {
  List students = [], subjects = [], studentSubjects = [];
  dynamic selStu, selSub;
  bool loading = true, loadingStuSubs = false, assigning = false;
  String? msg;
  bool? isErr;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final r1 = await http.get(Uri.parse("$baseUrl/management/students"));
      final r2 = await http.get(Uri.parse("$baseUrl/management/subjects"));
      if (r1.statusCode == 200 && r2.statusCode == 200) {
        setState(() {
          students = jsonDecode(r1.body);
          subjects = jsonDecode(r2.body);
          loading = false;
        });
      } else
        setState(() => loading = false);
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> _onStudentSelected(dynamic s) async {
    setState(() {
      selStu = s;
      selSub = null;
      studentSubjects = [];
      loadingStuSubs = true;
      msg = null;
    });
    try {
      final r = await http.get(
        Uri.parse("$baseUrl/management/student-details/${s['id']}"),
      );
      if (r.statusCode == 200)
        setState(() {
          studentSubjects = jsonDecode(r.body);
          loadingStuSubs = false;
        });
      else
        setState(() => loadingStuSubs = false);
    } catch (_) {
      setState(() => loadingStuSubs = false);
    }
  }

  List get _availableSubjects => subjects
      .where((s) => !studentSubjects.any((ss) => ss['id'] == s['id']))
      .toList();

  Future<void> _assign() async {
    if (selStu == null || selSub == null) {
      setState(() {
        msg = "Select both student and subject.";
        isErr = true;
      });
      return;
    }
    setState(() {
      assigning = true;
      msg = null;
    });
    try {
      final r = await http.post(
        Uri.parse(
          "$baseUrl/management/assign?studentId=${selStu['id']}&subjectId=${selSub['id']}",
        ),
      );
      if (!mounted) return;
      if (r.statusCode == 200) {
        setState(() {
          msg = "\"${selSub['name']}\" → ${selStu['name'] ?? selStu['email']}";
          isErr = false;
          selSub = null;
        });
        _onStudentSelected(selStu);
        widget.onDone?.call();
      } else {
        setState(() {
          msg = "Failed.";
          isErr = true;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          msg = "Connection error.";
          isErr = true;
        });
    } finally {
      if (mounted) setState(() => assigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: kGold)),
      );
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: "Assign Subject"),
          const SizedBox(height: 20),
          _lbl("SELECT STUDENT"), const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kSurfaceHi,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                value: selStu,
                isExpanded: true,
                dropdownColor: kSurface,
                icon: const Icon(
                  Icons.expand_more_rounded,
                  color: kCreamDim,
                  size: 18,
                ),
                hint: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "— choose student —",
                    style: TextStyle(color: kCreamDim, fontSize: 13),
                  ),
                ),
                items: students
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            s['name'] ?? s['email'] ?? 'Unknown',
                            style: const TextStyle(color: kCream, fontSize: 13),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => _onStudentSelected(v),
              ),
            ),
          ),

          // Current subjects
          if (selStu != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kSurfaceHi,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Already enrolled:",
                        style: TextStyle(
                          color: kCreamDim,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (loadingStuSubs) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            color: kGold,
                            strokeWidth: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!loadingStuSubs)
                    studentSubjects.isEmpty
                        ? const Text(
                            "None yet",
                            style: TextStyle(
                              color: kCreamDim,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: studentSubjects
                                .map(
                                  (s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kGold.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: kGold.withOpacity(.3),
                                      ),
                                    ),
                                    child: Text(
                                      s['name'] ?? '',
                                      style: const TextStyle(
                                        color: kGold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          _lbl(
            "SELECT SUBJECT ${_availableSubjects.isEmpty && selStu != null ? '(ALL ASSIGNED)' : ''}",
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: kSurfaceHi,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                value: selSub,
                isExpanded: true,
                dropdownColor: kSurface,
                icon: const Icon(
                  Icons.expand_more_rounded,
                  color: kCreamDim,
                  size: 18,
                ),
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _availableSubjects.isEmpty && selStu != null
                        ? "All subjects assigned!"
                        : "— choose subject —",
                    style: const TextStyle(color: kCreamDim, fontSize: 13),
                  ),
                ),
                items: _availableSubjects
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            s['name'] ?? 'Unknown',
                            style: const TextStyle(color: kCream, fontSize: 13),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _availableSubjects.isEmpty
                    ? null
                    : (v) => setState(() => selSub = v),
              ),
            ),
          ),

          if (selStu != null && selSub != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kGold.withOpacity(.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kGold.withOpacity(.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: kGold,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Assign \"${selSub['name']}\" to ${selStu['name'] ?? selStu['email']}",
                      style: const TextStyle(
                        color: kGoldLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (msg != null) ...[
            const SizedBox(height: 14),
            _Banner(message: msg!, isError: isErr ?? false),
          ],
          const SizedBox(height: 20),
          _GoldBtn(
            label: "CONFIRM ASSIGNMENT",
            icon: Icons.link_rounded,
            onTap: _assign,
            loading: assigning,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// STUDENT DASHBOARD
// ─────────────────────────────────────────
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List subjects = [];
  bool loading = true;
  String? error, email;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString('userEmail');
    try {
      final r = await http.get(
        Uri.parse("$baseUrl/management/my-subjects?email=$email"),
      );
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        setState(() {
          subjects = data is List ? data : (data['subjects'] ?? []);
          loading = false;
        });
      } else
        setState(() {
          loading = false;
          error = "Could not load.";
        });
    } catch (_) {
      setState(() {
        loading = false;
        error = "Connection error.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kGold.withOpacity(.06), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      _bupBadge(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Courses",
                              style: TextStyle(
                                color: kCream,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (email != null)
                              Text(
                                email!,
                                style: const TextStyle(
                                  color: kCreamDim,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _logoutBtn(context),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _rule(),
                ),

                // Stat card
                if (!loading && error == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: kGold.withOpacity(.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: kGold,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subjects.length.toString(),
                                style: const TextStyle(
                                  color: kGold,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                              const Text(
                                "Enrolled Courses",
                                style: TextStyle(
                                  color: kCreamDim,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(color: kGold),
                        )
                      : error != null
                      ? _ErrorRetry(msg: error!, onRetry: _load)
                      : subjects.isEmpty
                      ? const _Empty(message: "No subjects assigned yet")
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: subjects.length,
                          itemBuilder: (ctx, i) {
                            final s = subjects[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: kSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: kGold.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${i + 1}",
                                        style: const TextStyle(
                                          color: kGold,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      s['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: kCream,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: kCreamDim,
                                    size: 18,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
