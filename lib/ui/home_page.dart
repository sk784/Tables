import 'package:employeers/data/database.dart';
import 'package:employeers/data/employer.dart';
import 'package:employeers/ui/children_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Employer employer;
  TextEditingController lastNameController;
  TextEditingController firstNameController;
  TextEditingController middleNameController;
  TextEditingController positionController;
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
    employer = Employer();
    lastNameController = TextEditingController();
    firstNameController = TextEditingController();
    middleNameController = TextEditingController();
    positionController = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Работники'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 16.0,
              ),
              _newEmployerInput("Id, Фамилия, Имя, Отчество, Дата Рождения, Должность, Количество детей"),
              SizedBox(
                height: 16.0,
              ),
              _confirmButton(),
              SizedBox(
                height: 16.0,
              ),
              _buildEmployersList(),
            ],
          ),
        )
    );
  }

  Form _newEmployerInput(String listOfNames){
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
                  alignment: Alignment.center,
                  child: Text(name, style: TextStyle(fontSize: 14.0)),
                  padding: EdgeInsets.all(4.0),
                );
              }).toList(),
            ),
            TableRow(
                children:  <Widget>[
                  Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(hintText: 'Фамилия'),
                        validator: (val) => val.isEmpty ? 'Введите фамилию' : null,
                        onChanged: (val) {
                          setState(() => employer.lastName = val);
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
                          setState(() => employer.firstName = val);
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
                          setState(() => employer.middleName = val);
                        }
                    ),
                  ),
                  isDate ? Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(employer.birthDay),
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
                        employer.birthDay = DateFormat("dd.MM.yyyy").format(value);
                        setState(() => isDate = true);
                      })
                          .catchError((err) => print(err) );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                        controller: positionController,
                        decoration: InputDecoration(hintText: 'Должность'),
                        validator: (val) => val.isEmpty ? 'Введите должность' : null,
                        onChanged: (val) {
                          setState(() => employer.position = val);
                        }
                    ),
                  ),
                  Container()
                ]
            )
          ]
      ),
    );
  }

  Widget _confirmButton() =>
      RaisedButton(
          onPressed:  () async {
            (_formKey.currentState.validate() && isDate == true)
                ?
            await DatabaseProvider.db.addEmployer(employer).then((_){
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text("Работник добавлен!"),
                backgroundColor:Colors.green,
              ));
              setState(() {
                middleNameController.clear();
                firstNameController.clear();
                lastNameController.clear();
                positionController.clear();
                isDate = false;
              });
            })
                .catchError((err) => print(err))
                :
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text("Вы ввели не все данные!"),
              backgroundColor:Colors.red,
            ));
          },
          color: Colors.blue,
          child: Text(
            'Добавить работника',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
      );


  Widget _buildEmployersList() {
    return FutureBuilder(
      future: DatabaseProvider.db.getEmployers(),
      builder: (context, AsyncSnapshot<List<Employer>> snapshot) {
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


  Widget _buildListItem(Employer item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                ChildrenPage(
                  parentId: item.id,
                ),
          ),
        );
      },
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
          children: <TableRow>[
               TableRow(
                 children: ("${item.id},${item.firstName}, ${item.lastName}, ${item.middleName}, ${item.birthDay}, ${item.position},${item.children!=null?item.children:"0"}").split(',').map((name) {
                   return Container(
                     alignment: Alignment.topCenter,
                     child: Text(name, style: TextStyle(fontSize: 14.0)),
                     padding: EdgeInsets.all(6.0),
                   );
                 }).toList(),
               ),
              ]
      ),
    );
  }

  @override
  void dispose() {
    middleNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    positionController.dispose();
    super.dispose();
  }
}