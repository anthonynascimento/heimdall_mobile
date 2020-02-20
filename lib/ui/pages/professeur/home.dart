import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heimdall/model/_seance.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:intl/date_symbol_data_local.dart';


class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {
  List<Seance> _rollCalls = [];
  bool includeBaseContainer = false;

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    super.initState();
    _getRollCalls();
  }


  void _getRollCalls() async {
    await initializeDateFormatting('fr_FR', null);
    List<Seance> rollCalls = await api.getRollCalls();
      setState(() {
        _rollCalls = rollCalls;
        loading = false;
      });
  }

  void _showRollcallForm([Seance rollcall]) async {
    dynamic returnedRollcall = await Navigator.of(context).pushNamed('/professeur/rollcall', arguments: rollcall);
    if (returnedRollcall != null) {
      showSnackBar(SnackBar(
        content: Text("L'appel a bien été enregistré."),
        backgroundColor: Colors.lightGreen,
      ));
      int rollcallKey = _rollCalls.indexWhere((rollcall) => rollcall.id == returnedRollcall.id);
      print(rollcallKey);
      if (rollcallKey == -1) {
        setState(() {
          _rollCalls.insert(0, returnedRollcall);
        });
      } else {
        setState(() {
          _rollCalls[rollcallKey] = returnedRollcall;
        });
      }
    }
  }

  void _showUdpateRollcallForm([Seance rollcall]) async {
    dynamic returnedRollcall = await Navigator.of(context).pushNamed('/professeur/updaterollcall', arguments: rollcall);
    if (returnedRollcall != null) {
      showSnackBar(SnackBar(
        content: Text("L'appel a bien été enregistré."),
        backgroundColor: Colors.lightGreen,
      ));
      int rollcallKey = _rollCalls.indexWhere((rollcall) => rollcall.id == returnedRollcall.id);
      print(rollcallKey);
      if (rollcallKey == -1) {
        setState(() {
          _rollCalls.insert(0, returnedRollcall);
        });
      } else {
        setState(() {
          _rollCalls[rollcallKey] = returnedRollcall;
        });
      }
    }
  }

  @override
  Widget getFloatingButton() {
    return FloatingActionButton(
      child: Icon(FontAwesomeIcons.tasks),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Theme.of(context).textTheme.title.color,
      onPressed: _showRollcallForm,
    );
  }

  @override
  Widget getBody() {
    return ListView.builder(
        itemCount: _rollCalls.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_rollCalls[index].dateSeance),
            subtitle: Text("${_rollCalls[index].dateStart} à ${_rollCalls[index].dateEnd}"),
            trailing: Chip(label: Text('Accéder'), backgroundColor: Color.fromRGBO(255, 150, 0, 0.7)),
            //onTap: () => null,
            onTap:  () => _showUdpateRollcallForm(_rollCalls[index]),            
            /*trailing: _rollCalls[index].isPassed ? Chip(label: Text('Terminé'), backgroundColor: Color.fromRGBO(0, 150, 0, 0.7)) : Chip(label: Text('En cours'), backgroundColor: Color.fromRGBO(255, 150, 0, 0.7)),
            onTap: _rollCalls[index].isPassed ? null : () => _showRollcallForm(_rollCalls[index]),*/
          );
        }
    );
  }

}