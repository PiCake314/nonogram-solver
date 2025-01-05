import 'package:flutter/material.dart';


class Counter extends StatefulWidget {
  final void Function(int) incr;
  final int number;
  const Counter({super.key, required this.number, required this.incr});

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
            if(widget.number < 25) widget.incr(1);
          },
          child: const Icon(Icons.keyboard_arrow_up_sharp)
        ),

        Text(widget.number.toString()),

        ElevatedButton(
          onPressed: (){
            if(widget.number > 1) widget.incr(-1);
          },
          child: const Icon(Icons.keyboard_arrow_down_sharp)
        ),
      ],
    );
  }
}
