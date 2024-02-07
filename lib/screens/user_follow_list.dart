

import 'dart:ui';



import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/model/user.dart';
import 'package:fastgalery/providers/user_data.dart';

import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/screens/profile.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

ApiService apiService = ApiService();



int _currentPage = 1;







class ListUserFollowScreen extends StatefulWidget {

  ListUserFollowScreen({super.key});

  @override
  _ListUserFollowScreenState createState() => _ListUserFollowScreenState();


}

class _ListUserFollowScreenState extends State<ListUserFollowScreen> {
  final ScrollController _scrollController = ScrollController();
  final UserData _userData = UserData.fromJson('[]');


  _ListUserFollowScreenState();

  // Página inicial

  @override
  void initState() {
    super.initState();
    _refresh();
    _scrollController.addListener(_scrollListener);
    //_currentPage = 1;
    //_searchController.addListener(_onSearchChanged);
  }


  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }


  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent ) {
      // Llegaste al final de la lista, carga más datos

      _loadData();
    }
  }

  Future<void> _loadData() async {

    try {
      print('pagina actual -> $_currentPage');
      final jsonData = await apiService.getUserFollowList(_currentPage);
      final newData = UserData.fromJson(jsonData);
      if (newData.getSize() > 0) {
        setState(() {
          UserData.addMoreData(_userData, newData);
          _currentPage++;
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }

  }

  Future<void> _refresh() async {
    // Lógica de actualización al hacer "pull-to-refresh"
    _currentPage = 1;
    _userData.Clear(); // Asegúrate de limpiar la lista actual
    await _loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: const Text("Siguiendo"),
          gradientColors: const [
            Color(0xff611de1),
            Color(0xffa74bc0),
          ]),
      body:   imageList(),
      backgroundColor: Colors.white,
    );
  }


  Widget imageList(){
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: _userData.getSize(),
        itemBuilder: (context, index) {
          final user = _userData.getPost(index);
          return  _listItem(context,user);
        },
      ),
    );
  }

  _listItem(BuildContext context,User user){

    return Padding(
      key: ObjectKey(user),
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: Colors.blue.shade50,
       // textColor: Colors.purple,
        onTap: () => {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(id_user: user.id)))
        },


        title: Text('${user.name}',overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: 25,),),
        subtitle: Text('se unio el ${DateFormat('dd-MM-yy').format(user.created_at)}',style: TextStyle(fontSize: 20,),),
        leading: Icon(Icons.account_circle,size: 50,),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}





