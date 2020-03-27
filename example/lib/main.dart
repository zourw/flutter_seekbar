import 'package:flutter/material.dart';
import 'package:seekbar/seekbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _thumbSize = 8.0;

  @override
  Widget build(BuildContext context) =>
      MaterialApp(
        home: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.red,
                    margin: EdgeInsets.only(bottom: _thumbSize),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SeekBar(
                      value: 0.5,
                      secondValue: 0.75,
                      progressColor: Colors.blue,
                      secondProgressColor: Colors.blue.withOpacity(0.5),
                      thumbColor: Colors.blue,
                      onStartTrackingTouch: () {
                        print('onStartTrackingTouch');
                      },
                      onProgressChanged: (value) {
                        print('onProgressChanged:$value');
                      },
                      onStopTrackingTouch: () {
                        print('onStopTrackingTouch');
                      },
                      horizontalPadding: false,
                      thumbRadius: _thumbSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      );
}

