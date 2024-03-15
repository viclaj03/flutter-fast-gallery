import 'dart:io';


import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/services/api_services.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



String titulo = '';
String descripcion = '';
bool nsfw = false;
String tags = '';
XFile? _imageFile;




final ApiService _apiService = ApiService();


class FormScreen extends StatelessWidget  {
  const FormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(

      appBar: GradientAppBar(
        title:  Text("New Post"),
          gradientColors:
          const <Color>[
            Color(0xff611de1),
            Color(0xffa74bc0),
          ]
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
    XFile? selected = await ImagePicker().pickImage(source: ImageSource.gallery,);

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

      child: Padding(
        padding: const EdgeInsets.all(20.0),
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

      Container(
        margin: EdgeInsets.only(bottom: 16.0),
          child:
          TextFormField(
            initialValue: '',
            decoration:  InputDecoration(

              hintText: 'Un titulo breve pero descriptivo',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                )

            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El Titulo es obligatorio';
              }
              if (value.length < 5 || value.length >= 100 ) {
                return 'debe contener menos de 100 caracteres y mas de 5,\n Actual: ${value.length} ';
              }
              titulo = value;
              return null;
            },
          )
      ),
          const Text(
            "Description:",
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            decoration:  InputDecoration(
              hintText: 'Breve descripcion del contenido del post',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                )

            ),
            maxLines: 4,
            initialValue: '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El contenido es obligatorio';
              }

              if (value.length >= 500) {
                return 'debes contener menos de 500 characters ${value.length}';
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

          const Text(
            "Tags:",
            style: TextStyle(fontSize: 18),
          ),
          TextFormField(
            decoration:  InputDecoration(
              hintText: 'tags descriptivos separados por comas',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)
                )
            ),
            maxLines: 1,
            initialValue: '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El contenido es obligatorio';
              }

              if (value.length >= 500) {
                return 'debes contener menos de 500 characters ${value.length}';
              }
              //todo limitar el enumero de linea
              int newlines = value.split('\n').length - 1;
              if (newlines > 1) {
                return 'maximo 2 saltos de lineas';
              }
              tags = value;
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
                      'tags':tags
                    };

                    if (_imageFile != null) {
                      // Utilizar http.MultipartFile.fromPath para manejar el archivo

                      setState(() {
                        _isSaving = false;
                      });
                      try{
                        Map<String, dynamic> response = await _apiService.postImage(requestBody,_imageFile!);
                        print(response);
                        if(!response.isEmpty) {
                          //Navigator.push(context, MaterialPageRoute(
                          //    builder: (context) => ListImagesScreen()));
                          _formKey.currentState!.reset();
                          _imageFile = null;
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Imagen subida ${response['title']}'), backgroundColor: Colors.green));

                          Navigator.pop(context);

                        }
                      } catch (error) {

                        // Muestra un mensaje de error si la autenticación falla
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al subir el post:$error'), backgroundColor: Colors.red),
                        );
                      }
                    } else{

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
      )
    );
  }
}


