import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'crud_operation.dart';

enum NoteMode {
  Editing,
  Adding
}

class Note extends StatefulWidget {

  final NoteMode noteMode;
  final Map<String, dynamic> note;

  Note(this.noteMode, this.note);

  @override
  NoteState createState() {
    return new NoteState();
  }
}

class NoteState extends State<Note> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  
  //List<Map<String, String>> get _notes => NoteInheritedWidget.of(context).notes;

  @override
  void didChangeDependencies() {
    if (widget.noteMode == NoteMode.Editing) {
      _titleController.text = widget.note['title'];
      _textController.text = widget.note['text'];
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.noteMode == NoteMode.Adding ? 'Add note' : 'Edit note'
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Note title'
              ),
            ),
            Container(height: 8,),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Note text'
              ),
            ),
            Container(height: 16.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _NoteButton('Save', Colors.blue, () {
                  final title = _titleController.text;
                  final text = _textController.text;

                  if (widget?.noteMode == NoteMode.Adding) {
                    NoteProvider.insertNote({
                      'title': title,
                      'text': text
                    });
                  } else if (widget?.noteMode == NoteMode.Editing) {
                    NoteProvider.updateNote({
                      'id': widget.note['id'],
                      'title': _titleController.text,
                      'text': _textController.text,
                    });
                  }
                  Navigator.pop(context);
                }),
                Container(height: 16.0,),
                _NoteButton('Discard', Colors.grey, () {
                  Navigator.pop(context);
                }),
                widget.noteMode == NoteMode.Editing ?
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: _NoteButton('Delete', Colors.red, () async {
                      await NoteProvider.deleteNote(widget.note['id']);
                      Navigator.pop(context);
                    }),
                  )
                 : Container()
              ],
            ),
            Container(height: 50.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.notifications_active,
                  color: Colors.grey,
                  size: 24.0,
                
                ),
                Text('Schedule notification', style: TextStyle(color: Colors.grey),)
                //ONPREES A LA OTRA PAGINA

              ],
            ),
            new Divider(
              color: Colors.black,
              indent: 90,
              endIndent: 90,
              thickness: 1.0),
            Container(height: 15.0),
            
          ],
        ),
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyHomePage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  
}

class _NoteButton extends StatelessWidget {

  final String _text;
  final Color _color;
  final Function _onPressed;

  _NoteButton(this._text, this._color, this._onPressed);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: _onPressed,
      child: Text(
        _text,
        style: TextStyle(color: Colors.white),
      ),
      height: 40,
      minWidth: 100,
      color: _color,
    );
  }
}

//DATATIME PICKER

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex(this.currentTime.day);
    this.setLeftIndex(this.currentTime.hour);
    this.setMiddleIndex(this.currentTime.minute);
    this.setRightIndex(this.currentTime.second);
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return "|";
  }

  @override
  String rightDivider() {
    return "|";
  }

  @override
  List<int> layoutProportions() {
    return [1, 2, 1];
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
            this.currentLeftIndex(), this.currentMiddleIndex(), this.currentRightIndex())
        : DateTime(currentTime.year, currentTime.month, currentTime.day, this.currentLeftIndex(),
            this.currentMiddleIndex(), this.currentRightIndex());
  }
}



//NOTIFICACION



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

 /* void _showNotification() async {
    await _simpleSchedulNotification();
  }*/

//Spesific time and every week
  Future _particularSchedulNotification(DateTime timee) async {
    var time = Time(timee.hour, timee.minute);
    var date = Day(timee.day);
    print(time.toString());
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
    );

    var IOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, IOSPlatformChannelSpecifics);
    var now = new DateTime.now();

    //Notificar a los 3 minutos
   // var reprogram = now.add(Duration(hours: 1, minutes: 15, seconds: 00));
    //Id aleatorio(tarea)
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        'this is my third Notification',
        'Hello this notification only shown in one day ',
        date,
        time,
        platformChannelSpecifics, payload: 'Hello from my data');
    //Ver la hora programada
    Fluttertoast.showToast(
        msg: "Scheduled at time one day at the week '$date' ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0);
  }

