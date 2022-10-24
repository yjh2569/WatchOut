import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';

class SetPage extends StatefulWidget {
  const SetPage({Key? key}) : super(key: key);

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  final _authentication = FirebaseAuth.instance;
  bool _useWearOS = false;
  bool _useScreen = false;
  bool _useGPS = false;
  bool _useSiren = false;
  bool _useDzone = false;
  final List<String> _valueList = ['문자', '전화', 'X'];
  String _selectedAlert = '문자';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
            color: pColor,
            borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('WearOS 사용'),
              Switch(
                  value: _useWearOS,
                  onChanged: (value) {
                    setState(() {
                      _useWearOS = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: pColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('스크린 사용 감지'),
              Switch(
                  value: _useScreen,
                  onChanged: (value) {
                    setState(() {
                      _useScreen = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: pColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('위치 정보 전송'),
              Switch(
                  value: _useGPS,
                  onChanged: (value) {
                    setState(() {
                      _useGPS = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: pColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('경보음 사용'),
              Switch(
                  value: _useSiren,
                  onChanged: (value) {
                    setState(() {
                      _useSiren = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: pColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('위험 지대 알림'),
              Switch(
                  value: _useDzone,
                  onChanged: (value) {
                    setState(() {
                      _useDzone = value;
                    });
                  }
              )
            ],
          ),
        ),
        Container(
          height: 50,
          width: 300,
          decoration: BoxDecoration(
              color: pColor,
              borderRadius: BorderRadius.circular(20)
          ),
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('비상 연락망 전송'),
              DropdownButton(
                value: _selectedAlert,
                items: _valueList.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value)
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAlert = value!;
                  });
                }
              ),
            ],
          ),
        ),
      ],
    );
  }
}
