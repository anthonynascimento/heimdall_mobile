import 'package:flutter/material.dart';
import 'package:heimdall/model/_absencetudiant.dart';
import 'package:heimdall/ui/pages/logged.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  @override
  State createState() => _HomeState();
}

class _HomeState extends Logged<Home> {

  List<AbsenceEtudiant> _studentPresences = List<AbsenceEtudiant>();
  bool includeBaseContainer = false;
  RefreshController _refreshController = RefreshController(initialRefresh:false);

  void initState() {
    super.initState();
    _getPresence();
  }

  void _getPresence() async {
    await initializeDateFormatting('fr_FR', null);
    List<AbsenceEtudiant> studentPresences = await api.getStudentPresences();
    if(mounted)
    setState(() {
      _studentPresences = studentPresences;
      loading = false;
    });
    _refreshController.refreshCompleted();
  }

  Widget _getPresenceValidationStatus(AbsenceEtudiant studentPresence) {
    String label = 'Justificatif refusé';
    Color color = Color.fromRGBO(250, 0, 0, 0.7);

    //a justifier : rouge
    if (studentPresence.absence.justification == "" || studentPresence.absence.justification == null) {
      label = 'A justifier';
      color = Color.fromRGBO(250, 0, 0, 0.7);
    }
    /*//en attente de validation : orange
    else if (studentPresence.excuseValidated == null && studentPresence.excuseProof != null) {
      label = 'En attende de validation';
      color = Color.fromRGBO(250, 150, 0, 0.7);
    }*/
    //validé : vert
    else if (studentPresence.absence.justification != "" || studentPresence.absence.justification != null) {
      label = 'Justifiée';
      color = Color.fromRGBO(0, 150, 0, 0.7);
    }

    return Chip(
      label: Text(label),
      backgroundColor: color,
    );
  }

  _showPresence(int index) async {
    dynamic returnedPresence = await Navigator.pushNamed(context, '/etudiant/justify', arguments: _studentPresences[index]);
    if (returnedPresence != null) {
      showSnackBar(SnackBar(
        content: Text("La justification a été envoyée."),
        backgroundColor: Colors.lightGreen,
      ));
      setState(() {
        _studentPresences[index] = returnedPresence;
      });
    }
  }

  ListTile _buildItemsForListView(BuildContext context, int index) {
    return ListTile(
      title: Text((_studentPresences[index].absence.absent ? "Absence" : "Retard")),
      subtitle: _studentPresences[index].absence.absent ? Text("${_studentPresences[index].seance.dateBonFormat()} (${_studentPresences[index].seance.heureDebBonFormat()}-${_studentPresences[index].seance.heureFinBonFormat()})")
       : Text("${_studentPresences[index].absence.retard} min le ${_studentPresences[index].seance.dateSeance}"),
      trailing: _getPresenceValidationStatus(_studentPresences[index]),
      onTap: _studentPresences[index].absence.justification == null || _studentPresences[index].absence.justification == ""
         ? () => _showPresence(index)
          : null,
    );
  }


  @override
  Widget getBody() {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _getPresence,
        controller: _refreshController,
        child: ListView.builder(
            itemCount: _studentPresences.length,
            itemBuilder: _buildItemsForListView
        ),

      ),
    );
  }


}