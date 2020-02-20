import 'package:flutter/material.dart';
import 'package:heimdall/model/_seance.dart';
import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/ui/pages/logged.dart';

class UpdateRollCallForm extends StatefulWidget {
  @override
  State createState() => _UpdateRollCallFormState();
}

class _UpdateRollCallFormState extends Logged<UpdateRollCallForm> {
  List<ClassGroup> _classGroups = [];
  Seance _rollCall = new Seance();
  bool includeBaseContainer = false;
  bool _loadingStudents = false;
  bool _isUpdate = false;
  bool _draftLoadAsked = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context).settings.arguments != null) {
      _rollCall = ModalRoute.of(context).settings.arguments;
      _isUpdate = true;
    }
    if (!_isUpdate && !_draftLoadAsked) {
      _draftLoadAsked = true;
      setState(() {
        loading = true;
      });
      setState(() {
        loading = false;
      });
    }
  }

  _init() async {
    setState(() {
      loading = true;
    });
    //_rollCall.teacher = user;
    //await _getClassGroups();
    setState(() {
      loading = false;
    });
  }

  /*_getClassGroups() async {
    List<ClassGroup> classGroups = await api.getClasses();
    setState(() {
      _classGroups = classGroups;
      if (_rollCall.classGroup != null) {
        _rollCall.classGroup = _classGroups.singleWhere((classGroup) => classGroup.id == _rollCall.classGroup.id);
      }
    });
  }*/

  List<DropdownMenuItem<ClassGroup>> get _classGroupsDropdown {
    List<DropdownMenuItem<ClassGroup>> items = new List();
    for (ClassGroup classGroup in _classGroups) {
      items.add(new DropdownMenuItem(
          value: classGroup,
          child: new Text(classGroup.nompromotion)
      ));
    }
    return items;
  }

  /*List<Etudiant> recupererAbsences() {
    List<Etu
  }*/

  /*_onClassGroupChanged(ClassGroup classGroup) async {
    setState(() {
      _rollCall.classGroup = classGroup;
      _loadingStudents = true;
    });
    List<Etudiant> students = await api.getStudentsInClass(classGroup.id);
    List<StudentPresence> presences = new List<StudentPresence>();
    for (Etudiant student in students) {
      print(student.type);
      presences.add(new StudentPresence(student: student, present: true));
    }
    setState(() {
      _rollCall.studentPresences.clear();
      _rollCall.studentPresences.addAll(presences);
      _loadingStudents = false;
    });
  }*/

  /*_save() async {
    if (_rollCall.classGroup == null || _rollCall.studentPresences.isEmpty) {
      showSnackBar(SnackBar(
          content: Text('La classe est vide !'),
          backgroundColor: Colors.red
      ));
      return;
    }
    setState(() {
      loading = true;
    });
    RollCall rollcall;
    try {
      if (_isUpdate) {
        rollcall = await api.updateRollCall(_rollCall);
      } else {
        rollcall = await api.createRollCall(_rollCall);
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
      showSnackBar(SnackBar(
          content: Text('Erreur, impossible de sauvegarder !'),
          backgroundColor: Colors.red
      ));
    }
    if (rollcall != null) {
      setState(() {
        loading = false;
      });
      Navigator.of(context).pop(rollcall);
    }
  }

  Color _getPresenceColor(StudentPresence studentPresence, double opacity) {
      if (studentPresence.present == false) {
        return Color.fromRGBO(200, 0, 0, opacity);
      } else if (studentPresence.lateDuration.inMinutes > 0) {
        return Color.fromRGBO(255, 150, 0, opacity);
      }
      return Color.fromRGBO(0, 150, 0, opacity);
  }

  _askLateDuration(StudentPresence studentPresence) async {
    Duration duration = await showDurationPicker(
      context: context,
      initialTime: studentPresence.lateDuration,
      snapToMins: 5.0,
    );
    if (duration != null) {
      if (_rollCall.diff.compareTo(duration) > 0) {
        setState(() {
          studentPresence.present = true;
          studentPresence.lateDuration = duration;
        });
      } else {
        showSnackBar(SnackBar(
            content: Text('Durée de retard invalide !'),
            backgroundColor: Colors.red
        ));
      }
    }
  }

  _togglePresent(StudentPresence studentPresence) {
    setState(() {
      // Reset duration
      if (studentPresence.lateDuration != Duration()) {
        studentPresence.lateDuration = Duration();
      }
      studentPresence.present = !studentPresence.present;
    });
  }

  Widget _getStudentPresenceStatus(StudentPresence studentPresence) {
    if (studentPresence.lateDuration != Duration()) {
      return Align(
          child: Chip(
              label: Text('Retard de ${studentPresence.lateDuration.inMinutes
                  .toString()} minutes'),
              backgroundColor: _getPresenceColor(studentPresence, 0.7)
          ),
          alignment: Alignment.topLeft
      );
    }
    return Align(
        child: Chip(
          label: Text(studentPresence.present ? 'Présent.e' : 'Absent.e'),
          backgroundColor: _getPresenceColor(studentPresence, 0.7),
        ),
        alignment: Alignment.topLeft
    );
  }*/

  @override
  Widget getBody() {
    //final TextStyle hourStyle = new TextStyle(fontSize: 20, color: Theme.of(context).accentColor);
    return Padding(
        padding: EdgeInsets.only(top: 20, left: 5, right: 5),
        child: Column(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(left: 10), child:
                        Text(_rollCall.heureDebBonFormat(), style: TextStyle(fontSize: 40.0))
                        ),
                        Padding(padding: EdgeInsets.only(left: 10), child: Text('à')),
                        Padding(padding: EdgeInsets.only(left: 10), child:
                        Text(_rollCall.heureFinBonFormat(), style: TextStyle(fontSize: 40.0))
                        ),
                      ],
                    ),
                    /*Padding(
                      child: DropdownButton<ClassGroup>(
                        isExpanded: true,
                        hint: Text('Choisissez une classe'),
                        items: _classGroupsDropdown,
                        value: _rollCall.classGroup,
                        onChanged: _onClassGroupChanged,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    )*/
                  ],
                ),
              ),
              /*Expanded(
                  child: Card(
                      child: _loadingStudents ? Center(child: Stack(
                          children: <Widget>[CircularProgressIndicator()]))
                          : _rollCall.studentPresences.length == 0 ? Center(
                          child: Text(_rollCall.classGroup == null
                              ? "En attente d'une sélection de classe..."
                              : "Cette classe n'a aucun élève.")
                           )
                          : ListView.builder(
                          itemCount: _rollCall.studentPresences.length,
                          itemBuilder: (BuildContext context, int index) {
                            StudentPresence studentPresence = _rollCall
                                .studentPresences[index];
                            return Ink(
                              color: _getPresenceColor(
                                  _rollCall.studentPresences[index], 0.1),
                              child: ListTile(
                                title: Text(
                                  studentPresence.student.fullNameReversed,
                                  style: TextStyle(fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: _getStudentPresenceStatus(
                                    studentPresence),
                                contentPadding: EdgeInsets.only(left: 15,
                                    right: 10,
                                    bottom: 38,
                                    top: 5),
                                dense: true,
                                trailing: IconButton(
                                  icon: Icon(Icons.access_time),
                                  onPressed: () =>
                                      _askLateDuration(studentPresence),
                                ),
                                onTap: () => _togglePresent(studentPresence),
                              ),
                            );
                          }
                      )
                  )
              ),*/
        SizedBox(
            width: double.infinity,
            child: RaisedButton(
                  child: Text('Confirmer et enregistrer'),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  //onPressed: _save
              ))
            ]
        )
    );
  }

}