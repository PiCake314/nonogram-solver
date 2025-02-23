import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Size;
import 'package:nono_solver/Block.dart';
import 'package:nono_solver/Counter.dart';
import 'package:nono_solver/Grid.dart';
import 'package:nono_solver/HintsColumn.dart';
import 'package:nono_solver/HintsRow.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nono Solver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(103, 58, 183, 1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}



class MyInteractiveiwer extends InteractiveViewer {
  MyInteractiveiwer({super.key, required super.child});


}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  Size grid_size = Size(5, 5);

  late Grid_t grid = updateGrid();
  late Hints row_hints = updateHintsRow();
  late Hints col_hints = updateHintsCol();


  Hints updateHints(int primay, int seconday) => List.generate(primay,
    (_) => List.filled(seconday, 0)
  );

  updateHintsRow() => updateHints(grid_size.height, (grid_size.width + 1) ~/ 2);
  updateHintsCol() => updateHints(grid_size.width, (grid_size.height + 1) ~/ 2);

  Grid_t updateGrid() => List.generate(grid_size.height,
    (_) => List.generate(grid_size.width, (_) => BlockState.Empty)
  );


  static List<BlockState> getRow(final Grid_t grid, final int index) => grid[index];
  static List<BlockState> getCol(final Grid_t grid, final int index) => List.generate(grid.length, (i) => grid[i][index]);

  static bool validateRow(final List<BlockState> row, final List<int> hints){
    final cleaned_hints = [...hints]..removeWhere((e) => e == 0);

    final List<int> row_counts = [];
    int count = 0;

    for(final block in row){
      if(block == BlockState.Filled) count++;
      else if(count > 0){
        row_counts.add(count);
        count = 0;
      }
    }
    // one last check in case the row ends with a filled block
    if(count > 0) row_counts.add(count);

    return listEquals(row_counts, cleaned_hints);
  }


  // Not using Grid bc I want it to be explicit that it's a list of lists.
  // Not a 2D array.
  List<List<BlockState>> generateAllStates(final List<BlockState> r){
    //  // Finding all empty blocks. Counting in base 3. 0 = empty, 1 = filled, 2 = exed.

    final row = [...r];
    final List<int> indices = [];
    for(int i = 0; i < row.length; i++) if(row[i] == BlockState.Empty) indices.add(i);

    // increasing like we're adding 1 to a number in base 3.
    void increase(final List<BlockState> current_state){
      // current_state is passed by reference.
      // No need to return and keep copying. This is a hot path!


      for(int i = 0; i < current_state.length; ++i){
        current_state[i] = current_state[i].flip();

        // could move this to the for loop condition
        // but this is more readable.
        if(current_state[i] != BlockState.Empty) break;
      }
    }

    final current_state = List.filled(indices.length, BlockState.Empty);

    List<List<BlockState>> all_states = [];


    // 2 bc there are 2 states. Empty or filled. Exed doesn't really count
    final limit = pow(2, indices.length);
    for(int i = 0; i < limit; ++i){

      for(int x = 0; x < indices.length; ++x) row[indices[x]] = current_state[x];

      // for(int shift = 0; shift < row.length; ++shift){
      //   row[shift] = ((i >> shift) & 1) == 1 ? BlockState.Filled : BlockState.Empty;
      // }

      all_states.add([...row]);

      increase(current_state);
    }

    return all_states;
  }


  static int toBits(final List<BlockState> row){
    int bits = 0;
    for(int i = 0; i < row.length; ++i){
      bits <<= 1;
      bits |= row[i] == BlockState.Filled ? 1 : 0;
    }

    return bits;
  }

  static List<BlockState> getOverlap(final List<List<BlockState>> states, final int length) {

    final int overlap = states.isEmpty ? 0 : states.map(toBits).reduce((acc, elt) => acc & elt);

    return List.generate(
      length, (shift) => ((overlap >> shift) & 1) == 1 ? BlockState.Filled : BlockState.Empty
    ).reversed.toList(); // reversing because the bits are in reverse order
  }


  static BlockState flip(BlockState e){
    switch(e){
      case BlockState.Empty:
        return BlockState.Filled;
      case BlockState.Filled:
        return BlockState.Empty;
      case BlockState.Exed:
        return BlockState.Filled;
    }
  }

  static List<BlockState> getExedOverlap(final List<List<BlockState>> states, final int length) 
    => getOverlap(
      states.map((state) => state.map(flip).toList()).toList(), // flip all the states
      length
    ).map((e) => e == BlockState.Filled || e == BlockState.Exed ? BlockState.Exed : BlockState.Empty).toList(); // re-flip the result




  List<List<BlockState>> allPossibleStates(final List<BlockState> row, final List<int> hints)
    => generateAllStates(row)..removeWhere((state) => !validateRow(state, hints));





  void process(
    final Axis_t axis,
    final getoverlalpOf
  )
  {
    final hints = axis == Axis_t.Row ? row_hints : col_hints;
    final primary_len = axis == Axis_t.Row ? grid_size.height : grid_size.width;
    final secondary_len = axis == Axis_t.Row ? grid_size.width : grid_size.height;

    for(int i = 0; i < primary_len; ++i){
      final row = axis == Axis_t.Row ? getRow(grid, i) : getCol(grid, i);

      final states = allPossibleStates(row, hints[i]);
      final overlap = getoverlalpOf(states, primary_len);




      if(axis == Axis_t.Row){
           for(int j = 0; j < secondary_len; ++j) if(overlap[j] != BlockState.Empty) grid[i][j] = overlap[j];
      }
      else for(int j = 0; j < secondary_len; ++j) if(overlap[j] != BlockState.Empty) grid[j][i] = overlap[j];

    }
  }


  int stage = 0;
  void step() {

    switch(stage){
      case 0: process(Axis_t.Row, getOverlap);     break;
      case 1: process(Axis_t.Col, getOverlap);     break;
      case 2: process(Axis_t.Row, getExedOverlap); break;
      case 3: process(Axis_t.Col, getExedOverlap); break;
    }

    setState(() {});

    ++stage;
    stage %= 4;
  }


  static calculateBlockSize(final int width, final Size grid_size) =>
     (width / (max(grid_size.width, grid_size.height) + 2)).floor();




  List<List<bool>> generateChecked(final Size grid_size) => List.generate(grid_size.height, (_) => List.generate(grid_size.width, (_) => false));
  late List<List<bool>> checked = generateChecked(grid_size);
  BlockState putting = BlockState.Filled;
  BlockState affecting = BlockState.Empty;

  @override
  Widget build(BuildContext context) {

    void updateDimension(final int inc, final Axis_t axis) => setState(() {
      if (axis == Axis_t.Row) grid_size.width += inc;
      else grid_size.height += inc;
      grid = updateGrid();
      row_hints = updateHintsRow();
      col_hints = updateHintsCol();
    });



    final int block_size = calculateBlockSize(MediaQuery.of(context).size.width.toInt(), grid_size);

    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    final transformation_controller = TransformationController();


    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 50),

          // !!! Column Hints
          InteractiveViewer(
            transformationController: transformation_controller,

            child: Column(
              children: [
                HintsColumn(col_hints: col_hints, grid_size: grid_size, block_size: block_size),

                // !!! Row Hints
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HintsRow(row_hints: row_hints, grid_size: grid_size, block_size: block_size),

                    //!!! Grid
                    GestureDetector(
                      onScaleStart: (details) {
                          if(details.pointerCount == 1){
                          // calculating indecies
                          final x = (details.localFocalPoint.dx) ~/ block_size;
                          final y = (details.localFocalPoint.dy) ~/ block_size;

                          if(x < grid_size.width && y < grid_size.height && !checked[y][x])
                            setState(() {
                              checked[y][x] = true;
                              putting = grid[y][x] == BlockState.Empty ? BlockState.Filled : BlockState.Empty;
                              affecting = grid[y][x];


                              grid[y][x] = putting;
                            }); 
                          }
                          else{
                            
                          }
                      },

                      onScaleUpdate: (details) {
                        if(details.pointerCount == 1){

                          // calculating indecies
                          final x = (details.localFocalPoint.dx) ~/ block_size;
                          final y = (details.localFocalPoint.dy) ~/ block_size;


                          if(x < grid_size.width && y < grid_size.height && !checked[y][x])
                            setState(() {
                              checked[y][x] = true;
                              if(grid[y][x] == affecting) grid[y][x] = putting;
                            });
                        }
                      },

                      onScaleEnd: (details){
                        if(details.pointerCount == 1) setState(() => checked = generateChecked(grid_size));

                      },

                      child: Grid(grid: grid, grid_size: grid_size, block_size: block_size),
                    ),
                  ]
                ),
              ],
            ),
          ),


          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Counter(
                  number: grid_size.width,
                  incr: (inc) => updateDimension(inc, Axis_t.Row),
                ),

                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    child: const Text("Reset", style: TextStyle(color: Colors.red)),
                    onPressed: () => setState(() {
                      grid = updateGrid();
                      row_hints = updateHintsRow();
                      col_hints = updateHintsCol();
                    }),
                  ),
                ),

                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    child: const Text("Solve", style: TextStyle(color: Colors.green)),
                    onPressed: (){
                      // if(betterSolve()) setState(() {});
                      // else debugPrint("No solution found!");
                      step();
                    },
                  ),
                ),

                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    child: const Text("Step", style: TextStyle(color: Colors.blue)),
                    onPressed: step,
                  ),
                ),

                Counter(
                  number: grid_size.height,
                  incr: (inc) => updateDimension(inc, Axis_t.Col),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

