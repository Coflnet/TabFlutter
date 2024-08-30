import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_entry/pages/main/newRecognizedData.dart';

class newVoiceDataNotifer extends ChangeNotifier {
  late _RecognizedDataState lbState;

  void setState(_RecognizedDataState state) {
    lbState = state;
  }

  void newVoiceData(List newVoiceData) {
    lbState.addNewData(newVoiceData);
  }
}

class RecognizedData extends StatefulWidget {
  const RecognizedData({Key? key}) : super(key: key);

  @override
  _RecognizedDataState createState() => _RecognizedDataState();
}

class _RecognizedDataState extends State<RecognizedData> {
  List recognizedNoise = [];

  @override
  Widget build(BuildContext context) {
    Provider.of<newVoiceDataNotifer>(context, listen: false).setState(this);
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            itemCount: recognizedNoise.length,
            itemBuilder: (context, index) {
              return NewRecognizedData(data: recognizedNoise[index]);
            }));
  }

  void addNewData(List newVoiceData) {
    setState(() {
      recognizedNoise.add(newVoiceData);
    });
  }
}
