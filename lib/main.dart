import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.init();
  runApp(MyApp(dbHelper: dbHelper));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Simple SQL App')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Enter Name'),
                  ),
                ),
                ElevatedButton(onPressed: _addRecord, child: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_records[index]['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteRecord(_records[index]['_id']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