//CADA HORA
   Future<void> _simpleSchedulNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
    );

    var IOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, IOSPlatformChannelSpecifics);
    var now = new DateTime.now();
    //Notificar a los 3 minutos
    var reprogram = now.add(Duration(minutes: 59));
    //Id aleatorio(tarea)
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'this is my second Notification',
        'Hello from my second notification',
        RepeatInterval.Hourly,
        platformChannelSpecifics, payload: 'Hello from my data');
    //Ver la hora programada
    Fluttertoast.showToast(
        msg: "Scheduled at time every $reprogram",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.grey,
        textColor: Colors.white,);
  }

//Cada semana
 Future<void> _weekSchedulNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
    );

    var IOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, IOSPlatformChannelSpecifics);
    var now = new DateTime.now();
    //Notificar a los 3 minutos
    var reprogram = now.add(Duration(minutes: 59));
    //Id aleatorio(tarea)
    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'this is my tres Notification',
        'Hello from my second notification',
        RepeatInterval.Weekly,
        platformChannelSpecifics, payload: 'Hello from my data');
    //Ver la hora programada
    Fluttertoast.showToast(
        msg: "Scheduled at time every week",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.grey,
        textColor: Colors.white,);
  }



//Ejemplo del profe
  Future scheuleAtParticularTime(DateTime timee) async {
    var time = Time(timee.hour, timee.minute, timee.second);
    print(time.toString());
   
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
    );

    var IOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, IOSPlatformChannelSpecifics);
    var now = new DateTime.now();
    //Notificar a los 3 minutos
   // var reprogram = now.add(Duration(hours: 00, minutes: 00, seconds: 5));
    //Id aleatorio(tarea)
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'this is my first Notification',
        'Hello from my first notification',
        time,
        platformChannelSpecifics, payload: 'Hello from my data');
    //Ver la hora programada
    Fluttertoast.showToast(
        msg: "Scheduled at time ${time.hour} : ${time.minute} : ${time.second} ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
    );
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
    return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                  //POR HORA
                  MaterialButton(
                      onPressed: _simpleSchedulNotification,
                      child: Text('En una hora',
                        style: TextStyle(color: Colors.white),
              
                  
                      ),
                      
                      height: 40,
                      minWidth: 80,
                      color: Colors.amber,
                    ),
                    Container(height: 15.0),
                  //SEMANALMENTE
                  MaterialButton(
                      onPressed: _simpleSchedulNotification,
                      child: Text('Semanalmente',
                        style: TextStyle(color: Colors.white),
                      ),
                      height: 40,
                      minWidth: 80,
                      color: Colors.cyan,
                    ),
                    Container(height: 15.0),
                  //TIEMPO ESPECIFICO
                  MaterialButton(
                   /* onPressed: () {
                        DatePicker.showTimePicker(context, showTitleActions: true,
                        onChanged: (date) {
                          print('change $date');
                        }, onConfirm: (date) {
                          print('confirm $date');
                          scheuleAtParticularTime(
                              DateTime.fromMillisecondsSinceEpoch(
                                  date.millisecondsSinceEpoch));
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
          
                      },*/
                

                  onPressed: () {
                        DatePicker.showDateTimePicker(context, showTitleActions: true, onChanged: (date) {
                    print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                   _particularSchedulNotification(
                              DateTime.fromMillisecondsSinceEpoch(
                                  date.millisecondsSinceEpoch));
                  }, onConfirm: (date) {
                    print('confirm $date');

                  }, currentTime: DateTime.now(), locale: LocaleType.en); //en english - es español
                      },
                      child: Text('Especifico',
                        style: TextStyle(color: Colors.white),
                      ),
                      height: 40,
                      minWidth: 80,
                      color: Colors.purple,
                    ),
                  ],
                );
            
      
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






 