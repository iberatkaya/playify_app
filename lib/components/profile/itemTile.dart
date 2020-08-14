import 'package:flutter/material.dart';

class ItemTile extends StatelessWidget {
  ItemTile({@required this.title, @required this.icon, @required this.fn});
  final String title;
  final Widget icon;
  final Function fn;
  final TextStyle listTileTextStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Text(
          title,
          style: listTileTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
        leading: icon,
        onTap: fn,
      ),
    );
  }
}
