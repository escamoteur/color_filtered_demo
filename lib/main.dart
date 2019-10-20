import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Filter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Color Filter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CellData {
  double value;
  final int index;
  TextEditingController controller;

  CellData(this.value, this.index);
}

Map<String, List<double>> predefinedFilters = {
  'Identity': [
    //R  G   B    A  Const
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ],
  'Grey Scale': [
    //R  G   B    A  Const
    0.33, 0.59,0.11, 0,0,//
    0.33,0.59,0.11, 0,0,//
    0.33, 0.59,0.11, 0,0,//
    0, 0, 0, 1, 0, //
  ],
  'Invers': [
    //R  G   B    A  Const
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ],
  'Sepia': [
    //R  G   B    A  Const
    0.393, 0.769, 0.189, 0,0, //
    0.349,0.686,0.168,   0,0, //
    0.272,0.534,0.131,0,0, //
    0, 0, 0, 1, 0, //
  ],
};

class _MyHomePageState extends State<MyHomePage> {
  File imageFile;
  List<CellData> matrixValues =
      List<CellData>.generate(20, (index) => CellData(0.0, index));

  _MyHomePageState() {
    upDateMatrixValues(predefinedFilters['Identity']);
  }

  void pickImage() async {
    imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 800,
        maxHeight: 800);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              FractionallySizedBox(
                widthFactor: 0.75,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: GestureDetector(
                      onTap: pickImage,
                      child: imageFile != null
                          ? ColorFiltered(
                              colorFilter: ColorFilter.matrix(matrixValues
                                  .map<double>((entry) => entry.value)
                                  .toList()),
                              child: Image.file(
                                imageFile,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(child: Text('Tap here to select image')),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              FractionallySizedBox(
                widthFactor: 0.75,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  scrollDirection: Axis.vertical,
                  children: List<Widget>.generate(
                    matrixValues.length,
                    (index) => Center(
                      child: new MatrixCell(
                          value: matrixValues[index].value,
                          index: index,
                          onChanged: (newVal) => setState(
                              () => matrixValues[index].value = newVal)),
                    ),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                child: Container(
                    color: Color(0xff666666),
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(8),
                    child: Text('Predefined Filters')),
                itemBuilder: (context) => predefinedFilters.keys
                    .map<PopupMenuItem<String>>(
                      (filterName) => PopupMenuItem<String>(
                        value: filterName,
                        child: Text(filterName),
                      ),
                    )
                    .toList(),
                 onSelected: (entry) => setState(() {
                   upDateMatrixValues(predefinedFilters[entry]);
                 }),   
              )
            ],
          ),
        ),
      ),
    );
  }

  void upDateMatrixValues(List<double> values) {
    assert(values.length == 20);
    assert(matrixValues != null);
    for (int i = 0; i < values.length; i++) {
      matrixValues[i].value = values[i];
    }
  }
}

class MatrixCell extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const MatrixCell({Key key, this.index, this.value, this.onChanged})
      : assert(index != null),
        assert(value != null),
        super(key: key);
  final int index;

  @override
  _MatrixCellState createState() => _MatrixCellState();
}

class _MatrixCellState extends State<MatrixCell> {
  TextEditingController _controller;
  bool validValue = true;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _controller ??=
        TextEditingController(text: widget.value.toString());
    _focusNode.addListener(onFocusChanged);
    super.initState();
  }

  void onFocusChanged() {
    if (!_focusNode.hasFocus) {
      onEditFinish(_controller.text);
    }
  }

  @override
  void didUpdateWidget(MatrixCell oldWidget) {
    assert(_controller != null);
    _controller.text = widget.value.toString();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _focusNode.removeListener(onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      color: validValue ? Color(0xff666666) : Colors.redAccent,
      child: TextField(
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        controller: _controller,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        inputFormatters: [
          ThousandsFormatter(
              allowFraction: true, formatter: NumberFormat.decimalPattern('en'))
        ],
        keyboardType:
            TextInputType.numberWithOptions(decimal: true, signed: true),
        onSubmitted: onEditFinish,
      ),
    );
  }

  void onEditFinish(s) {
    s.replaceAll(',', '.');
    var value = double.tryParse(s);
    setState(() {
      validValue = value != null;
    });
    if (validValue) {
      widget.onChanged(value);
    }
  }
}
