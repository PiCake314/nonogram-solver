import 'package:flutter/material.dart';


class Counter extends StatefulWidget {
  final void Function(int) callback;
  final int number;
  const Counter({super.key, required this.number, required this.callback});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: (){
            if(widget.number < 15) widget.callback(1);
          },
          child: Icon(Icons.keyboard_arrow_up_sharp)
        ),

        Text(widget.number.toString()),

        ElevatedButton(
          onPressed: (){
            if(widget.number > 1) widget.callback(-1);
          },
          child: Icon(Icons.keyboard_arrow_down_sharp)
        ),
      ],
    );
  }
}
