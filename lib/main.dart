import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:jnpass/constants.dart';
import 'package:jnpass/models/notiJwttokenEvent.dart';
import 'package:jnpass/pages/consultWrite.dart';
import 'package:jnpass/pages/home.dart';
import 'package:jnpass/pages/notice_page.dart';
import 'package:jnpass/provider/formProvider.dart';
import 'package:jnpass/provider/stepProvider.dart';
import 'package:jnpass/util.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'api/jsonapi.dart';
import 'common.dart';
import 'firebase_options.dart';
import 'models/apiResponse.dart';
import 'pages/login_page.dart';
import 'pages/news.dart';
import 'pages/popover.dart';
import 'pages/profile_page.dart';

late SharedPreferences pref;
late String? token;
String appVer = '';
int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
StreamController<String?>.broadcast();

const MethodChannel platform =
MethodChannel('dexterx.dev/flutter_local_notifications_example');

int todaySteps = 0;
// 네이티브와 EventChannel로 연결하는 부분임을 알수있다.
// 백그라운드 으로 step_count를 통해서 전달함
const EventChannel stepDetectionChannel = EventChannel('step_detection');
const stepCountChannel = EventChannel('step_count');
late StreamSubscription _timerSubscription;

//
late Stream<StepCount> _stepCountStream;
late Stream<PedestrianStatus> _pedestrianStatusStream;


const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint('Handling a background message ${message.messageId}');
}

void showFlutterNotification(RemoteMessage message) {
  debugPrint('show : ${message.data}');

  SharedPreferences.getInstance().then((value) async {
    pref = value;
    pref.setString('link', message.data.toString());
  });

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'app_icon',
          ),
        ),
        payload: message.data.toString()
      //추가해주면 클릭시 selectNotificationStream 에 Listen 반응
    );
  }
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;

  FirebaseMessaging.instance.getToken().then((value) {

    if(value != null)
    {
      token = value;

      SharedPreferences.getInstance().then((value) async {
        pref = value;
        pref.setString('firebaseToken', token.toString());
        jwtToken = pref.getString('jwt_token') ?? "";

        if(jwtToken.isNotEmpty)
        {
          app_token_update();
        }
      });
    }
  });

  PackageInfo.fromPlatform().then((value){
    appVer = value.version;
    debugPrint('appVer : $appVer');
  });

}

Future<void> app_token_update() async {
  String atDevice = '';

  var uuid = const Uuid();

  jwtToken = pref.getString('jwt_token') ?? "";

  if(defaultTargetPlatform == TargetPlatform.iOS) {
    atDevice = 'I';
  }
  else if(defaultTargetPlatform == TargetPlatform.android) {
    atDevice = 'A';
  }

  final parameters = {"udid": uuid.v4(), "device": atDevice, "token": token.toString(), "token": token.toString(), "appver":appVer, "jwt_token" : jwtToken};
  JsonApi.postApi("rest/app_token", parameters).then((value) {
    ApiResponse apiResponse = ApiResponse();

    apiResponse = value;

    if((apiResponse.apiError).error == "9") {

      final responseData = json.decode(apiResponse.data.toString());

      if(kDebug)
      {
        debugPrint('data ${apiResponse.data}');
      }

      if(responseData['result'])
      {
        pref.setString('jwt_token', responseData['jwt_token']);
      }
      else
      {
        if(responseData['message'] != '')
        {
          Fluttertoast.showToast(
              msg: responseData['message'],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 13.0
          );
        }
      }
    }
    else
    {
      Fluttertoast.showToast(
          msg: (apiResponse.apiError).msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 13.0
      );
    }

  });
}


Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();
  await initializeService();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.blueAccent,
  //   ),
  // );

  // IOS 용
  // await Firebase.initializeApp(name: 'jbi',options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
  <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationStream.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );

  final LinuxInitializationSettings initializationSettingsLinux =
  LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {

      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
        // if (notificationResponse.actionId == navigationActionId) {
          selectNotificationStream.add(notificationResponse.payload);
          // }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StepProvider()),
        ChangeNotifierProvider(create: (_) => FormProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  debugPrint('initializeService');

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    '하루에 10,000 걸음 우리동네 SOS', // title
    description:
    '업데이트중...', // description
    importance: Importance.low, // importance must be at low or higher level
    showBadge: false,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: notificationChannelId,
      initialNotificationTitle: '하루에 10000 걸음 우리동네 SOS',
      initialNotificationContent: '업데이트중...',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  SharedPreferences.getInstance().then((value) async {
    pref = value;

    todaySteps = pref.getInt('todaySteps') ?? 0;

    flutterLocalNotificationsPlugin.show(
      888,
      '$todaySteps 걸음',
      '하루에 10,000 걸음 우리동네 SOS v',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'my_foreground',
          'MY FOREGROUND SERVICE',
          icon: 'ic_bg_service_small',
          ongoing: true,
        ),
      ),
    );

  });

}

