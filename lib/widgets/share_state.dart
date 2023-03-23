// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class ShareState extends StatelessWidget {
  final String ca_name;
  final String wr_6;
  final String wr_7;

  const ShareState({
    Key? key,
    required this.ca_name,
    required this.wr_6,
    required this.wr_7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ca_name == '1') {
      if (wr_6 != '') {
        if (wr_7 != '') {
          return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF007bff),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4.0),
                            // bottomRight: Radius.circular(4.0)
                            )),
                    child: Center(child: Text(
                        "방문완료",
                        style: TextStyle(color: Colors.white, fontSize: 12))),
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFa586bc),
                        borderRadius: BorderRadius.only(
                            // bottomLeft: Radius.circular(4.0),
                            bottomRight: Radius.circular(4.0))),
                    child: Center(child: Text(
                        "접수완료",
                        style: TextStyle(color: Colors.white, fontSize: 12))),
                  ),
                )
              ]
          );
        }
        else {
          return Container(
            decoration: BoxDecoration(
                color: const Color(0xFFa586bc),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4.0),
                    bottomRight: Radius.circular(4.0))),
            child: Center(child: Text(
                "접수완료", style: TextStyle(color: Colors.white, fontSize: 12))),
          );
        }
      }
      else {
        return Container(
          decoration: BoxDecoration(
              color: const Color(0xFF138496),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.0),
                  bottomRight: Radius.circular(4.0))),
          child: Center(child: Text(
              "접수대기", style: TextStyle(color: Colors.white, fontSize: 12))),
        );
      }
    }
    else if(ca_name == '2') {

      if (wr_6 != '') {
        if (wr_7 != '') {
          return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFF007bff),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4.0),
                            // bottomRight: Radius.circular(4.0)
                          )),
                      child: Center(child: Text(
                          "방문완료",
                          style: TextStyle(color: Colors.white, fontSize: 12))),
                    )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFa586bc),
                        borderRadius: BorderRadius.only(
                          // bottomLeft: Radius.circular(4.0),
                            bottomRight: Radius.circular(4.0))),
                    child: Center(child: Text(
                        "접수완료",
                        style: TextStyle(color: Colors.white, fontSize: 12))),
                  ),
                )
              ]
          );
        }
        else {
          return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF007bff),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4.0),
                            // bottomRight: Radius.circular(4.0)
                        )),
                    child: Center(child: Text(
                        "방문완료",
                        style: TextStyle(color: Colors.white, fontSize: 12))),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF138496),
                        borderRadius: BorderRadius.only(
                            // bottomLeft: Radius.circular(4.0),
                            bottomRight: Radius.circular(4.0))),
                    child: Center(child: Text(
                        "처리대기",
                        style: TextStyle(color: Colors.white, fontSize: 12))),
                  ),
                ),
              ]
          );
        }

      }
      else
      {
        if (wr_7 != '') {
          return Container(
            decoration: BoxDecoration(
                color: const Color(0xFFa586bc),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4.0),
                    bottomRight: Radius.circular(4.0))),
            child: Center(child: Text(
                "처리완료", style: TextStyle(color: Colors.white, fontSize: 12))),
          );
        }
        else
        {
          return Container(
            decoration: BoxDecoration(
                color: const Color(0xFF138496),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4.0),
                    bottomRight: Radius.circular(4.0))),
            child: Center(child: Text(
                "접수대기", style: TextStyle(color: Colors.white, fontSize: 12))),
          );

        }

      }

    }
    else
    {
      return Container();
    }

  }

}