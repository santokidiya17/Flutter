import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseDemo extends StatefulWidget {
  const DatabaseDemo({super.key});

  @override
  State<DatabaseDemo> createState() => _DatabaseDemoState();
}

class _DatabaseDemoState extends State<DatabaseDemo> {
  late Database database;
  TextEditingController title = TextEditingController();
  TextEditingController desc = TextEditingController();

  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    database = await openDatabase(join(await getDatabasesPath(), 'lab.db'),
        onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE DEMO(ID INTEGER PRIMARY KEY AUTOINCREMENT,TITLE TEXT,DESC TEXT)',
      );
    }, version: 1);
  }

  Future<void> fetchData() async {
    List<Map<String, dynamic>> tempdata = await database.query('DEMO');
    setState(() {
      data = tempdata;
    });
  }

  Future<void> addData(String title, String desc) async {
    if (title.isNotEmpty && desc.isNotEmpty) {
      await database.insert('DEMO', {'TITLE': title, 'DESC': desc});
    }
    fetchData();
  }

  Future<void> updateData(int id,String title,String desc) async{
    if(title.isNotEmpty && desc.isNotEmpty){
      await database.update('DEMO', {'TITLE': title, 'DESC': desc},where: 'ID = ?',whereArgs: [id]);
    }
    fetchData();
  }
  Future<void> deletedata(int id)async{
    await database.delete('DEMO',where: 'ID = ?',whereArgs: [id]);
    fetchData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Database Demo"),
      ),
        floatingActionButton: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      children: [
                        TextField(
                          controller: title,
                        ),
                        TextField(
                          controller: desc,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              addData(title.text, desc.text);
                              title.clear();
                              desc.clear();
                              Navigator.pop(context);
                            },
                            child: Text('Submit'))
                      ],
                    );
                  });
            },
            child: Text('ADD')),
        body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(data[index]['TITLE']?.toString() ?? 'No Title'),
              // Handle null case
              subtitle:
                  Text(data[index]['DESC']?.toString() ?? 'No Description'),
              trailing:Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: (){
                     title.text = data[index]['TITLE']?.toString() ?? 'No Title';
                     desc.text = data[index]['DESC']?.toString() ?? 'No Description';
                    showModalBottomSheet(context: context, builder: (context) {
                      return Column(
                        children: [
                          TextField(
                            controller: title,
                          ),
                          TextField(
                            controller: desc,
                          ),
                          ElevatedButton(
                              onPressed: (){
                            updateData(data[index]["ID"],title.text, desc.text);
                            title.clear();
                            desc.clear();
                            Navigator.pop(context);
                          },
                              child: Text("update"))
                        ],
                      );
                    },);
                  }, icon:Icon(Icons.edit)),
                  IconButton(onPressed: (){
                    deletedata(data[index]["ID"]);
                  }, icon:Icon(Icons.delete))
                ],
              ),
            );
          },
        ));
  }
}