Future<void> step_count(value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int todayDayNo = DateTime.now().day;
  int savedStepCount = prefs.getInt('savedStepCount') ?? 0;
  int lastDaySaved = prefs.getInt('lastDaySaved') ?? 0;
  int todaySteps = prefs.getInt('todaySteps') ?? 0;
  int lastValue = prefs.getInt('stepsLastValue') ?? 0;
  prefs.setInt('stepsLastValue', value);

  // device reboot
  if (savedStepCount > value) {
    prefs.setInt('savedStepCount', 0);
    savedStepCount = 0;
  }

  // next day
  if (todayDayNo > lastDaySaved) {
    prefs.setInt('lastDaySaved', todayDayNo);
    prefs.setInt('savedStepCount', value);
    prefs.setInt('todaySteps', 0);
    savedStepCount = value;
    todaySteps = 0;
  }

  if (savedStepCount == 0 && todaySteps > value) {
    if (value < 10) {
      prefs.setInt('todaySteps', value + todaySteps);
    } else {
      prefs.setInt('todaySteps', value - lastValue + todaySteps);
    }
  } else {
    prefs.setInt('todaySteps', value - savedStepCount);
  }

  todaySteps = prefs.getInt('todaySteps') ?? 0;

  debugPrint('step_count $todaySteps');

  flutterLocalNotificationsPlugin.show(
    888,
    '$todaySteps 걸음',
    '하루에 10,000 걸음 우리동네 SOS',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'my_foreground',
        'MY FOREGROUND SERVICE',
        icon: 'ic_bg_service_small',
        ongoing: true,
      ),
    ),
  );

}

void onStepCount(StepCount event) {
  pref.reload();
  int todaySteps = pref.getInt("todaySteps") ?? 0;
  GetIt.I.get<StepProvider>().setStep(todaySteps);

  debugPrint('onStepCount $todaySteps');

}

void onStepCountError(error) {
  debugPrint('onStepCountError: $error');
}

void onPedestrianStatusChanged(PedestrianStatus event) {

}

void onPedestrianStatusError(error) {
  debugPrint('onPedestrianStatusError: $error');
}


