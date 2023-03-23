
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool hasNavigation;
  final bool hasSwitch;
  final bool hasText;
  final String value;

  const ProfileListItem({
    Key? key,
    required this.icon,
    required this.text,
    required this.hasNavigation,
    required this.hasSwitch,
    required this.hasText,
    required this.value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isChecked = false;

    return Container(
      height: 50,
      margin: EdgeInsets.only(top:0, bottom: 0, left: 10, right: 10),
      // padding: EdgeInsets.only(top:10, bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(kSpacingUnit * 3),
        border: Border(bottom: BorderSide(
            width: 1.0,
            color: const Color(0x80CBCACA)
        )),
        // color: Theme.of(context).backgroundColor,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 14,
          ),
          SizedBox(width: kSpacingUnit * 1.5),
          Text(
            text,
            style: kTitleTextStyle.copyWith(
              fontSize: 13,
              color: const Color(0xFF1f1f1f),
              // fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          if (hasNavigation)
            Icon(
              FontAwesomeIcons.angleRight,
              color: const Color(0xFF1f1f1f),
              size: 12,
            ),
          if(hasSwitch)
            Switch(
              value: _isChecked,
              onChanged: (value) {
                // setState(() {
                _isChecked = value;
                // });
              },
            ),
          if(hasText)
            Text(
              value,
              style: kTitleTextStyle.copyWith(
                fontSize: 13,
                color: const Color(0xFF1f1f1f),
                // fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}