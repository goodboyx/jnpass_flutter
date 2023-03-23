import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../models/notiEvent.dart';

class CustomFormField extends StatelessWidget {
  CustomFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.isAutoFocus,
    required this.isPassword,
    required this.isReadonly,
    required this.isEnable,
    required this.isRequired,
    required this.textAlign,
    required this.keyBoardType,
    required this.textInputAction,
    this.errorText,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.id,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final bool isAutoFocus;
  final bool isPassword;
  final bool isReadonly;
  final bool isRequired;
  final TextAlign textAlign;
  final bool isEnable;
  final TextInputType? keyBoardType;
  final TextInputAction? textInputAction;
  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? id;

  final NotiEvent notiEvent = NotiEvent();

  @override
  Widget build(BuildContext context) {
    var kColor  = const Color(0xFFDDDDDD);
    if(isRequired)
    {
      kColor  = const Color(0xFFF03738);
    }

    return Container(
        margin: const EdgeInsets.only(left: 15.0, bottom: 5.0, top: 10.0, right: 15.0),
        // height: 35.0,
        // alignment: Alignment.center,
        child: TextFormField(
          textAlign: textAlign,
          autofocus: isAutoFocus,
          obscureText: isPassword,
          enabled:isEnable,
          readOnly: isReadonly,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Nanum Gothic',
              fontSize: 13.0,
              color: kPrimaryColor
          ),
          keyboardType:keyBoardType,
          textInputAction: textInputAction,
          onFieldSubmitted: (term){

            if(textInputAction == TextInputAction.next)
            {
              FocusScope.of(context).nextFocus();
            }
          },
          onChanged: onChanged,
          validator: (val) {
            //이메일 형식 체크
            validator;
          },
          inputFormatters: inputFormatters,
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            hintText: hintText,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.0),
            ),
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: (isPassword) ? IconButton(
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.grey,
              ),
              onPressed: () {
                notiEvent.notify(id.toString());
                // Update the state i.e. toogle the state of passwordVisible variable
              },
            ) : null,
            errorText: errorText,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.0),
            ),
          ),
          // focusNode: focusNode,
        ),
    );
  }
}