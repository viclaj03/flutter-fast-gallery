import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/model/message.dart';
import 'package:fastgalery/screens/profile.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


ApiService apiService = ApiService();



class ShowMessageScreen extends StatelessWidget {
  const ShowMessageScreen( {super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:  apiService.getMessage(id),
        builder: (BuildContext context,AsyncSnapshot<String> snapshot){
          if(snapshot.hasData){
            Message message = Message.fromJsonString(snapshot.data!);

            return _message(message,context);
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _message(Message message, BuildContext context,){
    return
      Scaffold(
        appBar: GradientAppBar(title: message.title,gradientColors: [
          Color(0xff611de1),
          Color(0xffa74bc0),
        ]),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  <Widget>[
                  TextButton( child: Text('Sender: ${message.user_sender.name}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35)),onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(id_user: message.user_sender.id)));
                  }),
                  Text('${DateFormat('dd-MM-yy HH:mm').format(message.created_at)}'),
                ],
              ),
              SizedBox(height: 15),
              Padding(padding: EdgeInsets.all(10),

                  child:
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(message.content),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black), // Borde negro
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.yellow, // Fondo amarillo
                    ),
                    width: double.infinity,
                  ) ,
              ),

            ],
          ),

      );
  }
}
