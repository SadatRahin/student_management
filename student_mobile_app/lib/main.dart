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
