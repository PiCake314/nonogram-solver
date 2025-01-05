import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nono_solver/Block.dart';



typedef Grid_t = List<List<BlockState>>;
extension on Grid_t{
  bool compare(final Grid_t grid){
    if(length != grid.length) return false;

    for(int i = 0; i < length; ++i)
      if(!listEquals(this[i], grid[i])) return false;

    return true;
  }


  Grid_t clone() => List.generate(length, (i) => List.generate(this[i].length, (j) => this[i][j]));
}

enum Axis_t { Row, Col }


class Grid extends StatefulWidget {
  final Grid_t grid;
  final grid_size;
  final int block_size;
  const Grid({
    super.key,
    required this.grid,
    required this.grid_size,
    required this.block_size,
  });

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  @override
  Widget build(BuildContext context) =>  Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for(int i = 0; i < widget.grid.length; ++i)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for(int j = 0; j < widget.grid[i].length; ++j)
              Block(
                state: widget.grid[i][j],
                onTap: () => setState(() {
                  if(widget.grid[i][j] == BlockState.Exed) widget.grid[i][j] = BlockState.Empty;
                  else widget.grid[i][j] = (widget.grid[i][j] == BlockState.Filled) ? BlockState.Empty : BlockState.Filled;
                }),

                onLongPress: () => setState(() {
                  if(widget.grid[i][j] == BlockState.Filled) return;

                  widget.grid[i][j] = (widget.grid[i][j] == BlockState.Exed) ? BlockState.Empty : BlockState.Exed;
                }),

                grid_size: widget.grid_size,

                block_size: widget.block_size,

                i: i,
                j: j,
              )
        ],
      ),
    ],
  );
}