// ignore_for_file: file_names

import 'dart:typed_data';

class DataUtility{
  bool isFailed;
  String errorStack;

  DataUtility({this.isFailed = false, this.errorStack = ''});

  void hasError(){ isFailed = true; }

  void setError(String text){ errorStack = text; }

  Uint8List getImageFromByteData(ByteData data){
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
}
