import 'dart:async';
import 'dart:ui';

import 'package:background_fetch/background_fetch.dart' as fetch;
import 'package:encrypt/encrypt.dart' as en;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homealone/api/api_kakao.dart';
import 'package:homealone/api/api_message.dart';
import 'package:homealone/components/dialog/basic_dialog.dart';
import 'package:homealone/components/dialog/permission_rationale_dialog.dart';
import 'package:homealone/components/login/auth_service.dart';
import 'package:homealone/components/login/user_service.dart';
import 'package:homealone/components/wear/local_notification.dart';
import 'package:homealone/googleLogin/loading_page.dart';
import 'package:homealone/pages/emergency_manual_page.dart';
import 'package:homealone/pages/safe_area_cctv_page.dart';
import 'package:homealone/providers/contact_provider.dart';
import 'package:homealone/providers/heart_rate_provider.dart';
import 'package:homealone/providers/switch_provider.dart';
import 'package:homealone/providers/user_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:workmanager/workmanager.dart' as wm;

ApiKakao apiKakao = ApiKakao();
ApiMessage apiMessage = ApiMessage();

String kakaoMapKey = "";

double initLat = 37.5013;
double initLon = 127.0396;

String message = "";
List<String> recipients = [];
String address = "";
bool messageIsSent = false;

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
StreamSubscription<Position>? _positionStreamSubscription;

const locationCheck = "locationCheck";
const fetchBackground = "fetchBackground";

const platform = MethodChannel('com.ssafy.homealone/channel');

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(fetch.HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    debugPrint("[백그라운드 헤드리스] Headless task timed-out: $taskId");
    fetch.BackgroundFetch.finish(taskId);
    return;
  }
  debugPrint('[백그라운드 헤드리스] Headless event received.');
  // Do your work here...
  initializeService();
  refreshUsage();

  fetch.BackgroundFetch.finish(taskId);
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ContactInfo>(create: (_) => ContactInfo()),
        ChangeNotifierProvider<SwitchBools>(create: (_) => SwitchBools()),
        ChangeNotifierProvider<MyUserInfo>(create: (_) => MyUserInfo()),
        ChangeNotifierProvider<HeartRateProvider>(
            create: (_) => HeartRateProvider()),
      ],
      child: MyApp(),
    ),
  );

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  fetch.BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

// void initQuickActions() {
//   final QuickActions _quickActions = new QuickActions();
//   _quickActions.initialize((navigateRoute);
//   _quickActions.setShortcutItems([
//     ShortcutItem(type: "SOS", localizedTitle: "SOS"),
//     ShortcutItem(type: "SafeHome", localizedTitle: "안심귀가"),
//     ShortcutItem(type: "성범죄자 알림e", localizedTitle: "알림e"),
//     ShortcutItem(type: "SafeZone", localizedTitle: "안전구역"),
//   ]);
// }

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    initializeService();
    initUsage();
    handlePlatformChannelMethods();
    wm.Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    wm.Workmanager().registerPeriodicTask(locationCheck, fetchBackground,
        frequency: Duration(minutes: 15),
        initialDelay: Duration(seconds: 60),
        constraints: wm.Constraints(
            networkType: wm.NetworkType.not_required,
            requiresDeviceIdle: true));
    // debugPrint("메인꺼");
    // SharedPreferences.getInstance().then(
    //   (value) => {
    //     debugPrint(value.hashCode.toString()),
    //     debugPrint(value.getBool("useWearOS").toString())
    //   },
    //
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WatchOuT',
          theme: ThemeData(
            fontFamily: 'HanSan',
            primarySwatch: Colors.blue,
            primaryColor: Colors.white,
            accentColor: Colors.black,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final quickActions = QuickActions();

  @override
  void initState() {
    super.initState();
    quickActions.setShortcutItems([
      ShortcutItem(type: "SafeZone", localizedTitle: "안전 구역", icon: 'safezone'),
      ShortcutItem(
          type: "EmergencyManual", localizedTitle: "응급상황 메뉴얼", icon: 'manual'),
    ]);
    quickActions.initialize((type) {
      if (type == "SafeZone") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SafeAreaCCTVMapPage()));
      } else if (type == "EmergencyManual") {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => EmergencyManual()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchOuT',
      theme: ThemeData(
        fontFamily: 'HanSan',
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        accentColor: Colors.black,
      ),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          _permission(context);
          if (snapshot.hasError) {
            return LoadingPage();
          }
          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            debugPrint("handleAuthstate로 넘어감");
            return AuthService().handleAuthState();
          }
          // Otherwise, show something whilst waiting for initialization to complete
          return LoadingPage();
        },
      ),
    );
  }
}

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
                EdgeInsets.fromLTRB(5.w, 4.h, 5.w, 3.h),
                24.h,
                '24시간 무응답 시 응급 상황 전파 기능은\n백그라운드에서 위치 정보를 수신하고,\n자동 문자 전송이 이루어질 수 있습니다.\n이 기능을 원치 않으시면 설정 페이지에서\n 스크린 사용 감지를 off로 바꿔주세요.',
                null))));
  }
  Future.microtask(() => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PermissionRationaleDialog(permission, message))));
}

