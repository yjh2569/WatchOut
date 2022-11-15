import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../dialog/basic_dialog.dart';
import '../dialog/permission_rationale_dialog.dart';

class PermissionService {
  Future<void> askPermission(
      BuildContext context, Permission permission, String message) async {
    if (await permission.isGranted) {
      return;
    }
    if (permission == Permission.locationAlways) {
      Future.microtask(() => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BasicDialog(
                  EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 1.25.h),
                  25.h,
                  '24시간 무응답 시 응급 상황 전파 기능은\n백그라운드에서 위치 정보를 수신하고,\n자동 문자 전송이 이루어질 수 있습니다.\n이 기능을 원치 않으시면 설정 페이지에서\n 스크린 사용 감지를 off로 바꿔주세요.',
                  null))));
    }
    Future.microtask(() => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PermissionRationaleDialog(permission, message))));
  }

  // bool permissionOnce = false;
  // void _permission(BuildContext context) async {
  //   if (permissionOnce) {
  //     return;
  //   }
  //   permissionOnce = true;
  //   askPermission(context, Permission.locationAlways,
  //       "WatchOuT 백그라운드에서 \n'응급 상황 전파' 및 '귀갓길 공유' \n등의 기능을 사용할 수 있도록 \n'항상 허용'을 선택해 주세요.");
  //   askPermission(context, Permission.location,
  //       "WatchOuT에서 \n'안전 지도' 및 '귀갓길 공유' \n등의 기능을 사용할 수 있도록 \n'위치 권한'을 허용해 주세요.");
  //   // if (await Permission.location.isDenied) {
  //   //   debugPrint("위치권한 거부");
  //   //   return;
  //   // }
  //   askPermission(context, Permission.sms,
  //       "WatchOuT에서 \n'응급 상황 전파', '귀갓길 공유', \n'귀갓길 공유자에게 문자' 기능에서 \n'문자 전송 기능'을 사용할 수 있도록 \n'SMS 권한'을 허용해 주세요.");
  // }
  //백그라운드 권한 요청
  bool permissionBackgroundOnce = false;
  void permissionBackground(BuildContext context) async {
    if (permissionBackgroundOnce) {
      return;
    }
    permissionBackgroundOnce = true;
    askPermission(context, Permission.locationAlways,
        "WatchOuT 백그라운드에서 \n'응급 상황 전파' 및 '귀갓길 공유' \n등의 기능을 사용할 수 있도록 \n'항상 허용'을 선택해 주세요.");
  }

  //위치 권한 요청
  bool permissionLocationOnce = false;
  void permissionLocation(BuildContext context) async {
    if (permissionLocationOnce) {
      return;
    }
    permissionLocationOnce = true;
    askPermission(context, Permission.location,
        "WatchOuT에서 \n'안전 지도' 및 '귀갓길 공유' \n등의 기능을 사용할 수 있도록 \n'위치 권한'을 허용해 주세요.");
  }

  bool permissionSMSOnce = false;
  void permissionSMS(BuildContext context) async {
    if (permissionSMSOnce) {
      return;
    }
    print("It is not returning");
    permissionSMSOnce = true;
    askPermission(context, Permission.sms,
        "WatchOuT에서 \n'응급 상황 전파', '귀갓길 공유', \n'귀갓길 공유자에게 문자' 기능에서 \n'문자 전송 기능'을 사용할 수 있도록 \n'SMS 권한'을 허용해 주세요.");
  }
}