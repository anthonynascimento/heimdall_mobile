import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:heimdall/model/_absencetudiant.dart';
import 'package:heimdall/model/student_presence.dart';
import 'package:heimdall/ui/components/named_card.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import "package:http/http.dart" as http;

class Justify extends StatefulWidget {
  @override
  State createState() => _JustifyState();
}
class _JustifyState extends Logged<Justify> {
  AbsenceEtudiant absence;
  bool includeBaseContainer = false;
  String justification;
  final motifController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    absence = ModalRoute.of(context).settings.arguments;
  }

  void initState() {
    super.initState();
  }

  Future<void> _saveJustification() async {
    print(motifController.text);

    if (motifController.text != "") {

      setState(() {
        loading = true;
      });
      try {
        String url = '${api.apiUrl}/absence/etudiant/justification/${absence.id}';
        print(url);
    Map<String,String> body = {"justification": motifController.text};
    Map<String,String> headers = { "Accept" : "application/json", "Authorization": "token ${api.userToken}"};
    print(body);
    print(headers);
      http.put(Uri.encodeFull(url), body: body , headers: headers).then((result) {
        print(result.statusCode);
        print(result.body);
        });
      } catch (e) {
        print(e);
      }
      showSnackBar(SnackBar(content: Text('Insertion faite'), backgroundColor: Colors.green));
      Navigator.pop(context);
      /*if (returnedPresence != null) {
        Navigator.pop(context, returnedPresence);
      } else {
        setState(() {
          loading = false;
        });
        showSnackBar(SnackBar(content: Text('Erreur lors de l\'enregistrement !'), backgroundColor: Colors.red));
      }*/
    } else {
      showSnackBar(SnackBar(content: Text('Renseignez une raison '), backgroundColor: Colors.red));
    }
  }

  @override
  Widget getBody() {
    return Padding(
        padding: EdgeInsets.only(top: 20, left: 5, right: 5),
        child: Column(children: <Widget>[
          Text("${absence.absence.typeAbsence()}", style: TextStyle(fontSize: 30.0),),
          Text("${absence.seance.dateBonFormat()}", style: TextStyle(fontSize: 15.0),),
          Text("Séance de ${absence.seance.heureDebBonFormat()} à ${absence.seance.heureFinBonFormat()}"),
          Text(absence.absence.retard!=0 ?"Retard de ${absence.absence.retard} min" : ""),
          
          NamedCard(
            title: 'Raison',
            children: <Widget>[
              Padding(
                child: TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  icon: const Icon(Icons.keyboard_arrow_right)),
                              controller: motifController,
                            ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              )
            ],
          ),
          
          SizedBox(
              width: double.infinity,
              child: RaisedButton(
                  child: Text('Valider'),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: Theme
                      .of(context)
                      .accentColor,
                  textColor: Colors.white,
                  onPressed: _saveJustification
                  )
              )
        ]));
  }
}
