import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nono_solver/Grid.dart';
import 'package:nono_solver/HintsRow.dart' show Size, Hints;



class HintDialog extends StatelessWidget {
  final Hints hints;
  final Size grid_size;
  final Axis_t axis;
  final int index;
  HintDialog({super.key, 
    required this.hints, 
    required this.grid_size,
    required this.axis,
    required this.index,
  });


  late final controller = PageController(initialPage: index);

  void changePage(bool forward){
    if(forward && controller.page! < hints.length - 1)
      controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOutSine);
    else if(!forward && controller.page! > 0)
      controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOutSine);
  }

  @override
  Widget build(BuildContext context) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          padding: const EdgeInsets.symmetric(vertical: 50),
          icon: const Icon(Icons.arrow_back_ios_sharp, size: 25),
          style: const ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
            backgroundColor: WidgetStatePropertyAll(Colors.white)
          ),
          onPressed: () => changePage(false)
        ),

        SizedBox(
          width: MediaQuery.sizeOf(context).width - 200,
          height: 300,

          child: PageView.builder(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hints.length,
            itemBuilder: (context, index) => SingleChildScrollView(
              child: Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text("${axis == Axis_t.Row ? "Row" : "Column"} ${index + 1}",
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),

                      SizedBox(
                        height: 150,
                        width: MediaQuery.sizeOf(context).width - 200,

                        child: ListView.separated(
                          separatorBuilder: (_, __) => const SizedBox(width: 30),
                          scrollDirection: Axis.horizontal,
                          itemCount: hints.first.length,
                          itemBuilder: (context, j) =>
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 150,
                                height: 250,
                                child: Center(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: "Hint ${j + 1}",
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      // TODO: fix the regex
                                      // FilteringTextInputFormatter.allow(RegExp("[0-${grid_size.height}]")),
                                      LengthLimitingTextInputFormatter(grid_size.height < 10 ? 1 : 2),
                                    ],
                                    onChanged: (value) => hints[index][j] = value.isEmpty ? 0 : int.parse(value),
                                    controller: TextEditingController(
                                      text: hints[index][j] == 0 ? "" : hints[index][j].toString(),
                                    )
                                  ),
                                ),
                              ),
                            )
                          ),
                        ),
                      ],
                    )
              ),
            ),
          ),
        ),


        IconButton(
          padding: const EdgeInsets.symmetric(vertical: 50),
          icon: const Icon(Icons.arrow_forward_ios_sharp, size: 25),
          style: const ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)))),
            backgroundColor: WidgetStatePropertyAll(Colors.white)
          ),
          onPressed: () => changePage(true)
        ),
      ],
    );
}

