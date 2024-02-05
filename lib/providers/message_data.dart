import 'dart:convert';

import 'package:fastgalery/model/message.dart';




class MessageData{
  final List<Message> _messages;
  final int _total_messages;
  final bool _has_next;
  final bool _has_previous;
  final int _page;


  MessageData._(this._messages, this._total_messages, this._has_next,
      this._has_previous, this._page);


  factory MessageData.fromJson(String jsonData){


    List<dynamic> list = json.decode( utf8.decode(jsonData.codeUnits))['messages'];
    Map<String,dynamic> respuesta = json.decode( utf8.decode(jsonData.codeUnits));
    print('repsuet');
    print(respuesta);
    print('\n\n\n');
    List<Message> messageList = list.map((e) => Message.fromMap(e)).toList();

    return MessageData._(messageList,respuesta['total_messages'],respuesta['has_next'],respuesta['has_previous'],respuesta['page']);
  }

  void deleteMessage(int messageId){
    _messages.removeWhere((message) => message.id == messageId);
}

  int get page => _page;

  bool get has_previous => _has_previous;

  bool get has_next => _has_next;

  int get total_messages => _total_messages;

  List<Message> get messages => _messages;


}
