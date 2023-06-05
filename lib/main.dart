import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());


class AvatarGlow extends StatefulWidget {
  final bool animate;
  final Color glowColor;
  final double endRadius;
  final Duration duration;
  final Duration repeatPauseDuration;
  final bool repeat;
  final Widget child;

  const AvatarGlow({
    Key? key,
    required this.animate,
    required this.glowColor,
    required this.endRadius,
    required this.duration,
    required this.repeatPauseDuration,
    required this.repeat,
    required this.child,
  }) : super(key: key);

  @override
  _AvatarGlowState createState() => _AvatarGlowState();
}

class _AvatarGlowState extends State<AvatarGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    if (widget.repeat) {
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(widget.repeatPauseDuration, () {
            _animationController.reverse();
          });
        } else if (status == AnimationStatus.dismissed) {
          Future.delayed(widget.repeatPauseDuration, () {
            _animationController.forward();
          });
        }
      });
    }
    if (widget.animate) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.endRadius * 2,
          height: widget.endRadius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.glowColor.withOpacity(
              0.6 * _animationController.value,
            ),
          ),
          child: Center(child: widget.child),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/tutorial1.PNG'),
            SizedBox(height: 40),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondScreen()),
                );
              },
              icon: Icon(Icons.add, size:40),
              label: Text('Añadir lista'),
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(350, 80),
                  textStyle: TextStyle(fontSize: 30)
              ),

            ),
            SizedBox(height: 40),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedListsScreen()),
                );
              },
              icon: Icon(Icons.menu, size:40) ,
              label: Text('Mis listas'),
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(350, 80),
                  textStyle: TextStyle(fontSize: 30)
              ),
            ),
            SizedBox(height: 40),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyScreen()),
                );
              },
              icon: Icon(Icons.help_outline,size:40),
              label: Text('Tutorial'),
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size(350, 80),
                  textStyle: TextStyle(fontSize: 30)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}
class MyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My List'),
      ),
      body: Center(
        child: Text('My List Page'),
      ),
    );
  }
}class _SecondScreenState extends State<SecondScreen> {
  List<String> itemList = [];
  List<bool> itemSelected = [];
  String listName = '';
  String newItem = '';
  bool _isListening = false;
  double _confidence = 1.0;
  String _text = 'Press the button and start speaking';
  late stt.SpeechToText _speech;
  stt.SpeechToText speech = stt.SpeechToText();

  void addItem(String item) {
    setState(() {
      itemList.add(item);
      itemSelected.add(false);
    });
  }

  void removeItem(int index) {
    setState(() {
      itemList.removeAt(index);
      itemSelected.removeAt(index);
    });
  }
  Future<void> startListening() async {
    await speech.initialize();
    if (speech.isAvailable) {
      await speech.listen(
        onResult: (result) {
          setState(() {
            String newItem = result.recognizedWords;
            if (newItem.isNotEmpty) {
              addItem(newItem);
            }
          });
        },
      );
    }
  }

  void stopListening() {
    speech.stop();
  }

  void showAddItemDialogVoice(BuildContext context) {
    String dictatedText = 'Patatas';

    Timer(Duration(milliseconds: 1000), () {
      setState(() {
        dictatedText = '';
      });
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Añadir elemento por voz'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Haz clic en el botón para empezar a escuchar:',
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 25),
                    Text(
                      dictatedText,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        children: [
                          AvatarGlow(
                            animate: true,
                            glowColor: Theme.of(context).primaryColor,
                            endRadius: 75.0,
                            duration: const Duration(milliseconds: 2000),
                            repeatPauseDuration: const Duration(milliseconds: 100),
                            repeat: true,
                            child: FloatingActionButton(
                              onPressed: _listen,
                              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  stopListening();
                                  Navigator.pop(context);
                                },
                                child: Text('Cancelar', style: TextStyle(fontSize: 30.0)),
                              ),
                              TextButton(
                                onPressed: () {
                                  stopListening();
                                  Navigator.pop(context);
                                  // Aquí puedes realizar alguna acción con el texto reconocido
                                },
                                child: Text('Añadir', style: TextStyle(fontSize: 30.0)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }







  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void showAddItemDialog(BuildContext context) {
    String newItem = '';

    Navigator.push(
      context,
      PageRouteBuilder(
        fullscreenDialog: true,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Añadir elemento'),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Introduce el texto:',
                          style: TextStyle(fontSize: 30.0),
                        ),
                        SizedBox(height: 30.0),
                        TextField(
                          style: TextStyle(fontSize: 40.0), // Tamaño del texto aumentado
                          onChanged: (value) {
                            newItem = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          addItem(newItem);
                          Navigator.pop(context);
                        },
                        child: Text('Añadir', style: TextStyle(fontSize: 30.0)),

                      ),
                      SizedBox(width: 8.0),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar', style: TextStyle(fontSize: 30.0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  void showDialogGuardar(BuildContext context) {
    String newItem = '';

    Navigator.push(
      context,
      PageRouteBuilder(
        fullscreenDialog: true,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Guardar lista'),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Introduce nombre de la lista:',
                          style: TextStyle(fontSize: 30.0),
                        ),
                        SizedBox(height: 30.0),
                        TextField(
                          style: TextStyle(fontSize: 40.0), // Tamaño del texto aumentado
                            onChanged: (value) {
                              listName = value;
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          final dbHelper = DatabaseHelper._instance;
                          dbHelper.saveList(itemList, listName);
                          Navigator.pop(context);
                        },
                        child: Text('Añadir', style: TextStyle(fontSize: 30.0)),

                      ),
                      SizedBox(width: 8.0),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar', style: TextStyle(fontSize: 30.0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  void saveList(List<String> items, String name) {
    // Aquí puedes guardar la lista de items bajo el nombre especificado
    // por ejemplo, puedes utilizar SharedPreferences o guardar en una base de datos
    print('Guardando lista "$name" con los siguientes elementos:');
    for (String item in items) {
      print('- $item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir lista'),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showAddItemDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 108),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Añadir Manualmente',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.keyboard,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showAddItemDialogVoice(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 108),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 9),
                      Text(
                        'Añadir por Voz',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.mic,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: itemList.isEmpty
                ? Container(
              child: Text(
                'Lista vacía',
                style: TextStyle(fontSize: 30),
              ),
            )
                : ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    tileColor: Colors.white, // Agregado
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.volume_up_rounded, size: 40),
                      onPressed: () async {
                        print(itemList[index]);
                      },
                    ),
                    title: Text(
                      itemList[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: itemSelected[index]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontSize: 30,
                        color: itemSelected[index] ? Colors.red : Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, size: 40),
                      onPressed: () {
                        removeItem(index);
                      },
                    ),
                    onTap: () {
                      setState(() {
                        itemSelected[index] = !itemSelected[index];
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Confirmar eliminación',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          content: Text(
                            '¿Estás seguro de que deseas eliminar la lista?',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  itemList.clear();
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontSize: 23,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 23,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 80),
                    primary: Colors.red,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Eliminar Lista',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.delete,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialogGuardar(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 80),
                    primary: Colors.blue,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Guardar lista',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.save,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (int i = 0; i < itemSelected.length; i++) {
                        itemSelected[i] = false;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 80),
                    primary: Colors.green,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Restaurar lista',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.remove_red_eye,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}





class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initializeDatabase();
    return _database!;
  }
  void saveList(List<String> itemList, String name) async {
    final db = await database;

    final listAsString = itemList.join(',');

    await db.insert('lists', {'name': name, 'items': listAsString});

    print('Guardando lista "$name" con los siguientes elementos:');
    print('- $listAsString');
  }

  Future<Database> initializeDatabase() async {
    final String databasesPath = await getDatabasesPath();
    print(databasesPath);
    final String path = join(databasesPath, 'my_lists.db');

    return openDatabase(
      path,
      version: 2, // Incrementar la versión de la base de datos
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE lists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          items TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the new 'items' column to the 'lists' table
          await db.execute('ALTER TABLE lists ADD COLUMN items TEXT');
        }
      },
    );
  }
  Future<void> saveListItems_update(List<String> items, String listName) async {
    final db = await database;
    final String itemsAsString = items.join(',');

    await db.update(
      'lists',
      {'items': itemsAsString},
      where: 'name = ?',
      whereArgs: [listName],
    );
  }

  Future<List<String>> getLists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('lists');

    return List.generate(maps.length, (index) => maps[index]['name'].toString());
  }
  Future<void> deleteList(String listName) async {
    final db = await database;
    await db.delete('lists', where: 'name = ?', whereArgs: [listName]);
  }
}
class SavedListsScreen extends StatefulWidget {
  @override
  _SavedListsScreenState createState() => _SavedListsScreenState();
}


class _SavedListsScreenState extends State<SavedListsScreen> {
  List<String> savedLists = [];

  @override
  void initState() {
    super.initState();
    loadLists();
  }

  void loadLists() async {
    final dbHelper = DatabaseHelper._instance;
    final lists = await dbHelper.getLists();

    setState(() {
      savedLists = lists;
    });
  }


  void deleteList(String name) async {
    final dbHelper = DatabaseHelper._instance;
    await dbHelper.deleteList(
        name); // Call the deleteList method from DatabaseHelper

    setState(() {
      savedLists.remove(
          name); // Remove the deleted list from the savedLists list
    });

    print('Lista "$name" eliminada');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Listas'),
      ),
      backgroundColor: Colors.black,
      body: savedLists.isEmpty
          ? Center(
        child: Text(
          'No se encontraron listas guardadas.',
          style: TextStyle(fontSize: 20.0),
        ),
      )
          : ListView.builder(
        itemCount: savedLists.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              tileColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.volume_up_rounded, size: 40),
                onPressed: () async {},
              ),
              title: Text(
                savedLists[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ListDetailScreen(
                          listName: savedLists[index],
                        ),
                  ),
                );
              },
              trailing: IconButton(
                icon: Icon(Icons.delete, size: 40),
                onPressed: () {
                  // Eliminar la lista
                  deleteList(savedLists[index]);
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 100,
        child: ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Confirmar eliminación',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  content: Text(
                    '¿Estás seguro de que deseas eliminar todas las listas?',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          savedLists.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 20),
            primary: Colors.red,
          ),
          icon: Icon(
            Icons.delete,
            size: 40,
          ),
          label: Text(
            'Eliminar Todas las Listas',
            style: TextStyle(
              fontSize: 23,
            ),
          ),
        ),
      ),
    );
  }
}
class ListDetailScreen extends StatefulWidget {
  final String listName;

