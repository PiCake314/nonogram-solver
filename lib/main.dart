import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nono_solver/Block.dart';
import 'package:nono_solver/Counter.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nono Solver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(103, 58, 183, 1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


typedef Grid = List<List<BlockState>>;
typedef Hints = List<List<int>>;

enum Axis { Row, Col }

class Size {
  int width, height;
  Size(this.width, this.height);
}

class _MyHomePageState extends State<MyHomePage> {
  Size grid_size = Size(5, 5);

  late Grid grid = updateGrid();
  late Hints row_hints = updateHintsRow();
  late Hints col_hints = updateHintsCol();


  Hints updateHints(int primay, int seconday) => List.generate(primay, 
    (_) => List.generate(seconday, (_) => 0)
  );

  updateHintsRow() => updateHints(grid_size.height, (grid_size.width + 1) ~/ 2);
  updateHintsCol() => updateHints(grid_size.width, (grid_size.height + 1) ~/ 2);

  Grid updateGrid() => List.generate(grid_size.height,
    (_) => List.generate(grid_size.width, (_) => BlockState.Empty)
  );




  static bool validateRow(final List<BlockState> row, final List<int> hints){
    final List<int> row_hints = [];
    int count = 0;

    for(final block in row){
      if(block == BlockState.Filled) count++;
      else if(count > 0){
        row_hints.add(count);
        count = 0;
      }
    }
    // one last check in case the row ends with a filled block
    if(count > 0) row_hints.add(count);

    debugPrint("Row Hints: $row_hints");
    debugPrint("Hints: $hints");

    return listEquals(row_hints, hints);
  }


  static bool validateRows(final Grid grid, final Hints rows){
    for(int i = 0; i < grid.length; i++)
      if(!validateRow(grid[i], [...rows[i]]..removeWhere((e) => e == 0))) return false;

    return true;
  }

  static bool validateCols(final Grid grid, final Hints cols){
    for(int i = 0; i < grid[0].length; i++){
      final List<BlockState> col = List.generate(grid.length, (j) => grid[j][i]);
      if(!validateRow(col, [...cols[i]]..removeWhere((e) => e == 0))) return false;
    }

    return true;
  }

  static bool validateSolution(final Grid grid, Hints rows, final Hints cols){
    return validateRows(grid, rows) && validateCols(grid, cols);
  }


  static int minSegments(final List<BlockState> row){
    int min = 0;
    // bool broken = true;
    for(int i = 0; i < row.length; ++i){
      if(row[i] == BlockState.Filled){
        ++min;
        while(i < row.length && row[i] != BlockState.Exed) ++i;
      }
      // if(row[i] == BlockState.Exed) broken = true;
    }

    return min;
  }


  static int maxSegHelper(final List<BlockState> row){

    int min = 0;
    for(int i = 0; i < row.length; ++i){
        if(row[i] == BlockState.Exed){
          ++min;
          
          // skips an extra block (which is not exed anyway)
          // it's a bug 
          while(i < row.length && row[i] == BlockState.Exed) ++i;
        }
    }
    if(row.first == BlockState.Exed) --min;
    if(row.last == BlockState.Exed) --min;

    return min + 1;
  }

  static int maxSegments(final List<BlockState> r){
    final row = [...r];

    for(int i = 1; i < row.length; i++){
      if(row[i-1] != BlockState.Exed && row[i] == BlockState.Empty)
        row[i] = BlockState.Exed;
    }


    return maxSegHelper(row);
  }

  (int, int) minAndMaxSegments(final Axis axis, final int index){
    final List<BlockState> row = axis == Axis.Row ? grid[index] : List.generate(grid.length, (i) => grid[i][index]);

    return (minSegments(row), maxSegments(row));
  }


  bool solvable(){
    debugPrint("row_hints[0]: ${row_hints[0]}");
    for(int i = 0; i < grid.length; i++){
      final List<int> hints = [...row_hints[i]]..removeWhere((e) => e == 0);

      final (min, max) = minAndMaxSegments(Axis.Row, i);
      if(hints.length < min || hints.length > max) return false;
    }

    for(int i = 0; i < grid[0].length; i++){
      // ! Might be a bug...
      final List<int> hints = [...col_hints[i]]..removeWhere((e) => e == 0);

      final (min, max) = minAndMaxSegments(Axis.Col, i);
      if(hints.length < min || hints.length > max) return false;
    }

    return true;
  }