bool permissionOnce = false;
void _permission(BuildContext context) async {
  if (permissionOnce) {
    return;
  }
  permissionOnce = true;
  askPermission(context, Permission.locationAlways,
      "WatchOuT에서 \n백그라운드에서 \n'응급 상황 전파' 및 '귀갓길 공유' \n등의 기능을 사용할 수 있도록 \n'항상 허용'을 선택해 주세요.");
  askPermission(context, Permission.location,
      "WatchOuT에서 \n'안전 지도' 및 '귀갓길 공유' \n등의 기능을 사용할 수 있도록 \n'위치 권한'을 허용해 주세요.");
  // if (await Permission.location.isDenied) {
  //   debugPrint("위치권한 거부");
  //   return;
  // }
  askPermission(context, Permission.sms,
      "WatchOuT에서 \n'응급 상황 전파', '귀갓길 공유', \n'귀갓길 공유자에게 문자' 기능에서\n문자 전송 기능을 사용할 수 있도록 \n'SMS 권한'을 허용해 주세요.");
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final SharedPreferences pref = await SharedPreferences.getInstance();

  if (service is AndroidServiceInstance) {
    onStartWatch(service, flutterLocalNotificationsPlugin, pref);
  }
}

Future<void> refreshUsage() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.reload();
  Future<int> count = initUsage();
  count.then((value) {
    debugPrint('24시간 이내에 사용한 앱 갯수 : $value');
    if (value == 0) {
      if (!messageIsSent) {
        _getKakaoKey().then((response) => sendEmergencyMessage());
      }
    } else {
      messageIsSent = false;
    }
  }).catchError((error) {
    debugPrint(error);
  });
}

Future<int> initUsage() async {
  int count = 0;

  UsageStats.grantUsagePermission();

  DateTime endDate = DateTime.now();
  DateTime startDate = endDate.subtract(Duration(days: 1));

  List<ConfigurationInfo> t2 =
      await UsageStats.queryConfiguration(startDate, endDate);
  for (var i in t2) {
    DateTime lastUsed =
        DateTime.fromMillisecondsSinceEpoch(int.parse(i.lastTimeActive!))
            .toUtc();
    if (lastUsed.isAfter(startDate)) count++;
  }

  return count;
}

void callbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        initLat = position.latitude;
        initLon = position.longitude;
        await refreshUsage();
        break;
    }
    return Future.value(true);
  });
}

Future _getKakaoKey() async {
  await dotenv.load();
  kakaoMapKey = dotenv.get('kakaoMapAPIKey');
  return kakaoMapKey;
}

void _sendSMS(String message, List<String> recipients) async {
  await platform.invokeMethod(
      'sendTextMessage', {'message': message, 'recipients': recipients});
}

Future<void> sendEmergencyMessage() async {
  await prepareMessage();
  if (recipients.isNotEmpty) {
    print(message);
    print(recipients);
    messageIsSent = true;
    _sendSMS(message, recipients); //테스트할때는 문자전송 막아놈
  }
}

Future<void> getCurrentLocation() async {
  address =
      await apiKakao.searchRoadAddr(initLat.toString(), initLon.toString());
}

Future<void> prepareMessage() async {
  await getCurrentLocation();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  message =
      "${preferences.getString('username')} 님이 24시간 동안 응답이 없습니다. 긴급 조치가 필요합니다.\n현재 예상 위치 : $address\n이 메시지는 WatchOut에서 자동 생성한 메시지입니다.";
  List<String>? list = await preferences.getStringList('contactlist');
  if (list != null) {
    recipients = list!;
  }
}

Future<dynamic> handlePlatformChannelMethods() async {
  var result = await platform
      .invokeMethod("getFriendLink")
      .onError((error, stackTrace) => debugPrint(error.toString()));
  if (result.runtimeType == String) {
    //Parameters received from Native…!!!!
    // debugPrint(result);
    await dotenv.load();
    String inviteRandomKey = dotenv.get('inviteRandomKey');
    String decoded = decodeInviteKey(inviteRandomKey, result);
    // TODO: 모달창 열고 onPressed로 이동
    registerFriend(decoded);
  }
}

String decodeInviteKey(String inviteRandomKey, String value) {
  //키값
  final key = en.Key.fromUtf8(inviteRandomKey);
  final iv = en.IV.fromLength(16);
  //위에 키값으로 지갑 생성
  final encrypter = en.Encrypter(en.AES(key));

  //생성된 지갑으로 복호화
  final decoded = encrypter.decrypt64(value, iv: iv);
  // debugPrint('-------복호화값: $decoded');
  return decoded;
}

void registerFriend(String decoded) {
  List<String> message = decoded.split(",");
  String expireTimeStr = message[0];
  String inviteCodeStr = message[1];

  debugPrint("초대코드 플러터에서 받음 ㅋㅋ: $inviteCodeStr \n만료일자: $expireTimeStr");

  DateTime expireTime = DateTime.parse(expireTimeStr);
  // 만료되기 전
  if (expireTime.isAfter(DateTime.now())) {
    UserService().registerFirstResponderFromInvite(inviteCodeStr);
  } else {
    debugPrint("만료된 초대코드입니다.");
  }
}
