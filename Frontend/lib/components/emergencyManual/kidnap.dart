import 'package:flutter/material.dart';

class EmergencyKidnap extends StatelessWidget {
  const EmergencyKidnap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Image.asset("assets/kidnap/유괴1.png"),
          Image.asset("assets/kidnap/유괴2.png"),
          Image.asset("assets/kidnap/유괴3.png"),
          Image.asset("assets/kidnap/유괴4.png"),
          Image.asset("assets/kidnap/유괴5.png"),
          Image.asset("assets/kidnap/유괴6.png"),
          Image.asset("assets/kidnap/유괴7.png"),
          Image.asset("assets/kidnap/유괴8.png"),
          Image.asset("assets/kidnap/유괴9.png"),
          Image.asset("assets/kidnap/유괴10.jpg"),
        ],
      ),
    );
  }
}
