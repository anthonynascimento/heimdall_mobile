import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/model/_absenceseance.dart';
import 'package:heimdall/model/_matiere.dart';
import 'package:heimdall/model/_seance.dart';
import 'package:heimdall/model/class_group.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/etudiant.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import "package:http/http.dart" as http;

class RollCallForm extends StatefulWidget {
  @override
  State createState() => _RollCallFormState();
}

class _RollCallFormState extends Logged<RollCallForm> {
  List<ClassGroup> _classGroups = [];
  List<Matiere> _matieres = [];
  Matiere selectedMatiere;
  RollCall _rollCall = new RollCall();
  List<AbsenceSeance> liste = [];
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
    _rollCall.teacher = user;
    await _getClassGroups();
    await _getListeMatieres();
    setState(() {
      loading = false;
    });
  }

  _getClassGroups() async {
    List<ClassGroup> classGroups = await api.getClasses();
    setState(() {
      _classGroups = classGroups;
      if (_rollCall.classGroup != null) {
        _rollCall.classGroup = _classGroups.singleWhere((classGroup) => classGroup.id == _rollCall.classGroup.id);
      }
    });
  }

  _getListeMatieres() async {
    List<Matiere> listeMat = await api.getMatieres();
    print(listeMat);
    setState(() {
      _matieres = listeMat;
    });
  }

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

  List<DropdownMenuItem<Matiere>> get _matieresDropdown {
    List<DropdownMenuItem<Matiere>> items = new List();
    for (Matiere mat in _matieres) {
      items.add(new DropdownMenuItem(
          value: mat,
          child: new Text(mat.titre)
      ));
    }
    return items;
  }

  _onClassGroupChanged(ClassGroup classGroup) async {
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
  }

  _onMatiereChanged(Matiere mat) async {
    setState(() {
      selectedMatiere = mat;
    });
    setState(() {
    });
  }

  _save() async {
      String urlCreationSeance =  '${api.apiUrl}/absence/seance/creation';
      String urlCreationAbsence =  '${api.apiUrl}/absence/creation';
      Map<String,String> headers = {"Authorization": "token ${api.userToken}"};
      Map<String,String> headersPost = {"Content-Type":"application/json","Authorization": "token ${api.userToken}"};
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      DateFormat timeFormat = DateFormat("HH:mm");
      String dateF = dateFormat.format(DateTime.now());
      String hDebF = timeFormat.format(_rollCall.dateStart);
      String hFinF = timeFormat.format(_rollCall.dateEnd);
      //Pour la création de séance
      Map<String,String> bodySeance = {
        "date":dateF,
        "heure_deb":hDebF,
        "heure_fin":hFinF,
        "id_promo":_rollCall.classGroup.id.toString(),
        "id_matiere":selectedMatiere.id.toString()};
      try {
                http.Response response = await http.post('${api.apiUrl}/absence/seance/creation',
        headers: headers,
        body: bodySeance)
        .timeout(Duration(seconds: 10), onTimeout: () {
          throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
        }
        );

        final responseSeances = await http.get(
          '${api.apiUrl}/absence/professeur/seances',
          headers: headers);

        if (responseSeances.statusCode == 200) {
        // If the server did return a 200 OK response, then parse the JSON.
          List<Seance> seances = List<Seance>.from(json.decode(responseSeances.body).map((x) => Seance.fromJson(x)));
          Seance sean;
          for(Seance se in seances) {
            if(se.dateSeance==dateF && se.heureDebBonFormat()==hDebF && se.heureFinBonFormat()==hFinF) {
              print(se.dateSeance+"-"+dateF);
              sean = se;
            }
          }
          int idSeance = sean.id;

          for(StudentPresence unePresence in _rollCall.studentPresences) {
            if(unePresence.present == false || unePresence.lateDuration.inMinutes > 0) {
              //etudiantsAbsents.add(unePresence);
              print(_rollCall.classGroup.id);
              Map<String,String> bodyAbs = {
                "absence":toBeginningOfSentenceCase((!unePresence.present).toString()),
                "retard":unePresence.lateDuration.inMinutes.toString(),
                "id_seance":idSeance.toString(),
                "id_etudiant":unePresence.student.id.toString()
              };
              print(bodyAbs);
              print(headersPost);
              http.Response response = await http.post('${api.apiUrl}/absence/creation',
                headers: headers,
                body: bodyAbs)
                .timeout(Duration(seconds: 10), onTimeout: () {
                   throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
                }
              );
              print(response.statusCode);
            }
          }
        }
        Navigator.pop(context);
      } catch (e) {
        showSnackBar(SnackBar(
          content: Text('Erreur, impossible de sauvegarder !'),
          backgroundColor: Colors.red
      ));
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
  }

  @override
  Widget getBody() {
    final TextStyle hourStyle = new TextStyle(fontSize: 20, color: Theme.of(context).accentColor);
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
                        FlatButton(
                          child: Text(_rollCall.startAt.format(context), style: hourStyle),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _rollCall.startAt,
                            );
                            if (time != null) {
                              setState(() {
                                _rollCall.startAt = time;
                              });
                            }
                          },
                        ),
                        Padding(padding: EdgeInsets.only(left: 10), child: Text('à')),
                        Padding(padding: EdgeInsets.only(left: 10), child:
                        FlatButton(
                          child: Text(_rollCall.endAt.format(context), style: hourStyle),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _rollCall.endAt,
                            );
                            if (time != null) {
                              setState(() {
                                _rollCall.endAt = time;
                              });
                            }
                          },
                        ),),
                      ],
                    ),
                    Padding(
                      child: DropdownButton<ClassGroup>(
                        isExpanded: true,
                        hint: Text('Choisissez une classe'),
                        items: _classGroupsDropdown,
                        value: _rollCall.classGroup,
                        onChanged: _onClassGroupChanged,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                                        Padding(
                      child: DropdownButton<Matiere>(
                        isExpanded: true,
                        hint: Text('Choisissez une matière'),
                        items: _matieresDropdown,
                        value: selectedMatiere,
                        onChanged: _onMatiereChanged,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    )
                  ],
                ),
              ),
              Expanded(
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
              ),
        SizedBox(
            width: double.infinity,
            child: RaisedButton(
                  child: Text('Confirmer et enregistrer'),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  onPressed: _save
              ))
            ]
        )
    );
  }

}