import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nono_solver/Grid.dart';
import 'package:nono_solver/HintsRow.dart';



class HintDialog extends StatefulWidget {
  final Hints hints;
  final Size grid_size;
  final Axis_t axis;
  final int index;
  const HintDialog({super.key, 
    required this.hints, 
    required this.grid_size,
    required this.axis,
    required this.index,
  });

  @override
  State<HintDialog> createState() => _HintDialogState();
}

class _HintDialogState extends State<HintDialog> {

  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
  }

  @override
  void dispose() { super.dispose(); controller.dispose(); }


  void changePage(bool forward){
    if(forward && controller.page! < widget.hints.length - 1)
      controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    else if(!forward && controller.page! > 0)
      controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
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

          child: PageView(
            controller: controller,

            // itemCount: widget.hints.length,
            // itemBuilder: (context, index) {

            children: [
              for(final (index, hint_row) in widget.hints.indexed)
                Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text("${widget.axis == Axis_t.Row ? "Row" : "Col"} ${index + 1}",
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),

                      SizedBox(
                        height: 150,
                        width: MediaQuery.sizeOf(context).width - 200,

                        child: ListView.separated(
                          separatorBuilder: (_, __) => const SizedBox(width: 30),
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.hints.first.length,
                          itemBuilder: (context, j) =>
                            SizedBox(
                              width: 250,
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
                                    LengthLimitingTextInputFormatter(widget.grid_size.height < 10 ? 1 : 2),
                                  ],
                                  onChanged: (value) => hint_row[j] = value.isEmpty ? 0 : int.parse(value),
                                  controller: TextEditingController(
                                    text: hint_row[j] == 0 ? "" : hint_row[j].toString(),
                                  )
                                ),
                              ),
                            )
                        ),
                      ),
                    ],
                  )
                )
            ],
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

