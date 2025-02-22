import 'package:flutter/material.dart' hide Size;
import 'package:nono_solver/HintsRow.dart' show Size;


enum BlockState {
  Empty,
  Filled,
  Exed;

  BlockState operator+(final int i) {
    // i isn't used.
    // I wanted to do ++;

    switch(this) {
      case BlockState.Empty:
        return BlockState.Filled;
      case BlockState.Filled:
        return BlockState.Exed;
      case BlockState.Exed:
        return BlockState.Empty;
    }
  }


  BlockState flip(){
    switch(this){
      case BlockState.Empty:
        return BlockState.Filled;
      case BlockState.Filled:
        return BlockState.Empty;
      case BlockState.Exed:
        return BlockState.Exed;
    }
  }

  @override
  String toString() {
    switch(this) {
      case BlockState.Empty:
        return "Empty";
      case BlockState.Filled:
        return "Filled";
      case BlockState.Exed:
        return "Exed";
    }
  }
}



class Block extends StatefulWidget {
  final BlockState state;
  final void Function() onTap;
  final void Function() onLongPress;
  final Size grid_size;
  final int block_size;
  final int i;
  final int j;

  const Block({
    super.key,
    required this.state,
    required this.onTap,
    required this.onLongPress,
    required this.grid_size,
    required this.block_size,
    required this.i,
    required this.j,
  });


  @override
  State<Block> createState() => _BlockState();
}

class _BlockState extends State<Block> {

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    // final two_thirds_width = 2/3 * width;
    // widget.grid_size.height * size > two_thirds_width ? 35 : size

    bool is5th(final int index) => index > 1 && (index) % 5 == 0;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,

      child: Container(
        width: widget.block_size.toDouble() + (is5th(widget.j) ? 5 : 0),
        height: widget.block_size.toDouble() + (is5th(widget.i) ? 5 : 0),
        decoration: BoxDecoration(
            border:
              Border.merge(
                Border.merge(
                  Border.all(color: Colors.black),
                  Border(left: BorderSide(color: Colors.black, width: is5th(widget.j) ? 5 : 0)),
                ),
              Border(top: BorderSide(color: Colors.black, width: is5th(widget.i) ? 5 : 0)),
            ),
            // border: Bordexr.all(color: Colors.black),
        ),

        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            color:
              widget.state == BlockState.Filled ? Colors.black
            : widget.state == BlockState.Exed ? Colors.red : null,
          ),
        ),
      )
    );
  }
}

