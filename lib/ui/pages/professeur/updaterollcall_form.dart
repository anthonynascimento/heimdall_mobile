import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heimdall/model/_absenceetudiant.dart';
import 'package:heimdall/model/_absenceseance.dart';
import 'package:heimdall/model/_matiere.dart';
import 'package:heimdall/model/_seance.dart';
import 'package:heimdall/model/class_group.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:heimdall/exceptions/api_connect.dart';
import 'package:heimdall/model/rollcall.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/pages/logged.dart';
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';

class UpdateRollCallForm extends StatefulWidget {
  @override
  State createState() => _UpdateRollCallFormState();
}

class _UpdateRollCallFormState extends Logged<UpdateRollCallForm> {
  List<ClassGroup> _classGroups = [];
  List<Matiere> _matieres = [];
  int id;
  Matiere selectedMatiere;
  Seance _rollCall = new Seance();
  List<AbsenceEtudiant> listeEtudiantsAbs = [];
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
      print(_rollCall.id);
      id = _rollCall.id;
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
    selectedMatiere = await api.getMatiereAppel(api.idseance);
    print(selectedMatiere.titre);
    setState(() {
      loading = true;
    });
    await _getListeEtudiantsAbsents();
    setState(() {
      loading = false;
    });
  }

  _getListeEtudiantsAbsents() async {
    List<AbsenceEtudiant> listeEtu = await api.getAbsencesDurantSeance(api.idseance);
    print(listeEtu);
    print(listeEtu);
    setState(() {
      listeEtudiantsAbs = listeEtu;
    });
  }




  Color _getPresenceColor(AbsenceEtudiant studentAbs, double opacity) {
      if (studentAbs.absence.absent == true) {
        return Color.fromRGBO(200, 0, 0, opacity);
      } else if (studentAbs.absence.retard > 0) {
        return Color.fromRGBO(255, 150, 0, opacity);
      }
      return Color.fromRGBO(0, 150, 0, opacity);
  }

  _askLateDuration(AbsenceEtudiant abs) async {
    Duration duration = await showDurationPicker(
      context: context,
      initialTime: Duration(minutes: abs.absence.retard),
      snapToMins: 5.0,
    );
    if (duration != null) {
      if (abs.absence.retard - duration.inMinutes != 0) {
        setState(() {
                    abs.absence.absent = false;
          abs.absence.retard = duration.inMinutes;
        });

      } else {
        showSnackBar(SnackBar(
            content: Text('Durée de retard invalide !'),
            backgroundColor: Colors.red
        ));
      }
    }
  }

  _togglePresent(AbsenceEtudiant studentAbs) {
    setState(() {
      // Reset duration
      if (studentAbs.absence.retard>0) {
        studentAbs.absence.retard = Duration().inMinutes;
      }
      studentAbs.absence.absent = !studentAbs.absence.absent;
    });
  }

  Widget _getStudentPresenceStatus(AbsenceEtudiant studentAbs) {
    if (studentAbs.absence.retard > 0) {
      return Align(
          child: Chip(
              label: Text('Retard de ${studentAbs.absence.retard
                  .toString()} minutes'),
              backgroundColor: _getPresenceColor(studentAbs, 0.7)
          ),
          alignment: Alignment.topLeft
      );
    }
    return Align(
        child: Chip(
          label: Text(studentAbs.absence.absent ? 'Absent.e' : 'Présent.e'),
          backgroundColor: _getPresenceColor(studentAbs, 0.7),
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
                    selectedMatiere!= null ?Text("Séance de ${selectedMatiere.titre} du ${_rollCall.dateBonFormat()}", style: hourStyle,)
                    : Text("Séance du ${_rollCall.dateBonFormat()}", style: hourStyle,)
                    ,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                         Text(_rollCall.heureDebBonFormat(), style: hourStyle),
                         Text('    à '),
                        Padding(padding: EdgeInsets.only(left: 10), child:
                        Text(_rollCall.heureFinBonFormat(), style: hourStyle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Card(
                      child: ListView.builder(
                          itemCount: listeEtudiantsAbs.length,
                          itemBuilder: (BuildContext context, int index) {
                            AbsenceEtudiant studentPresence = listeEtudiantsAbs[index];
                            //return Text("${studentPresence.etudiant.id}");
                            return Ink(
                              color: _getPresenceColor(
                                  listeEtudiantsAbs[index], 0.1),
                              child: ListTile(
                                title: Text(
                                  studentPresence.etudiant.fullName,
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

  void _save() async {
    try {
      for(AbsenceEtudiant abs in listeEtudiantsAbs) {
        Map<String,String> headers = {"Authorization": "token ${api.userToken}"};
        Map<String, String> bodyModif = {
          "absence":toBeginningOfSentenceCase(abs.absence.absent.toString()),
          "retard":abs.absence.retard.toString()
          };
        print(abs.absence.retard.toString()+" min et absence ="+abs.absence.absent.toString());
        print(abs.absence.id);
        http.Response response = await http.put('${api.apiUrl}/absence/${abs.absence.id}',
          headers: headers,
          body: bodyModif)
          .timeout(Duration(seconds: 10), onTimeout: () {
            throw new ApiConnectException(type: ApiConnectExceptionType.timeout);
          }
          );
          print(response.statusCode);
      }
     Navigator.pop(context);
      } catch (e) {
        showSnackBar(SnackBar(
          content: Text('Erreur, impossible de sauvegarder !'),
          backgroundColor: Colors.red
      ));
      }
  }
}