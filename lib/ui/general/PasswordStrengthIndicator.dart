import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../core/PasswordStrength.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class PasswordStrengthIndicator extends StatefulWidget {
  PasswordStrengthIndicator({Key key, @required this.initialPassword}) : super(key: key);

  final String initialPassword;

  @override
  State<StatefulWidget> createState() => PasswordStrengthIndicatorState();
}

class PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator> {
  Entropizer entropizer = new Entropizer();

  int level = 0;
  Color strengthColor = Colors.red;
  Icon strengthIcon = Icon(MdiIcons.emoticonAngry);

  @override
  void initState() {
    onPasswordChange(widget.initialPassword);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LinearPercentIndicator(
        width: MediaQuery.of(context).size.width / 2,
        lineHeight: 14.0,
        percent: level / 100,
        center: Text(
          level.toString() + " bits",
          style: new TextStyle(fontSize: 12.0),
        ),
        trailing: strengthIcon,
        linearStrokeCap: LinearStrokeCap.roundAll,
        backgroundColor: Theme.of(context).primaryColor,
        progressColor: strengthColor,
      ),
    );
  }

  void onPasswordChange(String password) {
    double score = entropizer.evaluate(password);
    int bits = score.round();
        setState(() {
      if (bits <= 24) {
        strengthColor = Colors.red;
        strengthIcon = Icon(MdiIcons.emoticonAngry);
      }
      else if (bits <= 45) {
        strengthColor = Colors.orange;
        strengthIcon = Icon(MdiIcons.emoticonSad);
      }
      else if (bits <= 67) {
        strengthColor = Colors.yellow;
        strengthIcon = Icon(MdiIcons.emoticonNeutral);
      }
      else if ( bits <= 81) {
        strengthColor = Colors.lightGreen;
        strengthIcon = Icon(MdiIcons.emoticonHappy);
      }
      else {
        strengthColor = Colors.green;
        strengthIcon = Icon(MdiIcons.emoticonExcited);
      }
      
      if (bits > 100) {
        level = 100;
      } else {
        level = bits;
      }
    });   
  }
}
