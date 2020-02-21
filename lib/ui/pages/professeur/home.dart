import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heimdall/model/_matiere.dart';
import 'package:heimdall/model/_seance.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {
  List<Seance> _rollCalls = [];
  List<Matiere> _matieres = List<Matiere>();
  bool includeBaseContainer = false;
  RefreshController _refreshController = RefreshController(initialRefresh:false);

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    super.initState();
    _getRollCalls();
  }


  /*void _getRollCalls() async {
    await initializeDateFormatting('fr_FR', null);
    List<Seance> rollCalls = await api.getRollCalls();
      setState(() {
        _rollCalls = rollCalls;
        loading = false;
      });
  }*/

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
    api.idseance = rollcall.id;
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

    ListTile _buildItemsForListView(BuildContext context, int index) {
    return ListTile(
            title: Text("${_rollCalls[index].dateBonFormat()} (${_matieres[index].titre})"),
            subtitle: Text("${_rollCalls[index].heureDebBonFormat()} à ${_rollCalls[index].heureFinBonFormat()}"),
            trailing: Chip(label: Text('Accéder'), backgroundColor: Color.fromRGBO(255, 150, 0, 0.7)),
            //onTap: () => null,
            onTap:  () => _showUdpateRollcallForm(_rollCalls[index]),            
            /*trailing: _rollCalls[index].isPassed ? Chip(label: Text('Terminé'), backgroundColor: Color.fromRGBO(0, 150, 0, 0.7)) : Chip(label: Text('En cours'), backgroundColor: Color.fromRGBO(255, 150, 0, 0.7)),
            onTap: _rollCalls[index].isPassed ? null : () => _showRollcallForm(_rollCalls[index]),*/
          );
  }

  void _getRollCalls() async {
    await initializeDateFormatting('fr_FR', null);
    List<Seance> rollCalls = await api.getRollCalls();
    List<Matiere> listeMat = [];
    for(Seance se in rollCalls) {
      listeMat.add(await api.getMatiereAppel(se.id));
    }
    if(mounted)
    setState(() {
      _rollCalls = rollCalls;
      _matieres = listeMat;
      loading = false;
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget getBody() {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _getRollCalls,
        controller: _refreshController,
        child: ListView.builder(
        itemCount: _rollCalls.length,
        itemBuilder: _buildItemsForListView
    ),

      ),
    );

  }

}