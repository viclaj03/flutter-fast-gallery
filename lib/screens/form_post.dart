import 'dart:io';

import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:fastgalery/screens/post_show.dart';
//import 'package:fastgalery/screens/posts_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


String titulo = '';
String descripcion = '';
bool nsfw = false;
XFile? _imageFile;

class FormScreen extends StatelessWidget {
  const FormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("New Post $titulo"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.black,
      ),
      body: const SingleChildScrollView(
        child: formulario(),
      ),
    );
  }
}

class formulario extends StatefulWidget {
  const formulario({Key? key}) : super(key: key);

  @override
  State<formulario> createState() => _formularioState();
}

class _formularioState extends State<formulario> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    XFile? selected = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (selected != null) {
      setState(() {
        _imageFile = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isSaving = false;
    return Form(
      key: _formKey,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                iconSize: 280,
                onPressed: _pickImage,
                icon: _imageFile != null
                    ? Image.file(
                  File(_imageFile!.path),
                  height: 280.0,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/image/not_image.jpg',
                  height: 280.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
          ),
          const Text(
            "Title:",
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            initialValue: '',
            decoration: const InputDecoration.collapsed(
              hintText: 'Un titulo breve pero descriptivo',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El Titulo es obligatorio';
              }
              if (value.length >= 250) {
                return 'debes contener menos de 250 cracteres';
              }
              titulo = value;
              return null;
            },
          ),
          const Text(
            "Description:",
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Breve descripcion del contenido del post',
            ),
            maxLines: 4,
            initialValue: '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El contenido es obligatorio';
              }

              if (value.length >= 250) {
                return 'debes contener menos de 250 cracteres';
              }
              //todo limitar el enumero de linea
              int newlines = value.split('\n').length - 1;
              if (newlines > 2) {
                return 'maximo 2 saltos de lineas';
              }
              descripcion = value;
              return null;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "NSFW:",
                style: TextStyle(fontSize: 18),
              ),
              Checkbox(
                activeColor: Colors.red,
                checkColor: Colors.black,
                value: nsfw,
                onChanged: (bool? value) {
                  setState(() {
                    nsfw = value!;
                  });
                },
              ),

            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,

            children: <Widget>[
              ElevatedButton(
                child: const Text('Clear Form'),
                onPressed: () {
                  nsfw = false;
                  _formKey.currentState!.reset();
                  _imageFile = null;

                  setState(() {
                    _imageFile = null;
                  });
                },
              ),
              ElevatedButton(
                child: const Text('SAVE'),
                onPressed: _isSaving?null :  () async {
                  if (_formKey.currentState!.validate()) {

                    setState(() {
                      _isSaving = true;
                    });
                    Map<String, dynamic> requestBody = {
                      'title': titulo,
                      'description': descripcion,
                      'NSFW': nsfw,
                    };

                    if (_imageFile != null) {
                      // Utilizar http.MultipartFile.fromPath para manejar el archivo
                      print('hOlaaaaaaaaaaaa');
                      setState(() {
                        _isSaving = false;
                      });
                      try{
                        Map<String, dynamic> response = await apiService.postImage(requestBody,_imageFile!);
                        print(response);
                        if(!response.isEmpty) {
                          //Navigator.push(context, MaterialPageRoute(
                          //    builder: (context) => ListImagesScreen()));
                          _formKey.currentState!.reset();
                          _imageFile = null;
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Imagen subida ${response['title']}'), backgroundColor: Colors.green));

                          Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen(Post.fromMap(response))));

                        }
                      } catch (error) {
                        print(error);
                        // Muestra un mensaje de error si la autenticación falla
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error al subir el post'), backgroundColor: Colors.red),
                        );
                      }
                    } else{
                      print('falata imagen');
                      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Falta la imagen'), backgroundColor: Colors.red,showCloseIcon: true,duration: Duration(seconds: 2),));
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
