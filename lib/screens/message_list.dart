import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/model/message.dart';
import 'package:fastgalery/providers/message_data.dart';
import 'package:fastgalery/screens/form_message.dart';
import 'package:fastgalery/screens/message_show.dart';

import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


ApiService apiService = ApiService();

int _currentTabIndex = 0;

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  @override
  Widget build(BuildContext context) {
    return
      DefaultTabController(length: 2, initialIndex: 1,child:

      Scaffold(
        appBar: GradientAppBar(
          title: 'Message',
          gradientColors: [
            Color(0xff611de1),
            Color(0xffa74bc0),
          ],
          bottom: TabBar(
            onTap: (index) {
              // Cambia el índice de la pestaña cuando se selecciona una nueva pestaña
              setState(() {

              });
            },
            tabs: const [
              Tab(
                text: "enviados",
              ),
              Tab(
                text: "recibidos",
              )
            ],
          ),
        ),
        body:
        TabBarView(
          children: [
            _senderMessage(),
            _inbox()
          ],
        )
        ,
        floatingActionButton: FloatingActionButton(
            tooltip: 'New Message',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MessageForm()));
            },
            child: const Icon(Icons.email)
        ),
      ),
      );


  }
  Widget _inbox(){
    return FutureBuilder(
        future:  apiService.getMessageList(1),
        builder: (BuildContext context,AsyncSnapshot<String> snapshot){
          if(snapshot.hasData){
            MessageData messageData = MessageData.fromJson(snapshot.data!);
            return ListMessages(messageData:  messageData,isInbox: true);
          }else{
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}


Widget _senderMessage(){
  return FutureBuilder(
      future:  apiService.getSenderMessageList(1),
      builder: (BuildContext context,AsyncSnapshot<String> snapshot){
        if(snapshot.hasData){
          MessageData messageData = MessageData.fromJson(snapshot.data!);
          return ListMessages(messageData:  messageData,isInbox: false);
        }else{
          return const Center(child: CircularProgressIndicator());
        }
      });
}






class ListMessages extends StatefulWidget {
  final MessageData messageData;
  final bool isInbox;
  const ListMessages(  { required this.messageData,required this.isInbox,super.key});
  @override
  State<ListMessages> createState() => _ListMessagesState(messageData,isInbox);
}

class _ListMessagesState extends State<ListMessages> {
  _ListMessagesState(this._messageData,this.isInbox);
  MessageData _messageData;
  final bool isInbox;

  @override
  Widget build(BuildContext context) {

    return
      Column(
        children: <Widget>[
          Expanded(child:
          ListView.builder(
              itemCount: _messageData.messages.length,
              itemBuilder: (context,index)=>
                  _listItem(context, _messageData.messages[index]))
          ),
          DecoratedBox(decoration: BoxDecoration(
            color: Colors.grey
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _messageData.has_previous? () async{
                  String _messages;

                  if(isInbox)
                    _messages = await apiService.getMessageList(_messageData.page - 1);
                  else
                    _messages = await apiService.getSenderMessageList(_messageData.page - 1);

                  setState(()  {
                    _messageData = MessageData.fromJson(_messages);
                  });
                }:null,
              ),
              Text(
                'Página ${_messageData.page}',
                style: TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed:_messageData.has_next?  () async{
                  String _messages;

                  if(isInbox)
                    _messages = await apiService.getMessageList(_messageData.page + 1);
                  else
                    _messages = await apiService.getSenderMessageList(_messageData.page + 1);

                  setState(()  {
                    _messageData = MessageData.fromJson(_messages);
                  });
                }:null,
              ),
            ],
          ),

            ),

        ],
      );


  }


  _listItem(BuildContext context,Message message){

    return Padding(
      key: ObjectKey(message),
      padding: const EdgeInsets.all(10.0),
      child: ListTile(
        tileColor: message.reed ?Colors.yellow.shade400:Colors.blue.shade200,
        onTap: () => Navigator.of(context).push(
          // context,
          // todo Ejercicio5 usamos el widget hero para dar aniumacion a la navegacion
            MaterialPageRoute(builder: (context)=>
                ShowMessageScreen(id: message.id,isReciber:  isInbox))).then((value) => {
                  if(value !=  null && value is Message){
                    setState(() {
                      print('eliminar');
                        _messageData.deleteMessage(message.id);
                    })
                  } else {
                    setState(() {
                      if(isInbox)
                        message.reed = true;
                    })
                  }

          
        }),

        trailing:  Icon(message.reed ?Icons.mark_email_read:Icons.mark_email_unread,color:message.reed ?Colors.grey:Colors.yellow),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${message.title}'),
            Text('${DateFormat('dd-MM-yy HH:mm').format(message.created_at)}'),
          ],
        ),
        subtitle: Text(isInbox ?'sender: ${message.user_sender.name}':'to: ${message.user_reciber.name}'),
        leading: Icon(Icons.account_circle),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

