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
  File justificativeFile;
  Image temp;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    absence = ModalRoute.of(context).settings.arguments;
  }

  void initState() {
    super.initState();
  }

  Future<void> _saveJustification() async {
    if (absence.absence.justification != null) {
      setState(() {
        loading = true;
      });
      try {
        print('${api.apiUrl}/etudiant/justification/${absence.id}');
        dynamic result = api.put('etudiant/justification/${absence.id}',
          {
            'justification' : absence.absence.justification
          }, api.authHeader
        );
      } catch (e) {
        print(e);
      }

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
          NamedCard(
            title: 'Raison',
            children: <Widget>[
              Padding(
                child: TextFormField(
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: "Raison",
                                  icon: const Icon(Icons.keyboard_arrow_right)),
                              textInputAction: TextInputAction.next,
                              onSaved: (String value) => absence.absence.justification = value,
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