  ListDetailScreen({required this.listName});

  @override
  _ListDetailScreenState createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  List<String> itemList = <String>[];
  List<bool> itemSelected = <bool>[];

  @override
  void initState() {
    super.initState();
    getListItems();
  }
  Future<void> addItem(String item) async {
    setState(() {
      itemList.add(item);
      itemSelected.add(false);
    });

    final dbHelper = DatabaseHelper();
    await dbHelper.saveListItems_update(itemList, widget.listName);
  }

  Future<void> getListItems() async {
    final dbHelper = DatabaseHelper._instance;
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'lists',
      columns: ['items'],
      where: 'name = ?',
      whereArgs: [widget.listName],
    );

    if (maps.isNotEmpty) {
      final String itemsAsString = maps.first['items'];
      setState(() {
        itemList = itemsAsString.split(',');
        itemSelected = List<bool>.filled(itemList.length, false);
      });
    }
  }
  void toggleItemSelection(int index) {
    setState(() {
      itemSelected[index] = !itemSelected[index];
    });
  }
  void showAddItemDialog(BuildContext context) {
    String newItem = '';

    Navigator.push(
      context,
      PageRouteBuilder(
        fullscreenDialog: true,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Añadir elemento'),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Introduce el texto:',
                          style: TextStyle(fontSize: 30.0),
                        ),
                        SizedBox(height: 30.0),
                        TextField(
                          style: TextStyle(fontSize: 40.0), // Tamaño del texto aumentado
                          onChanged: (value) {
                            newItem = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          addItem(newItem); // Agregar el nuevo elemento a la lista
                          Navigator.pop(context);
                        },
                        child: Text('Añadir', style: TextStyle(fontSize: 30.0)),
                      ),
                      SizedBox(width: 8.0),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar', style: TextStyle(fontSize: 30.0)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  void deleteListItem(String itemName) {
    setState(() {
      itemList.remove(itemName);
      itemSelected.removeAt(itemList.indexOf(itemName));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showAddItemDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 108),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Añadir Manualmente',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.keyboard,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí puedes implementar la lógica para añadir elementos por voz
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 108),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 9),
                      Text(
                        'Añadir por Voz',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.mic,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(Icons.volume_up_rounded, size: 40),
                      onPressed: () async {
                        // Aquí puedes implementar la lógica para reproducir el elemento
                      },
                    ),
                    title: GestureDetector(
                      onTap: () {
                        toggleItemSelection(index);
                      },
                      child: Text(
                        itemList[index],
                        style: TextStyle(
                          decoration: itemSelected[index]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          fontSize: 30, color: itemSelected[index] ? Colors.red : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, size: 40),
                      onPressed: () {
                        deleteListItem(itemList[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Confirmar eliminación',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          content: Text(
                            '¿Estás seguro de que deseas eliminar la lista?',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  itemList.clear();
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontSize: 23,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 23,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 80),
                    primary: Colors.red,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Eliminar Lista',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.delete,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Guardar lista'),
                          content: TextField(
                            onChanged: (value) {
                              // Aquí puedes actualizar el nombre de la lista si es necesario
                            },
                            decoration: InputDecoration(
                              hintText: 'Nombre de la lista',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Guardar la lista en la base de datos
                                final dbHelper = DatabaseHelper._instance;
                                dbHelper.saveList(itemList, widget.listName);

                                Navigator.pop(context);
                              },
                              child: Text('Guardar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancelar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 80),
                    primary: Colors.blue,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Guardar lista',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.save,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (int i = 0; i < itemSelected.length; i++) {
                        itemSelected[i] = false;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 80),
                    primary: Colors.green,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Restaurar lista',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.remove_red_eye,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
class ImageSlider extends StatefulWidget {
  final List<ImageProvider> imageProviders;

  ImageSlider({required this.imageProviders});

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageProviders.length,
            itemBuilder: (BuildContext context, int index) {
              return Image(image: widget.imageProviders[index]);
            },
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Imagen ${_currentPage + 1} de ${widget.imageProviders.length}',
          style: TextStyle(fontSize: 25),
        ),
      ],
    );
  }
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutorial'),
      ),
      body: ImageSlider(
        imageProviders: [
          AssetImage('assets/tutorial1.PNG'),
          AssetImage('assets/tutorial2.PNG'),
          AssetImage('assets/tutorial3.PNG'),
          AssetImage('assets/tutorial4.PNG'),
          AssetImage('assets/tutorial5.PNG'),
        ],
      ),
    );
  }
}






