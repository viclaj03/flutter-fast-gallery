
import 'dart:ui';


import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/model/user.dart';
import 'package:fastgalery/providers/post_data.dart';
import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:fastgalery/screens/form_message.dart';
import 'package:fastgalery/screens/form_update_profile.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/screens/registre.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';




ApiService _apiService = ApiService();

int _currentPage = 1;






Future<Map<String, dynamic>> getUserAndIdUser(int id) async {

  final userJson = await _apiService.getUserProfile(id);
  final userId = await getIdUser();
  User _user = User.fromJson(userJson);

  return {'userId': userId, 'user': _user};
}


int calculateCrossAxisCount(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 300) {
    return 1; // Dispositivos muy pequeños, una sola columna
  } else if (screenWidth < 600) {
    return 2; // Dispositivos pequeños, dos columnas
  } else if (screenWidth < 800) {
    return 3; // Dispositivos medianos, tres columnas
  }else if (screenWidth < 1000) {
    return 4; // Dispositivos medianos, tres columnas
  } else {
    return 5; // Dispositivos grandes, cuatro columnas
  }
}


Future<String> getJsonPosts(int user_id,int page) async {

  String posts;

  final actualUserId = await getIdUser();

  if(actualUserId == user_id ){
    posts = await _apiService.getMyPosts(page);
  } else {
    posts = await _apiService.getImageListUser(page,user_id);
  }


  return posts ;
}


class ProfileScreen extends StatefulWidget {

  final int id_user;
  const ProfileScreen({super.key,required this.id_user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(id_user);
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int id_user;
  final ScrollController _scrollController = ScrollController();
  final PostData _postData = PostData.fromJson('[]');
  _ProfileScreenState(this.id_user);


  @override
  void initState() {
    _currentPage = 1;
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadData(id_user);
  }

  @override
  void dispose() {

    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent ) {
      // Llegaste al final de la lista, carga más datos
      _loadData(id_user);
    } else {
      print('object');
    }
  }

  Future<void> _loadData(int id_user) async {
    print('loadData');
    try {
      print('pagina actual -> $_currentPage');
      final jsonData = await getJsonPosts(id_user, _currentPage);
      final newData = PostData.fromJson(jsonData);
      if (newData.getSize() > 0) {
        setState(() {
          PostData.addMoreData(_postData, newData);
          _currentPage++;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya no hay más posts :(',),showCloseIcon: true,
            backgroundColor: Colors.red,duration: Duration(seconds: 2),shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }

  }


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future:  getUserAndIdUser(id_user),
        builder: (BuildContext context,AsyncSnapshot<Map<String, dynamic>> snapshot){
        if(snapshot.hasData){
          final User user = snapshot.data!['user'];
          final int idUser = snapshot.data!['userId'];


          return profileView(user:user, idUser:idUser, scrollController: _scrollController,postData: _postData,);
        }else{
          return const Center(child: CircularProgressIndicator());
        }
    });
  }
}


class profileView extends StatelessWidget {
  User user;
  final int idUser;
  final ScrollController scrollController;
  final PostData postData;

  profileView({super.key, required this.user,required this.scrollController,required this.postData, required this.idUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: Text(user.id == idUser?'My profile':'Profile'),
          gradientColors:
          const <Color>[
            Color(0xff611de1),
            Color(0xffa74bc0),
          ]),

      body:CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: profileBody(user: user,idUser:idUser),
          ),
          ImageList(scrollController: scrollController, postData: postData,userId: user.id,),
        ],
      ),

        floatingActionButton: user.id != idUser ?FloatingActionButton(
          tooltip: 'New Message',
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MessageForm(user: user,)));
          },
          child: const Icon(Icons.email)
      ):null,
    );
  }

}

class profileBody extends StatefulWidget {
  final User user;
  final int idUser;
  const profileBody({super.key, required this.user, required  this.idUser,});

  @override
  State<profileBody> createState() => _profileBodyState(user,idUser);
}

class _profileBodyState extends State<profileBody> {
  User user;
  int idUser;
  _profileBodyState(this.user,this.idUser);

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Icon(Icons.account_circle,size: 120),
          Text('${user.name}',style: TextStyle(fontSize: 30),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //mainAxisSize: MainAxisSize.min,
            children: [
              Spacer(),

              Column(
                children: [
                  Text(user.post_count.toString(),style: const TextStyle(fontSize: 25),),
                  const Text('POSTS')
                ],
              ),

              Spacer(),
              Column(
                children: [
                  Text(user.follower_count.toString(),style: const TextStyle(fontSize: 25),),
                  const Text('SEGUIDORES',style: TextStyle())
                ],
              ),
              Spacer(),// Espacio entre datos
              Column(
                children: [
                  Text(user.like_counts.toString(),style: const TextStyle(fontSize: 25),),
                  const Text('LIKES')
                ],
              ),
              Spacer(),
            ],
          ),
          user.id != idUser?
          ElevatedButton(onPressed: () async{
            user.subscribe = await  _apiService.followUser(user.id);

            if(user.subscribe!){
              user.follower_count = user.follower_count! + 1;
            } else {
              user.follower_count = user.follower_count! - 1 ;
            }
            setState(() {
              //user.subscribe;
            });
          },
            child: user.subscribe! ? Icon(Icons.check): Text('Seguir')
          ):ElevatedButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FormUpdatePorfileScreen(user:user)),
            ).then((value) => {
              if(value is User){
                setState(() {
                  user = value;
            })}
            });
          },
              child:   Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children:const <Widget> [
                  Icon(Icons.edit),
                  Text(" Editar Perfil")
                ],
              )
          ),
        ],
      ),
    );
  }


}


////////////////////////



class ImageList extends StatefulWidget {
  final ScrollController scrollController;

  final PostData postData;
  final userId;

  const ImageList({
    Key? key,
    required this.scrollController,

    required this.postData,
    required this.userId
  }) : super(key: key);

  @override
  _ImageListState createState() => _ImageListState(userId);
}

class _ImageListState extends State<ImageList> {
  final userId;
  _ImageListState(this.userId);

  @override
  Widget build(BuildContext context) {
    return  SliverGrid(

        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: calculateCrossAxisCount(context),
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
    delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
        final post = widget.postData.getPost(index);
        return PostView(post);
        },
      childCount: widget.postData.getSize(),
    ),
    );
  }
  Widget PostView(Post post){
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: !post.NSFW?ImageFiltered(
                      imageFilter: post.NSFW? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0):ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child:Hero(
                          tag:'imageHero${post.id}',
                          child:Image.network(
                            '${_apiService.baseUrl}/static/images_render/${post.image_url_ligere}',
                          ))):
                  ColorFiltered(
                      colorFilter: ColorFilter.mode(Color(0xABD7322F), BlendMode.lighten),
                      child:
                      ImageFiltered(
                          imageFilter: post.NSFW? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0):ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child:Hero(
                              tag:'imageHero${post.id}',
                              child:Image.network(
                                '${_apiService.baseUrl}/static/images_render/${post.image_url_ligere}',)
                          )
                      )
                  ),
                ),
              ),
              Text(post.title),
            ],
          )
        ],
      ),
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostScreen(post)),
        ).then((result) =>
        {
          if(result != null && result is int){
            setState(() {
              widget.postData.deletePostById(result);
            })

          }
        });
      },
    );
  }
}

