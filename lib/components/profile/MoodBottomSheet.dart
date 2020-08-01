import 'package:flutter/material.dart';
import 'package:playify_app/components/profile/moodList.dart';
import 'package:playify_app/utilities/moodUtility.dart';
import 'package:toast/toast.dart';

Future showBottomToSaveMood(
    BuildContext context, Function getCurrentMood) async {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Select Your MOOD!",
                  textScaleFactor: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    ListTile(
                      onLongPress: () {
                        Toast.show("Why Not to Be Happy :)", context);
                      },
                      onTap: () async {
                        Toast.show("Happpy Mood!", context);
                        await saveMood("Happy");
                        getCurrentMood();
                        Navigator.of(context).pop();
                      },
                      leading: HappyMood().moodIcon,
                      title: Text(
                        HappyMood().moodText,
                        style: TextStyle(color: HappyMood().moodTextColor),
                      ),
                    ),
                    ListTile(
                      onLongPress: () {
                        Toast.show("Not Sure", context);
                      },
                      onTap: () async {
                        Toast.show("We Know How If Feels!", context);
                        await saveMood("Sad");
                        getCurrentMood();
                        Navigator.of(context).pop();
                      },
                      leading: SadMood().moodIcon,
                      title: Text(
                        SadMood().moodText,
                        style: TextStyle(color: SadMood().moodTextColor),
                      ),
                    ),
                    ListTile(
                      onLongPress: () {
                        Toast.show("Step UPP!", context);
                      },
                      onTap: () async{
                        Toast.show("High Energyy, Love That!", context);
                        await saveMood("Energetic");
                        getCurrentMood();
                        Navigator.of(context).pop();
                      },
                      leading: EnergeticMood().moodIcon,
                      title: Text(
                        EnergeticMood().moodText,
                        style: TextStyle(color: EnergeticMood().moodTextColor),
                      ),
                    ),
                    ListTile(
                      onLongPress: () {
                        Toast.show("Dont Wakeee me Upp!", context);
                      },
                      onTap: () async{
                        Toast.show("Go to Bed!", context);
                        await saveMood("Sleepy");
                        getCurrentMood();
                        Navigator.of(context).pop();
                      },
                      leading: SleepyMood().moodIcon,
                      title: Text(
                        SleepyMood().moodText,
                        style: TextStyle(color: SleepyMood().moodTextColor),
                      ),
                    ),
                    ListTile(
                      onLongPress: () {
                        Toast.show("Wish All Your Days Be Like", context);
                      },
                      onTap: () async{
                        Toast.show("Enjoyying!", context);
                        await saveMood("Joyful");
                        getCurrentMood();
                        Navigator.of(context).pop();
                      },
                      leading: JoyfulMood().moodIcon,
                      title: Text(
                        JoyfulMood().moodText,
                        style: TextStyle(color: JoyfulMood().moodTextColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}
