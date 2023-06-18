import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:neumorphic_ui/neumorphic_ui.dart';

class GeneratePage extends StatefulWidget {
  const GeneratePage({Key? key}) : super(key: key);

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  final TextEditingController _sessionIdFieldController =
      TextEditingController();
  String _sessionId = "";

  var databaseFactory = databaseFactoryFfi;
  late Database _database;

  @override
  void initState() {
    super.initState();
    sqfliteFfiInit();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final path = ('${Directory.current.path}/input.db');
    _database = await databaseFactory.openDatabase(path);
    _database.execute("""CREATE TABLE IF NOT EXISTS metadata
                (key TEXT PRIMARY KEY NOT NULL,
                value TEXT NOT NULL)""");
    _setSessionIdValue();
  }

  Future<void> _setSessionIdValue() async {
    var val = await _database.query("metadata", where: "key = 'session_name'");
    _sessionId = (val.isEmpty ? "Undefined" : val[0]["value"]).toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.circular(16),
            ),
            color: Colors.blue.shade300.withAlpha(50),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _sessionIdFieldController,
                          decoration: InputDecoration(
                            labelText: 'Session : $_sessionId',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: NeumorphicButton(
                        onPressed: () {
                          var input = _sessionIdFieldController.text.trim();
                          if (RegExp(r'\d\d-\d\d-\d\d\d\d [AF]N')
                              .hasMatch(input)) {
                            _sessionId = input;
                          } else {
                            final snackBar = SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              content: AwesomeSnackbarContent(
                                title: 'Invalid Session ID',
                                message:
                                    'Please Recheck the Session ID entered if of proper format and try again.',
                                contentType: ContentType.failure,
                              ),
                            );

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(snackBar);
                          }

                          _database.execute(
                            "INSERT OR REPLACE INTO metadata (key, value) VALUES ('session_name', '$_sessionId')",
                          );
                          _sessionIdFieldController.clear();
                          setState(() {});
                        },
                        style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(Icons.settings),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NeumorphicButton(
                      onPressed: () async {
                        var content_type = ContentType.failure;
                        var title = "PDF Generation Failed";
                        var msg = "PDF Generation Failed";

                        try {
                          final result = await Process.run(
                            '${Directory.current.path}\\allocator.exe',
                            [],
                          );

                          if (result.exitCode == 0) {
                            final result2 = await Process.run(
                              '${Directory.current.path}\\pdf_generator.exe',
                              [],
                            );

                            if (result2.exitCode == 0) {
                              content_type = ContentType.success;
                              title = "PDF Generated";
                              msg =
                                  "PDF Generated, please check the output folder.";
                            } else {
                              // pdf generation failed
                            }
                          } else {
                            // Executable failed
                          }
                        } catch (e) {
                          // Handle any exceptions here
                        }

                        final snackBar = SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: title,
                            message: msg,
                            contentType: content_type,
                          ),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(snackBar);
                      },
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Generate"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NeumorphicButton(
                      onPressed: () {
                        final Uri fileLocation = Uri.parse(
                            "file:" '${Directory.current.path}/../output/');
                        launchUrl(fileLocation);
                      },
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.folder_open),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
