import 'package:flutter/material.dart';
import 'package:nono_solver/Grid.dart';
import 'package:nono_solver/HintDialog.dart';


typedef Hints = List<List<int>>;
class Size {
  int width, height;
  Size(this.width, this.height);
}


class HintsRow extends StatelessWidget {
  final Hints row_hints;
  final Size grid_size;
  final int block_size;
  const HintsRow({
    super.key,
    required this.row_hints,
    required this.grid_size,
    required this.block_size,
  });

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children:
      List.generate(row_hints.length, (i) => 
        SizedBox(
          width: block_size.toDouble(),
          height: block_size.toDouble(),
          child: IconButton(
            icon: Icon(Icons.edit, size: block_size/1.5),
            onPressed: (){
              showDialog(
                context: context,
                builder: (_) => HintDialog(hints: row_hints, grid_size: grid_size, axis: Axis_t.Row, index: i),
              );
            },
          )
      )),
  );
}
