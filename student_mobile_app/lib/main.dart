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
