
import 'dart:ui';


import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/model/user.dart';
import 'package:fastgalery/providers/post_data.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/screens/registre.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';




ApiService apiService = ApiService();

int _currentPage = 1;





int calculateCrossAxisCount(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 400) {
    return 1; // Dispositivos muy pequeños, una sola columna
  } else if (screenWidth < 600) {
    return 2; // Dispositivos pequeños, dos columnas
  } else if (screenWidth < 800) {
    return 3; // Dispositivos medianos, tres columnas
  } else {
    return 4; // Dispositivos grandes, cuatro columnas
  }
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
    _currentPage =1;
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadData(id_user);

    print('gg $_currentPage');

  }

  @override
  void dispose() {

    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent ) {
      // Llegaste al final de la lista, carga más datos
      print('Scrollll');
      _loadData(id_user);
    } else {
      print('object');
    }
  }

  Future<void> _loadData(int id_user) async {
    //_currentPage = 1;
    print('loadData');
    try {
      print('pagina actual -> $_currentPage');
      final jsonData = await apiService.getImageListUser(_currentPage,id_user);
      final newData = PostData.fromJson(jsonData);
      if (newData.getSize() > 0) {
        setState(() {
          PostData.addMoreData(_postData, newData);
          _currentPage++;
        });
      } else {
        print('sin posts fff');
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
      future:  apiService.getUserProfile(id_user),
        builder: (BuildContext context,AsyncSnapshot<String> snapshot){
        if(snapshot.hasData){
          User user = User.fromJson(snapshot.data!);

          return profileView(user:user,scrollController: _scrollController,postData: _postData,);
        }else{
          return const Center(child: CircularProgressIndicator());
        }
    });
  }
}




class profileView extends StatelessWidget {
  User user;
  final ScrollController scrollController;
  final PostData postData;

  profileView({super.key, required this.user,required this.scrollController,required this.postData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text('Profile'),
        actions: [
          IconButton(onPressed: (){

          }, icon: const Icon(Icons.edit))
        ],
      ),
      body:CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: profileBody(user: user),
          ),
          ImageList(scrollController: scrollController, postData: postData),
        ],
      ),


      /*ListView(
        children: [
          profileBody(user: user,),
          ImageList(scrollController: scrollController,  postData: postData)
        ],
      )*/

    );
  }




}

class profileBody extends StatefulWidget {
  final User user;

  const profileBody({super.key, required this.user,});

  @override
  State<profileBody> createState() => _profileBodyState(user);
}

class _profileBodyState extends State<profileBody> {
  User user;
  _profileBodyState(this.user);

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
          ElevatedButton(onPressed: () async{
            user.subscribe = await  apiService.followUser(user.id);

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

  const ImageList({
    Key? key,
    required this.scrollController,

    required this.postData,
  }) : super(key: key);

  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  @override
  Widget build(BuildContext context) {
    return  SliverGrid(

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
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
                            '${apiService.baseUrl}/static/images_render/${post.image_url_ligere}',
                          ))):
                  ColorFiltered(
                      colorFilter: ColorFilter.mode(Color(0xABD7322F), BlendMode.lighten),
                      child:
                      ImageFiltered(
                          imageFilter: post.NSFW? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0):ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child:Hero(
                              tag:'imageHero${post.id}',
                              child:Image.network(
                                '${apiService.baseUrl}/static/images_render/${post.image_url_ligere}',)
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
        );
      },
    );
  }
}

