import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id; //해당 도큐먼트의 ID를 담기위함
  final String mb_id; // 글쓴이 아이디
  final String mb_nick; // 글쓴이 닉네임
  final String mb_img; // 글쓴이 프로필 이미지
  final String state; // 신고 및 삭제 상태 1:신고, 2:삭제
  final String content; // 내용
  final Timestamp sendDate; // 보낸 날짜

  MessageModel({
    this.id = '',
    this.mb_id = '',
    this.mb_nick = '',
    this.mb_img = '',
    this.state = '',
    this.content = '',
    Timestamp? sendDate,
  }):sendDate = sendDate??Timestamp(0, 0);

  //서버로부터 map형태의 자료를 MessageModel형태의 자료로 변환해주는 역할을 수행함.
  factory MessageModel.fromMap({required String id,required Map<String,dynamic> map}){
    return MessageModel(
        id: id,
        mb_id: map['mb_id']??'',
        mb_nick: map['mb_nick']??'',
        mb_img: map['mb_img']??'',
        state: map['state']??'',
        content: map['content']??'',
        sendDate: map['sendDate']??Timestamp(0, 0)
    );
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> data = {};
    data['mb_id']=mb_id;
    data['mb_nick']=mb_nick;
    data['mb_img']=mb_img;
    data['state']=state;
    data['content']=content;
    data['sendDate']=sendDate;
    return data;
  }

}