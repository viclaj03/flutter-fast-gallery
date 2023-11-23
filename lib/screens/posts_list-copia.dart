import 'package:fastgalery/providers/post_data.dart';
import 'package:fastgalery/screens/form_post.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final ApiService apiService = ApiService();


class ListImagesScreen extends StatelessWidget {
  const ListImagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('FastGallery'),
        actions:<Widget> [
          IconButton(
            icon: Icon( Icons.person),
            color: Colors.white,
            onPressed:(){print('object');},
          ),
        ],
      ),
      body: FutureBuilder(
        future: apiService.getImageList(1),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            // final List<Map<String, dynamic>> imageList = snapshot.data!;
            return Galery(postData: PostData.fromJson(snapshot.data!));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: 'Increment Counter',
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FormScreen()));
          }),

    );
  }
}



class Galery extends StatefulWidget {
  const Galery({super.key,  required this.postData});
  final PostData postData;
  @override
  State<Galery> createState() => _GaleryState(postData);
}

class _GaleryState extends State<Galery> {
  _GaleryState( this._postData);
  final PostData _postData;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
      itemBuilder: (context,index){
        return InkWell(
          child:Image.network('${apiService.baseUrl}/static/images/${_postData.getPost(index).image_url}'),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen(_postData.getPost(index))));
          },
        );
      },
      itemCount:_postData.getSize(),
    );
  }
}