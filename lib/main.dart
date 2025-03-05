import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  dbHelper.init().then((_) {
    runApp(MyApp(dbHelper: dbHelper));
  });
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp({Key? key, required this.dbHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(dbHelper: dbHelper),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const HomeScreen({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //setting colorscheme
  Color background = Color(0xFF558C8C);
  Color background2 = Color(0xFFE8DB7D);
  Color accent1 = Color(0xFF82204A);
  Color accent2 = Color(0xFF7DDF64);
  Color text = Color(0xFFEFF7FF);
  Color text2 = Color(0xFF231123);

  List<Map<String, dynamic>> _records = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final data = await widget.dbHelper.queryAllRows();
    setState(() {
      _records = data;
    });
  }

  Future<void> _addRecord() async {
    if (_nameController.text.isEmpty) return;
    await widget.dbHelper.insert({'name': _nameController.text});
    _nameController.clear();
    _loadRecords();
  }

  Future<void> _deleteRecord(int id) async {
    await widget.dbHelper.delete(id);
    _loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    List folders = ['Heart', 'Spades', 'Diamonds', 'Clubs'];
    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer App')),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.start, // Align all children to the start
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Enter Name'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 70.0,
              ), // Add vertical padding
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Center(
                  child: GridView.builder(
                    itemCount: folders.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      mainAxisSpacing: 8, // Space between rows
                      crossAxisSpacing: 8, // Space between cols
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        height: 5,
                        width: 5,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent1,
                          ),
                          onPressed: () {},
                          child: Center(
                            child: Text(
                              folders[index],
                              style: TextStyle(fontSize: 50, color: text),
                            ),
                          ),
                        ),
                      );
                    },
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
