import 'package:flutter/material.dart';

class NamedCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  NamedCard({this.title, this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          child: Text(title, style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).primaryColor,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 5,
                color: Colors.grey,
              ),
            ],
          ),),
          padding: EdgeInsets.only(left: 10, top: 10),
        ),
        Card(
          margin: EdgeInsets.only(bottom: 10, left: 4, right: 4, top: 4),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }


}