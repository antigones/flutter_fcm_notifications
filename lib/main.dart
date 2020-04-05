import 'package:english_words/english_words.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message = '';
  List _receivedMessagesList = new List();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  _register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  _initLocalNotifications() async {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    _receivedMessagesList.clear();
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessage();
    _initLocalNotifications();
  }

  Future<void> _showGroupedMockFCM(List messageList) async {
    String groupKey = 'com.example.flutterfcmnotifications.WORK_EMAIL';
    String groupChannelId = 'grouped channel id';
    String groupChannelName = 'grouped channel name';
    String groupChannelDescription = 'grouped channel description';
// example based on https://developer.android.com/training/notify-user/group.html
    /* if (messageList.length <= 1) {
      AndroidNotificationDetails firstNotificationAndroidSpecifics =
          new AndroidNotificationDetails(
        groupChannelId,
        groupChannelName,
        groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey,
      );
      var message = messageList.first;
      NotificationDetails firstNotificationPlatformSpecifics =
          new NotificationDetails(firstNotificationAndroidSpecifics, null);
      await flutterLocalNotificationsPlugin.show(
          1,
          message["notification"]["title"],
          message["notification"]["body"],
          firstNotificationPlatformSpecifics);
      AndroidNotificationDetails secondNotificationAndroidSpecifics =
          new AndroidNotificationDetails(
        groupChannelId,
        groupChannelName,
        groupChannelDescription,
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: groupKey,
      );
    }
    // create the summary notification required for older devices that pre-date Android 7.0 (API level 24)
    else {*/
    print(messageList.length.toString() + " messages in queue");
    List<String> lines = new List<String>();
    for (var message in messageList) {
      print(message);
      lines.add(message["notification"]["title"] +
          " " +
          message["notification"]["body"]);
    }
    print(lines);
    InboxStyleInformation inboxStyleInformation = new InboxStyleInformation(
        lines,
        contentTitle: messageList.length.toString() + ' new messages',
        summaryText: 'MyAwesomeFCMFlutterApp');
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        new AndroidNotificationDetails(
            groupChannelId, groupChannelName, groupChannelDescription,
            styleInformation: inboxStyleInformation,
            groupKey: groupKey,
            setAsGroupSummary: true);
    NotificationDetails platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        2,
        'Attention',
        messageList.length.toString() + ' new messages',
        platformChannelSpecifics);
    //}
  }

  Future<void> _showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max,
        priority: Priority.High,
        groupKey: 'com.android.example.WORK_EMAIL');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message["notification"]["title"],
      message["notification"]["body"],
      platformChannelSpecifics,
      payload: message["data"],
    );
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('ON MESSAGE $message');
      _receivedMessagesList.add(message);
      //_showNotification(message);
      _showGroupedMockFCM(_receivedMessagesList);
      setState(() => _message = message["notification"]["title"]);
    }, onResume: (Map<String, dynamic> message) async {
      print('ON RECEIVE $message');
      _showGroupedMockFCM(_receivedMessagesList);
      //_showNotification(message);
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('ON LAUNCH $message');
      _showGroupedMockFCM(_receivedMessagesList);
      //_showNotification(message);
      setState(() => _message = message["notification"]["title"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Message: $_message"),
                OutlineButton(
                    child: Text("Register My Device"),
                    onPressed: () {
                      _register();
                    }),
                OutlineButton(
                    child: Text("Show mock"),
                    onPressed: () {
                      var message = Map<String, dynamic>();

                      message["notification"] = {
                        'title': WordPair.random().toString(),
                        'body': generateWordPairs().take(5).toList().join(" ")
                      };
                      //print(message);
                      _receivedMessagesList.add(message);
                      //print(_receivedMessagesList.length);
                      _showGroupedMockFCM(_receivedMessagesList);
                    }),

                OutlineButton(
                    child: Text("Clear list"),
                    onPressed: () {
                      _receivedMessagesList.clear();
                    }),
                // Text("Message: $message")
              ]),
        ),
      ),
    );
  }
}
