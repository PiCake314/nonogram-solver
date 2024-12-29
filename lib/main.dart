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

  updateHintsRow() => updateHints(grid_size.height.toInt(), (grid_size.width + 1) ~/ 2);
  updateHintsCol() => updateHints(grid_size.width.toInt(), (grid_size.height.toInt() + 1) ~/ 2);

  Grid updateGrid() => List.generate(grid_size.height.toInt(),
    (_) => List.generate(grid_size.width.toInt(), (_) => BlockState.Empty)
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

  static bool validateCols(Grid grid, Hints cols){
    for(int i = 0; i < grid[0].length; i++){
      final List<BlockState> col = List.generate(grid.length, (j) => grid[j][i]);
      if(!validateRow(col, [...cols[i]]..removeWhere((e) => e == 0))) return false;
    }

    return true;
  }

  static bool validate(final Grid grid, Hints rows, final Hints cols){
    return validateRows(grid, rows) && validateCols(grid, cols);
  }



  @override
  Widget build(BuildContext context) {
    void updateDimension(int inc, bool width) => setState(() {
      if (width) grid_size.width += inc;
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
                  number: grid_size.width.toInt(),
                  callback: (inc) => updateDimension(inc, true),
                ),

                ElevatedButton(
                  child: Text("Validate"),
                  onPressed: () {
                    final bool v = validate(grid, row_hints, col_hints);
                    debugPrint("Validation: $v");
                  } ,
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
                  number: grid_size.height.toInt(),
                  callback: (inc) => updateDimension(inc, false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


