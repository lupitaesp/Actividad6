import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Local Notifications Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }


class _MyHomePageState extends State<MyHomePage> {
  //Declarar el plugin

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  void _showNotification() async {
    await _simpleSchedulNotification();
  }

//Spesific time and every week
 /* Future<void> _simpleSchedulNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
    );

    var IOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, IOSPlatformChannelSpecifics);
    var now = new DateTime.now();
    var time = Time(1, 20, 0);
    //Notificar a los 3 minutos
   // var reprogram = now.add(Duration(hours: 1, minutes: 15, seconds: 00));
    //Id aleatorio(tarea)
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        'this is my third Notification',
        'Hello this notification only shown in one day ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
        Day.Tuesday,
        time,
        platformChannelSpecifics, payload: 'Hello from my data');
    //Ver la hora programada
    Fluttertoast.showToast(
        msg: "Scheduled at time one day at the week",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0);
  }*/

//CADA HORA
  /* Future<void> _simpleSchedulNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
    );

    var IOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, IOSPlatformChannelSpecifics);
    var now = new DateTime.now();
    //Notificar a los 3 minutos
    var reprogram = now.add(Duration(minutes: 1));
    //Id aleatorio(tarea)
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'this is my second Notification',
        'Hello from my second notification',
        RepeatInterval.EveryMinute,
        platformChannelSpecifics, payload: 'Hello from my data');
    //Ver la hora programada
    Fluttertoast.showToast(
        msg: "Scheduled at time $reprogram",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0);
  }*/

//Ejemplo del profe
     Future<void> _simpleSchedulNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
    );

    var IOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, IOSPlatformChannelSpecifics);
    var now = new DateTime.now();
    //Notificar a los 3 minutos
    var reprogram = now.add(Duration(hours: 00, minutes: 00, seconds: 5));
    //Id aleatorio(tarea)
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'this is my first Notification',
        'Hello from my first notification',
        RepeatInterval.EveryMinute,
        platformChannelSpecifics, payload: 'Hello from my data');
    //Ver la hora programada
    Fluttertoast.showToast(
        msg: "Scheduled at time $reprogram",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0);
  }
  @override
  void initState() {
    super.initState();
    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onSelectNotification);
  }

  Future _onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    await Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new SecondPage(payload: payload,)));
    print('Called On Select local Notification');
  }

  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SecondPage(payload: payload,)));
                  },
                ),

              ],
            ));
    print('Called On did Receive local Notification');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: new Text('This is my main page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                child: Icon(Icons.notification_important),
                onPressed: _showNotification,
                color: Colors.redAccent,
              ),
              SizedBox(width: 20, height: 20),
              MaterialButton(
                color: Colors.blue,
                child: Text("Cancel notification"),
                onPressed: () async{
                  await flutterLocalNotificationsPlugin.cancel(0);
                },
              )
            ],
          ),
        ));
  }
}

class SecondPage extends StatelessWidget {

  final String payload;
  const SecondPage({Key key, this.payload}) : super(key:key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: new Text('$payload'),
        ),
        body: Column(
          children: <Widget>[
            MaterialButton(
              child: Text('Go back...'),
              onPressed: () {
                Navigator.pop(context);
              }),

  ]
        ));
  }
}