@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  service.on('update').listen((event) {
    debugPrint('received data message in feed: $event');

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: event!['title'],
        content: event['content'],
      );

      flutterLocalNotificationsPlugin.show(
          notificationId,
          event!['title'],
          event['content'],
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              // other properties...
            ),
          ),
          payload: ''
      );
    }

  });

  debugPrint('onStart');
  _timerSubscription = stepCountChannel.receiveBroadcastStream().listen(step_count);
  /*
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
          flutterLocalNotificationsPlugin.show(
            888,
            'COOL SERVICE',
            'Awesome ${DateTime.now()}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'my_foreground',
                'MY FOREGROUND SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            ),
          );

        // if you don't using custom notification, uncomment this
        pref.reload();
        String todaySteps = pref.getString("todaySteps") ?? "0";
        service.setForegroundNotificationInfo(
          title: "$todaySteps 걸음",
          content: "${DateTime.now()} 하루에 10,000 걸음 우리동네 SOS",
        );
      }
    }

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
  */

}
@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('FLUTTER BACKGROUND FETCH');

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.reload();
  // final log = preferences.getStringList('log') ?? <String>[];
  // log.add(DateTime.now().toIso8601String());
  // await preferences.setStringList('log', log);

  return true;
}


Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); //세로

    return MaterialApp(
      // title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute: (jwtToken != "") ? '/' : '/login',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: '우리동네 SOS'),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String token = '';
  bool _notificationsEnabled = false;
  String initialMessage = "";
  bool _resolved = false;
  late final Timer timer;
  late String todayStep = "0";
  int selectedIndex = 0;
  NotiJwttokenEvent notiJwttokenEvent = NotiJwttokenEvent();

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  Future<void> splash() async {
    // debugPrint('ready in 2...');
    // await Future.delayed(const Duration(seconds: 1));
    // debugPrint('ready in 1...');
    // await Future.delayed(const Duration(seconds: 1));
    debugPrint('go!');
    FlutterNativeSplash.remove();
  }

  void _handleNotification(Map<String, dynamic> message) {
    debugPrint('message.link ${message['link'].toString()}');
    debugPrint('message.click_action ${message['click_action'].toString()}');

    // ignore: unnecessary_null_comparison
    if (message != null) {
      var parts = message['link'].split('/');
      // debugPrint('parts $parts');
      if(parts[1] != '')
      {

        // Navigator.of(context,rootNavigator: true).push(
        //   MaterialPageRoute(builder: (context) =>
        //       MovieViewPage(boTable: parts[1], wrId: parts[2],)),).then((value){
        // });
      }
    }

    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      throw UnimplementedError();
    }

  }

  @override
  void initState() {
    super.initState();

    GetIt.I.isRegistered<StepProvider>() ? null : GetIt.I.registerSingleton<StepProvider>(StepProvider(), signalsReady: true);
    GetIt.I.isRegistered<FormProvider>() ? null : GetIt.I.registerSingleton<FormProvider>(FormProvider(), signalsReady: true);
    // GetIt.I.isRegistered<LocationProvider>() ? null : GetIt.I.registerSingleton<LocationProvider>(LocationProvider(), signalsReady: true);
    notiJwttokenEvent.addListener(notiEventListener);

    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
          _resolved = true;

          initialMessage = value?.data.toString() ?? '';

          if(initialMessage.isNotEmpty)
          {
            var parts = initialMessage.split('/');

            // debugPrint('parts $parts');
            if(parts![1].isNotEmpty)
            {

              SharedPreferences.getInstance().then((value) async {
                pref = value;
                pref.setString('link', initialMessage.toString());
              });

              // Navigator.of(context,rootNavigator: true).push(
              //   MaterialPageRoute(builder: (context) =>
              //       MovieViewPage(boTable: parts[1], wrId: parts[2],)),).then((value){
              // });
            }
          }

        },
      ),
    );

    // click_action: FLUTTER_CLICK_ACTION
    // APP 실행중 푸시 전달
    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    // 백그라운드에서 푸시 전달
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      debugPrint('A new onMessageOpenedApp event was published!');
      debugPrint('message.data ${message.data.toString()}');

      _handleNotification(message.data);
    });

    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();

    // 업데이트 어플 설치 여부
    // initPackageInfo();
    splash();

    SharedPreferences.getInstance().then((value) async {
      pref = value;
      jwtToken = pref.getString('jwt_token') ?? "";

      initPlatformState();

    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SharedPreferences.getInstance().then((value) async {
        pref = value;

        String? link = pref.getString('link');

        if(link != null)
        {
          var parts = link?.split('/');
          pref.setString('link', '');

          debugPrint('parts $parts');

          if(parts!.isNotEmpty)
          {
            if(parts?[1] != '')
            {

            }
            else
            {

            }

          }
        }
      });
    });

  }

  void notiEventListener() {
    // Current class name print
    debugPrint('notiEventListener ${notiJwttokenEvent.msg}');
    jwtToken = notiJwttokenEvent.msg;

    setState(() {

    });
  }

