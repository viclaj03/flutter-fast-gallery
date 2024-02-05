import 'dart:convert';

import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/main.dart';
import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:flutter/material.dart';




class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'Settings',gradientColors: <Color>[
        Color(0xff611de1),
        Color(0xffa74bc0),
      ], ),

      body: FutureBuilder(
          future: apiService.getMyUser(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              Map<String,dynamic> userData = jsonDecode(snapshot.data!);
              return _profielOptions(userData['Nsfw']);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }

  Widget _profielOptions(bool nsfw){
    Future<void> deleteAccount(BuildContext context,) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Eliminar Cuenta',style: TextStyle(color: Colors.red),),
            content: Text('Esta acción no se puede deshacer'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  apiService.deleteAccount();
                  removeToken();
                  removeUserData();
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: Text('Si'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context);
                  Navigator.pop(context);
                },
                child: Text('No'),
              ),
            ],
          );
        },
      );
    }

    return
      Padding(
          padding: const EdgeInsets.only(top: 15,left: 15),
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
              Text('Profile Options'.toUpperCase()),
              Row(
                children: <Widget>[
                  Text('Permiter contenido NSFW'),
                  Switch(value: nsfw, onChanged: (bool value) async {
                    bool changeNSFW = await apiService.changeNSFW();
                    setState(() {
                      nsfw = changeNSFW;
                    });
                  }, activeColor: Colors.red,)
                ],
              ),
              TextButton(onPressed: () async{
               deleteAccount(context);
              },
                 child:Text('Delete account',style: TextStyle(color: Colors.red),),
                style: ButtonStyle(),)
            ],
          )
      );
  }
}

