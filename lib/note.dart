import 'package:flutter/material.dart';
import 'crud_operation.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'noti.dart';

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
            Container(height: 30.0),
              FilterChip(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 3,horizontal:10),
                      avatar: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.av_timer),
                      ),
                        label: Text('Hora',
                          style: TextStyle(
                            color: Colors.white),),
                      onSelected: (b) {
                          print(b);
                         // Navigator.push(context, MaterialPageRoute(
                          //builder: (context) => NoteList()
                          //));
                      },
                  ),
            Column(  
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            IconButton(icon: Icon(Icons.av_timer),
            iconSize: 40,
            color: Colors.black,
            onPressed: () {
              DatePicker.showDateTimePicker(context, showTitleActions: true, onChanged: (date) {
                print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
            }, onConfirm: (date) {
              print('confirm $date');
              }, currentTime: DateTime.now(), locale: LocaleType.en); //en english - es español
            },
           ),
            IconButton(icon: Icon(Icons.notification_important),
            iconSize: 40,
            color: Colors.black,
            onPressed: () {
              Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()
          ));
            },
           ),
              ],
            ),
          ],
        ),
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

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
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