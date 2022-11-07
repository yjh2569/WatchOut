import 'package:flutter/material.dart';
import 'package:homealone/components/set/set_page_radio_button.dart';
import 'package:homealone/components/singleton/is_check.dart';
import 'package:homealone/constants.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/contact_provider.dart';
import '../login/user_service.dart';
import '../wear/heart_rate_view.dart';

final isCheck = IsCheck.instance;

class SetButton extends StatefulWidget {
  const SetButton({Key? key}) : super(key: key);

  @override
  State<SetButton> createState() => _SetButtonState();
}

class _SetButtonState extends State<SetButton> {
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _contactFieldController = TextEditingController();
  final List<String> _valueList = ['문자', '전화', '사용안함'];
  String _selectedAlert = '문자';
  List<String> _contactList = [];
  List<String> _nameList = [];
  String _selectedContact = '';
  String _addContact = '';
  String _addName = '';
  bool flag = true;

  @override
  Widget build(BuildContext context) {
    Map<String, String> firstResponder =
        Provider.of<ContactInfo>(context, listen: false).getResponder();
    if (!firstResponder.isEmpty && flag) {
      _nameList = firstResponder.keys.toList();
      _contactList = firstResponder.values.toList();
      flag = false; //최초 한번만 실행되도록 설정
    }
    if (!_nameList.isEmpty) _selectedContact = _nameList[0];
    return Column(
      children: [
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 1.5.h, 1.w, 0.75.h),
          texts: 'WearOS 사용',
          values: Provider.of<SwitchBools>(context, listen: false).useWearOS,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeWearOS();
            });
          },
        ),
        Provider.of<SwitchBools>(context, listen: true).useWearOS
            ? HeartRateView(
                margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
                provider:
                    Provider.of<HeartRateProvider>(context, listen: false),
              )
            : Container(),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '스크린 사용 감지',
          values: Provider.of<SwitchBools>(context, listen: false).useScreen,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeScreen();
            });
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '위치 정보 전송',
          values: Provider.of<SwitchBools>(context, listen: false).useGPS,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeGPS();
              print('셋버튼다트${isCheck.check}');
              print('셋버튼다트${isCheck.hashCode}');
            });
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '경보음 사용',
          values: Provider.of<SwitchBools>(context, listen: false).useSiren,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeSiren();
            });
          },
        ),
        SetPageRadioButton(
          margins: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 0.75.h),
          texts: '위험 지대 알림',
          values: Provider.of<SwitchBools>(context, listen: false).useDzone,
          onchangeds: (value) {
            setState(() {
              Provider.of<SwitchBools>(context, listen: false).changeDzone();
            });
          },
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 0.5.h, 5.w, 0.5.h),
            margin: EdgeInsets.fromLTRB(1.w, 0.75.h, 1.w, 1.5.h),
            decoration: BoxDecoration(
                color: b25Color, borderRadius: BorderRadius.circular(25)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _nameList.isEmpty
                    ? Text('비상연락처를 등록해주세요.')
                    : Row(
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: _selectedContact,
                              items: _nameList.map(
                                (value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: firstResponderText(
                                        _nameList, _contactList),
                                    // Text("${value} ${_contactList[0]}"),
                                  );
                                },
                              ).toList(),
                              onChanged: (value) {
                                setState(
                                  () {
                                    _selectedContact = value!;
                                  },
                                );
                              },
                            ),
                          ),
                          // Container(
                          //   margin: EdgeInsets.symmetric(horizontal: 5.w),
                          //   child: DropdownButtonHideUnderline(
                          //     child: DropdownButton(
                          //       value: _selectedAlert,
                          //       items: _valueList.map(
                          //         (value) {
                          //           return DropdownMenuItem(
                          //             value: value,
                          //             child: Text(value),
                          //           );
                          //         },
                          //       ).toList(),
                          //       onChanged: (value) {
                          //         setState(
                          //           () {
                          //             _selectedAlert = value!;
                          //           },
                          //         );
                          //       },
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _displayTextInputDiaLog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget firstResponderText(List name, List contact) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(name[0]),
          Text(contact[0]),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  UserService().deleteFirstResponder(name[0]);
                });
              },
              child: Text("삭제")),
        ],
      ),
    );
  }

  Future<void> _displayTextInputDiaLog(BuildContext context) async {
    _nameFieldController.clear();
    _contactFieldController.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.5)),
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
            height: 27.5.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Title(
                  color: bColor,
                  child: Text(
                    '비상 연락망',
                    style: TextStyle(
                      color: bColor,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                Container(
                  height: 12.5.h,
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _addName = value;
                          });
                        },
                        controller: _nameFieldController,
                        cursorColor: bColor,
                        decoration: InputDecoration(
                          hintText: '이름 또는 닉네임',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: bColor),
                          ),
                        ),
                      ),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _addContact = value;
                          });
                        },
                        controller: _contactFieldController,
                        keyboardType: TextInputType.phone,
                        cursorColor: bColor,
                        decoration: InputDecoration(
                          hintText: '연락처',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: bColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _contactList.add(_addContact);
                            _nameList.add(_addName);
                            UserService()
                                .registerFirstResponder(_addName, _addContact);
                            _nameFieldController.clear();
                            _contactFieldController.clear();
                            // Navigator.pop(context);
                          });
                        },
                        child: Text(
                          '등록',
                          style: TextStyle(
                            color: bColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: b25Color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _nameFieldController.clear();
                            _contactFieldController.clear();
                            Navigator.pop(context);
                          });
                        },
                        child: Text(
                          '닫기',
                          style: TextStyle(color: bColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