  static (int, int) findEmptyBlock(final Grid grid){
    for(int i = 0; i < grid.length; i++)
      for(int j = 0; j < grid[i].length; j++)
        if(grid[i][j] == BlockState.Empty) return (i, j);

    return (-1, -1);
  }

  bool solve(){
    final (i, j) = findEmptyBlock(grid);
    if(i == -1) return true;

    for(final state in [BlockState.Filled, BlockState.Exed]){
      grid[i][j] = state;
      if(validateSolution(grid, row_hints, col_hints) && solve()) return true;
      grid[i][j] = BlockState.Empty;
    }

    return false;
  }


  @override
  Widget build(BuildContext context) {

    void updateDimension(final int inc, final Axis axis) => setState(() {
      if (axis == Axis.Row) grid_size.width += inc;
      else grid_size.height += inc;
      grid = updateGrid();
      row_hints = updateHintsRow();
      col_hints = updateHintsCol();
    });

    debugPrint("Column Hints:");
    for(final hints in col_hints) debugPrint(hints.toString());

    debugPrint("\nRow Hints:");
    for(final hints in row_hints) debugPrint(hints.toString());

    debugPrint("\nGrid:");
    for(final col in grid) debugPrint(col.toString());


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 50),

          // !!! Column Hints
          Column(
            children: [
              for(int i = 0; i < col_hints[0].length; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: row_hints[0].length * 50),

                    for(final hints in col_hints)
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.allow(RegExp("[0-${grid_size.height}]")),
                            LengthLimitingTextInputFormatter(grid_size.height < 10 ? 1 : 2),
                          ],
                          onChanged: (value) =>
                            setState(() => hints[i] = value.isEmpty ? 0 : int.parse(value)),

                          controller: TextEditingController(text: hints[i] == 0 ? "" : hints[i].toString(),
                        ),
                      ),
                    ),
                  ],
                ),

              // !!! Row Hints
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for(final hints in row_hints)
                        Row(
                          children: [
                            for(int i = 0; i < hints.length; i++)
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    FilteringTextInputFormatter.allow(RegExp("[0-${grid_size.width}]")),
                                    LengthLimitingTextInputFormatter(grid_size.width < 10 ? 1 : 2),
                                  ],
                                  onChanged: (value) =>
                                    setState(() => hints[i] = value.isEmpty ? 0 : int.parse(value)),

                                  controller: TextEditingController(text: hints[i] == 0 ? "" : hints[i].toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ]
                  ),

                  //!!! Grid
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for(final col in grid)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for(int i = 0; i < col.length; i++)
                              Block(
                                state: col[i],
                                onTap: () => setState(() {
                                  if(col[i] == BlockState.Exed) col[i] = BlockState.Empty;
                                  else col[i] = (col[i] == BlockState.Filled) ? BlockState.Empty : BlockState.Filled;
                                }),

                                onLongPress: () => setState(() {
                                  if(col[i] == BlockState.Filled) return;

                                  col[i] = (col[i] == BlockState.Exed) ? BlockState.Empty : BlockState.Exed;
                                }),

                                grid_size: grid_size
                              )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),


          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Counter(
                  number: grid_size.width,
                  callback: (inc) => updateDimension(inc, Axis.Row),
                ),

                ElevatedButton(
                  child: Text("Validate"),
                  onPressed: () {
                    final bool v = validateSolution(grid, row_hints, col_hints);
                    debugPrint("Validation: $v");
                  } ,
                ),

                ElevatedButton(
                  child: Text("Solve", style: TextStyle(color: Colors.green)),
                  onPressed: (){
                    // if(solve()) setState(() {});
                    // else debugPrint("No solution found!");

                      final (min, max) = minAndMaxSegments(Axis.Row, 0);
                      debugPrint("Min: $min, Max: $max");
                      final bool can_solve = solvable();
                      debugPrint("Solvable: $can_solve");
                  },
                ),

                ElevatedButton(
                  child: Text("Reset", style: TextStyle(color: Colors.red)),
                  onPressed: () => setState(() {
                    grid = updateGrid();
                    row_hints = updateHintsRow();
                    col_hints = updateHintsCol();
                  }),
                ),

                Counter(
                  number: grid_size.height,
                  callback: (inc) => updateDimension(inc, Axis.Col),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


