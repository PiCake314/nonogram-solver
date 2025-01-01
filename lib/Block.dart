import 'package:flutter/material.dart';


enum BlockState {
  Empty,
  Filled,
  Exed;

  BlockState operator+(int i) {
    switch(this) {
      case BlockState.Empty:
        return BlockState.Filled;
      case BlockState.Filled:
        return BlockState.Exed;
      case BlockState.Exed:
        return BlockState.Empty;
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
  final grid_size;

  const Block({
    super.key,
    required this.state,
    required this.onTap,
    required this.onLongPress,
    required this.grid_size
  });


  @override
  State<Block> createState() => _BlockState();
}

class _BlockState extends State<Block> {
  static const double size = 50;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final two_thirds_width = 2/3 * width;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,

      child: Container(
        width: widget.grid_size.height * size > two_thirds_width ? 35 : size,
        height:widget.grid_size.height * size > two_thirds_width ? 35 : size,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.onSurface),
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

