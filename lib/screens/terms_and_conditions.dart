import 'dart:convert';
import 'package:flutter/material.dart';



class TermsAndConditiosnScreen extends StatelessWidget {
  const TermsAndConditiosnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:AppBar(
        title: Text('Terminos y condiciones'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ) ,
      body: _terms(),
    );
  }
}


Widget _terms(){
  return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('1º No subir contenido inapropiado',style:  TextStyle(fontSize: 16) ,),
            SizedBox(height: 10),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec at diam id manunc. Curabitur dapibus semper quam et venenatis. Praesent ac convallis leo. Phasellus vehicula tortor non ex placerat imperdiet. Maecenas vel leo vel neque aliquet mattis. Nunc scelerisque in tellus eu dapibus. Integer tempus, metus id varius laoreet, massa massa pulvinar quam, a luctus elit nisl eu ex. Nulla ut accumsan eros. Morbi pulvinar facilisis maximus.\n\n"
                  "Aenean pharetra enim l scelerisque, e curs ac ante ipsum primis in faucibus.",
              style: TextStyle(fontSize: 10),
            ),
            Divider(
              height: 20, // Altura de la línea
              thickness: 2, // Grosor de la línea
              color: Colors.black, // Color de la línea
            ),
            SizedBox(height: 10),
            Text('2º No ',style:  TextStyle(fontSize: 16) ,),
            SizedBox(height: 10),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec at diam id manunc. Curabitur dapibus semper quam et venenatis. Praesent ac convallis leo. Phasellus vehicula tortor non ex placerat imperdiet. Maecenas vel leo vel neque aliquet mattis. Nunc scelerisque in tellus eu dapibus. Integer tempus, metus id varius laoreet, massa massa pulvinar quam, a luctus elit nisl eu ex. Nulla ut accumsan eros. Morbi pulvinar facilisis maximus.\n\n"
                  "Aenean pharetra enim l scelerisque, e curs ac ante ipsum primis in faucibus.",
              style: TextStyle(fontSize: 10),
            ),
            Divider(
              height: 20, // Altura de la línea
              thickness: 2, // Grosor de la línea
              color: Colors.black, // Color de la línea
            ),
            SizedBox(height: 10),
            Text('3º Mensajes',style:  TextStyle(fontSize: 16) ,),
            SizedBox(height: 10),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec at diam id manunc. Curabitur dapibus semper quam et venenatis. Praesent ac convallis leo. Phasellus vehicula tortor non ex placerat imperdiet. Maecenas vel leo vel neque aliquet mattis. Nunc scelerisque in tellus eu dapibus. Integer tempus, metus id varius laoreet, massa massa pulvinar quam, a luctus elit nisl eu ex. Nulla ut accumsan eros. Morbi pulvinar facilisis maximus.\n\n"
                  "Aenean pharetra enim l scelerisque, e curs ac ante ipsum primis in faucibus.",
              style: TextStyle(fontSize: 10),
            ),
            Divider(
              height: 20, // Altura de la línea
              thickness: 2, // Grosor de la línea
              color: Colors.black, // Color de la línea
            ),
            SizedBox(height: 10),
            Text('4º Ser buena Gente UwU',style:  TextStyle(fontSize: 16) ,),
            SizedBox(height: 10),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec at diam id manunc. Curabitur dapibus semper quam et venenatis. Praesent ac convallis leo. Phasellus vehicula tortor non ex placerat imperdiet. Maecenas vel leo vel neque aliquet mattis. Nunc scelerisque in tellus eu dapibus. Integer tempus, metus id varius laoreet, massa massa pulvinar quam, a luctus elit nisl eu ex. Nulla ut accumsan eros. Morbi pulvinar facilisis maximus.\n\n"
                  "Aenean pharetra enim l scelerisque, e curs ac ante ipsum primis in faucibus.",
              style: TextStyle(fontSize: 10),
            ),
            Divider(
              height: 20, // Altura de la línea
              thickness: 2, // Grosor de la línea
              color: Colors.black, // Color de la línea
            ),
            SizedBox(height: 10),
            Text('5º Ser Antisionistas',style:  TextStyle(fontSize: 16) ,),
            SizedBox(height: 10),
            Text("Aprovecho para condenar de nuevo, desde el fondo de mi alma y de mis vísceras al estado de Israel, maldito seas estado de Israel ",
              style: TextStyle(fontSize: 10),
            ),
          ]
      )
      )
  );
}
