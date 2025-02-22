import 'package:flutter/material.dart';
import 'package:nono_solver/Grid.dart';
import 'package:nono_solver/HintDialog.dart';
import 'package:nono_solver/HintsRow.dart' show Size, Hints;


class HintsColumn extends StatelessWidget {
  final Hints col_hints;
  final Size grid_size;
  final int block_size;
  const HintsColumn({super.key,
    required this.col_hints,
    required this.grid_size,
    required this.block_size,
  });

  @override
  Widget build(BuildContext context) =>  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(width: block_size.toDouble()), // offset for the edit icon to the left

      ...List.generate(col_hints.length,
        (i) => SizedBox(
          width: block_size.toDouble(),
          height: block_size.toDouble(),
          child: IconButton(
            icon: Icon(Icons.edit, size: block_size/1.5),
            onPressed: (){
              showDialog(
                context: context,
                builder: (_) => HintDialog(hints: col_hints, grid_size: grid_size,axis: Axis_t.Col , index: i),
              );
            },
          )
        )
      )
    ]
  );
}


// [
//       for(int i = 0; i < widget.col_hints[0].length; i++)
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(width: 50), // size of an icon

//           for(final hints in widget.col_hints)
//             SizedBox(
//               width: 50,
//               height: 50,
//               child: TextField(
//                 keyboardType: TextInputType.number,
//                 inputFormatters: [
//                   FilteringTextInputFormatter.digitsOnly,
//                   // FilteringTextInputFormatter.allow(RegExp("[0-${grid_size.height}]")),
//                   LengthLimitingTextInputFormatter(widget.grid_size.height < 10 ? 1 : 2),
//                 ],
//                 onChanged: (value) =>
//                   setState(() => hints[i] = value.isEmpty ? 0 : int.parse(value)),

//                 controller: TextEditingController(text: hints[i] == 0 ? "" : hints[i].toString(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ],