class Notificacion{
  //CAMPOS
  int id;
  String title;
  String description;

  //CONSTRUCTOR
  Notificacion (this.id, this.title, this.description);

  //MAPEO
  Map<String,dynamic>toMap(){
    var map = <String,dynamic>{
      'id': id,
      'title': title,
      'description': description,
    };
    return map;
  }

  Notificacion.fromMap(Map<String,dynamic> map){
    id = map['id'];
    title = map['title'];
    description = map['description'];
  }
}