import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_translation_example/firebase_options.dart';
import 'package:flutter/material.dart';

Future main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Firebase Translation Example',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyHomePage(title: 'Firebase Translation Example'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Center(child: Text("Enter text to be translated")),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                    controller: _controller,
                    onChanged: (val) {
                      _controller.value = _controller.value.copyWith(
                        text: val,
                        selection: TextSelection.collapsed(offset: val.length),
                      );
                    })),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _writeToCloudFirestore,
                child: const Text("Translate!")),
            const SizedBox(height: 20),
            const Center(child: Text("Translations")),
            const SizedBox(height: 20),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("translations")
                    .doc("pLwlji6aSwJ7Xudj9rGD") // <-- replace with your doc id
                    .snapshots(),
                builder: (context, snapshot) {
                  var translated = snapshot.data == null
                      ? Translated(de: "", en: "", es: "", fr: "")
                      : Translated.fromJson(
                          snapshot.data!.data()!["translated"]);

                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(translated.en),
                        Text(translated.es),
                        Text(translated.de),
                        Text(translated.fr)
                      ]);
                }),
          ],
        )));
  }

  Future _writeToCloudFirestore() async {
    FirebaseFirestore.instance
        .collection("translations")
        .doc("pLwlji6aSwJ7Xudj9rGD") // <-- replace with your doc id
        .update({"input": _controller.text});
  }
}

class Translated {
  Translated({
    required this.de,
    required this.en,
    required this.es,
    required this.fr,
  });

  final String de;
  final String en;
  final String es;
  final String fr;

  factory Translated.fromJson(Map<String, dynamic> json) {
    return Translated(
      de: json["de"],
      en: json["en"],
      es: json["es"],
      fr: json["fr"],
    );
  }
}