// 만보기 초기 설정
  Future<void> initPlatformState() async {

    // 안드로이드 상위 버전 때문에  대한 권한 설정
    PermissionStatus activityRecognitionEnabled = Platform.isAndroid ? await Permission.activityRecognition.status : await Permission.sensors.status; // Check if permission is granted
    Platform.isAndroid ? await Permission.activityRecognition.request() : await Permission.sensors.request(); //Request permission

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);
    _stepCountStream = Pedometer.stepCountStream;

    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }


  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      setState(() {
        _notificationsEnabled = granted ?? false;
      });
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                // Navigator.of(context, rootNavigator: true).pop();
                // await Navigator.of(context).push(
                //   MaterialPageRoute<void>(
                //     builder: (BuildContext context) =>
                //         SecondPage(receivedNotification.payload),
                //   ),
                // );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      debugPrint('payLoad :: $payload');
      Map<String,dynamic> valueMap = Util.jsonStringToMap(payload!);
      debugPrint('valueMap :: $valueMap');

      _handleNotification(valueMap);

    });
  }


  // 접수 클릭시
  void centerLayer(BuildContext ctx) {

    showModalBottomSheet<int>(
        backgroundColor: Colors.transparent,
        context: ctx,
        builder: (context) {
          return Popover(
            child: Column(
              children: [
                Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical:8.0
                        ),
                        child: Text("접수하기",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      )
                    ]
                ),
                InkWell(
                  onTap: () async {
                    // push 할때 클래스에 데이터를 실어서 보냄 arguments:Arguments(arg: "i'm argument")
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConsultWrite()
                      ),
                    ).then((value) {
                      if (value != null) {

                        if(kDebug)
                        {
                          debugPrint('sos : ${value['msg']} : ${value['wr_id']} ');
                        }

                        // 등록되면 현재 페이지 닫고 상세페이지로 이동
                        if (value['msg'] == "ok") {
                          Navigator.pop(context);

                          // Navigator.of(context, rootNavigator: true).push(
                          //     MaterialPageRoute(builder: (context) =>
                          //         ShareView(boTable: 'share',
                          //             wrId: value['wr_id'].toString(),
                          //             like: '1',
                          //             share: '1'))
                          // );
                        }
                      }
                    });
                  },
                  child:_buildListItem(
                    context,
                    color: const Color(0xFF98BF54),
                    title: '온라인상담',
                    leading: const Icon(Icons.newspaper_outlined, color: Colors.white,),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    launchUrl(Uri.parse('tel: 1522-0365'));
                  },
                  child:_buildListItem(
                      context,
                      color: const Color(0xFF52A4DA),
                      title: '전화하기',
                      leading: const Icon(Icons.call, color: Colors.white),
                      trailing: const Align(alignment: Alignment.topRight, child: Text("1522-0365", style: TextStyle(color: Colors.white),))
                  ),
                ),
              ],
            ),
          );
        }
    );
  }


  void bottomTapped(int index) {

    if(kDebug)
    {
      debugPrint('tad $index move');
    }

    if(index != 2)
    {
      setState(() {
        selectedIndex = index;
      });
      // pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
      pageController.jumpToPage(index);
    }
  }

  void pageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget buildPageView() => PageView(
      controller: pageController,
      physics:const NeverScrollableScrollPhysics(),  // 슬라이드 기능 false
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: [
        const HomePage(),
        const NoticePage(),
        const NoticePage(),
        const NewsPage(),
        (jwtToken.isEmpty) ? const LoginPage() : const ProfilePage()
      ]
  );

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      // title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body:buildPageView(),
          bottomNavigationBar : BottomNavigationBar(
            //1f1f1f
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,          //Bar의 배경색
            selectedItemColor: const Color(0xff51a5db),   //선택된 아이템의 색상
            unselectedItemColor: const Color(0xff949494), //선택 안된 아이템의 색상
            selectedFontSize: 12,   //선택된 아이템의 폰트사이즈
            unselectedFontSize: 12, //선택 안된 아이템의 폰트사이즈
            currentIndex: selectedIndex, //현재 선택된 Index
            onTap: (int index) {
              setState(() {
                selectedIndex = index;
              });

              bottomTapped(index);
            },
            items: [
              const BottomNavigationBarItem(
                label: '홈',
                icon: Icon(Icons.home),
              ),
              const BottomNavigationBarItem(
                label:'알림',
                icon: Icon(FontAwesomeIcons.bell),
              ),
              const BottomNavigationBarItem(
                label: '상담하기',
                icon: Icon(null),
              ),
              const BottomNavigationBarItem(
                label: '동네소식',
                icon: Icon(Icons.library_books),
              ),
              BottomNavigationBarItem(
                label: (jwtToken.isEmpty) ? '로그인' : '나의활동' ,
                icon: const Icon(Icons.manage_accounts),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () {
                // 상담하기
                centerLayer(context);
              },
              child: Image.asset("assets/images/icon_sos.png", fit:BoxFit.fitWidth, colorBlendMode: BlendMode.darken)
            // color: Color(0xFFFFFFFF),
            // backgroundColor: Colors.green,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        )
    );

  }


  @override
  void dispose()
  {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    pageController.dispose();
    notiJwttokenEvent.removeListener(notiEventListener);

    // timer.cancel();

    super.dispose();
  }

  Widget _buildListItem(
      BuildContext context, {
        required Color? color,
        required String? title,
        required Widget leading,
        Widget? trailing,
      }) {
    final theme = Theme.of(context);

    return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          // color: Colors.blue,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(10))
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 10.0,
          ),
          child:Row(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ignore: unnecessary_null_comparison
              if (leading != null) leading,
              // ignore: unnecessary_null_comparison
              if (title != null)
                Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: RichText(
                      text: TextSpan(text: title, style: const TextStyle(color: Colors.white)
                      ),
                    )
                ),
              // const Spacer(),
              if (trailing != null)
                Expanded(child: trailing, ),
              const SizedBox(height:10),
            ],
          ),
        )
    );
  }
}