import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastGallery Downloader',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String imageUrl = 'http://192.168.1.148:8000/static/images/__trailblazer_stelle_asta_and_peppy_honkai_and_1_more_drawn_by_yajuu__c5057bd6a8e3ef999bc10df1e7c63afd.jpg'; // Reemplaza con la URL de la imagen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FastGallery Downloader'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            downloadImage();
          },
          child: Text('Descargar Imagen d'),
        ),
      ),
    );
  }

  Future<void> downloadImage() async {
    final response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    final directory = await getExternalStorageDirectory();
    final galleryDirectory = Directory('${directory!.path}/fastGallery');

    if (!galleryDirectory.existsSync()) {
      galleryDirectory.createSync();
    }

    final file = File('${galleryDirectory.path}/downloaded_image.jpg');
    file.writeAsBytesSync(Uint8List.fromList(bytes));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Descarga Completa'),
          content: Text('La imagen se ha descargado en la carpeta fastGallery.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
