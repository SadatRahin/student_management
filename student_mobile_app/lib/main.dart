import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      home: const HomeScreen(),
    );
  }
}

// --- MAIN HOME SCREEN WITH TABS ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 192.168.100.151 is your Golden Number IP
    const String baseUrl = "http://192.168.100.151:8080/api";

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Management System"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Students"),
              Tab(icon: Icon(Icons.book), text: "Subjects"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DataListScreen(type: "students", baseUrl: baseUrl),
            DataListScreen(type: "subjects", baseUrl: baseUrl),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE LIST SCREEN FOR BOTH STUDENTS & SUBJECTS ---
class DataListScreen extends StatefulWidget {
  final String type; // "students" or "subjects"
  final String baseUrl;

  const DataListScreen({super.key, required this.type, required this.baseUrl});

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
      final response = await http.get(Uri.parse("${widget.baseUrl}/${widget.type}"));
      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final String name = item['name']?.toString() ?? "Unknown";
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Icon(widget.type == "students" ? Icons.person : Icons.menu_book),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.type == "students" ? (item['email'] ?? "") : "Click to see enrolled students"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(
                    id: item['id'],
                    displayName: name,
                    baseUrl: widget.baseUrl,
                    viewType: widget.type, // Tells details screen if it's showing subjects or students
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// --- DETAILS SCREEN (Shows the Relationships) ---
class DetailsScreen extends StatefulWidget {
  final int id;
  final String displayName;
  final String baseUrl;
  final String viewType;

  const DetailsScreen({
    super.key,
    required this.id,
    required this.displayName,
    required this.baseUrl,
    required this.viewType,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List relatedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    // Logic: If viewing a student, fetch their subjects. 
    // If viewing a subject, fetch its students.
    String endpoint = widget.viewType == "students" 
        ? "/student-subjects/student/${widget.id}" 
        : "/student-subjects/subject-details/${widget.id}";

    try {
      final response = await http.get(Uri.parse("${widget.baseUrl}$endpoint"));
      if (response.statusCode == 200) {
        setState(() {
          relatedItems = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = widget.viewType == "students" 
        ? "${widget.displayName}'s Courses" 
        : "Students in ${widget.displayName}";

    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : relatedItems.isEmpty
              ? const Center(child: Text("No data found."))
              : ListView.builder(
                  itemCount: relatedItems.length,
                  itemBuilder: (context, index) {
                    final item = relatedItems[index];
                    return ListTile(
                      leading: Icon(widget.viewType == "students" ? Icons.book : Icons.person_outline),
                      title: Text(item['name']?.toString() ?? "Unknown"),
                    );
                  },
                ),
    );
  }
}