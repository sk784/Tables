import 'package:employeers/data/child.dart';
import 'package:employeers/data/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class ChildrenPage extends StatefulWidget {

 final int parentId;

  ChildrenPage({this.parentId});

  @override
  _ChildrenPageState createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {

  Child child;
  TextEditingController lastNameController;
  TextEditingController firstNameController;
  TextEditingController middleNameController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isDate = false;


  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    child = Child();
    child.parentId = widget.parentId;
    lastNameController = TextEditingController();
    firstNameController = TextEditingController();
    middleNameController = TextEditingController();
    DatabaseProvider.db.calculateQuantityOfChildren(widget.parentId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Дети'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 16.0,
              ),
              _newChildInput("Фамилия, Имя, Отчество, Дата Рождения"),
              SizedBox(
                height: 16.0,
              ),
              _confirmButton(),
              SizedBox(
                height: 16.0,
              ),
              _buildChildrenList(),
            ],
          ),
        )
    );
  }

  Form _newChildInput(String listOfNames){
    return Form(
      key: _formKey,
      child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
              color: Colors.black,
              style: BorderStyle.solid,
              width: 1.0,
            ),
            verticalInside: BorderSide(
              color: Colors.black,
              style: BorderStyle.solid,
              width: 1.0,
            ),
          ),
          children: [
            TableRow(
              children: listOfNames.split(',').map((name) {
                return Container(
                  child: Text(name, style: TextStyle(fontSize: 16.0)),
                  padding: EdgeInsets.all(4.0),
                );
              }).toList(),
            ),
            TableRow(
                children:  <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(hintText: 'Фамилия'),
                        validator: (val) => val.isEmpty ? 'Введите фамилию' : null,
                        onChanged: (val) {
                          setState(() => child.lastName = val);
                        }
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(hintText: 'Имя'),
                        validator: (val) => val.isEmpty ? 'Введите имя' : null,
                        onChanged: (val) {
                          setState(() => child.firstName = val);
                        }
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                        controller: middleNameController,
                        decoration: InputDecoration(hintText: 'Отчество'),
                        validator: (val) => val.isEmpty ? 'Введите отчество' : null,
                        onChanged: (val) {
                          setState(() => child.middleName = val);
                        }
                    ),
                  ),
                  isDate ? Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(child.birthDay),
                  ):
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime birth = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1940),
                        lastDate: DateTime.now(),
                      ).then((value){
                        child.birthDay = DateFormat("dd.MM.yyyy").format(value);
                        setState(() => isDate = true);
                      })
                          .catchError((err) => print(err) );
                    },
                  ),
                ]
            )
          ]
      ),
    );
  }

  Widget _confirmButton() =>
      RaisedButton(
          onPressed:  () async {
            if(_formKey.currentState.validate() && isDate == true){
              await DatabaseProvider.db.addChild(child,widget.parentId).then((_){
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text("Ребенок добавлен!"),
                  backgroundColor:Colors.green,
                ));
                setState(() {
                  middleNameController.clear();
                  firstNameController.clear();
                  lastNameController.clear();
                  isDate = false;
                });
              })
                  .catchError((err) => print(err));
            } else {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Вы ввели не все данные!"),
                backgroundColor:Colors.red,
              ));
            }
          },
          color: Colors.blue,
          child: Text(
            'Добавить ребенка',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ));

  Widget _buildChildrenList() {
    return FutureBuilder(
      future: DatabaseProvider.db.getChildren(widget.parentId),
      builder: (context, AsyncSnapshot<List<Child>> snapshot) {
        if(snapshot.hasData){
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildListItem(snapshot.data[index]);
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


  Widget _buildListItem(Child item) {
    return Table(
        border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.black,
            style: BorderStyle.solid,
            width: 1.0,
          ),
          verticalInside: BorderSide(
            color: Colors.black,
            style: BorderStyle.solid,
            width: 1.0,
          ),
        ),
        children: <TableRow>[
          TableRow(
            children: ("${item.lastName}, ${item.firstName}, ${item.middleName}, ${item.birthDay}").split(',').map((name) {
              return Container(
                alignment: Alignment.topCenter,
                child: Text(name, style: TextStyle(fontSize: 16.0)),
                padding: EdgeInsets.all(8.0),
              );
            }).toList(),
          ),
        ]
    );
  }



  @override
  void dispose() {
    middleNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}