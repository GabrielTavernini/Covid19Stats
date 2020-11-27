import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeDialog extends StatefulWidget {
  DateRangeDialog(this.availableRange, this.currentRange, {Key key}) : super(key: key);
  final DateTimeRange availableRange, currentRange;

  @override
  _DateRangeDialogState createState() => _DateRangeDialogState();
}

class _DateRangeDialogState extends State<DateRangeDialog> {
  TextEditingController fromController;
  TextEditingController toController;
  DateFormat dateFormat = DateFormat('dd MMMM yyyy');

  DateTimeRange selectedRange;
  int selectedOption;

  DateTimeRange preset7, preset28;

  @override
  void initState() {
    super.initState();

    preset7 = DateTimeRange(
        start:  widget.availableRange.end.subtract(Duration(days: 7)),
        end: widget.availableRange.end
    );
    preset28 = DateTimeRange(
        start:  widget.availableRange.end.subtract(Duration(days: 28)),
        end: widget.availableRange.end
    );

    selectedRange = widget.currentRange;
    checkForPresets(); //Sets selectedOption
    fromController = new TextEditingController(text: dateFormat.format(widget.currentRange.start));
    toController = new TextEditingController(text: dateFormat.format(widget.currentRange.end));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Charts date range"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField(
            dropdownColor: Color(0xff232d37),
            value: selectedOption,
            items: [
              DropdownMenuItem(child: Text("Last 7 days"), value: 0),
              DropdownMenuItem(child: Text("Last 28 days"), value: 1),
              DropdownMenuItem(child: Text("Everything"), value: 2),
              DropdownMenuItem(child: Text("Custom"), value: 3)
            ],
            onChanged: (value){
              setState(() {
                selectedOption = value;
              });
              switch(value) {
                case 0:
                  selectedRange = preset7;
                  break;
                case 1:
                  selectedRange = preset28;
                  break;
                case 2:
                  selectedRange = widget.availableRange;
                  break;
              }
              fromController.text = dateFormat.format(selectedRange.start);
              toController.text = dateFormat.format(selectedRange.end);
            },
          ),
          SizedBox(height: 20),
          Container(
            height: 50,
            child: TextField(
              readOnly: true,
              showCursor: false,
              textAlign: TextAlign.center,
              controller: fromController,
              decoration: InputDecoration(
                labelText: "From",
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime newDate = await showDatePicker(
                  context: context,
                  initialEntryMode: DatePickerEntryMode.calendar,
                  firstDate: widget.availableRange.start,
                  lastDate: widget.availableRange.end,
                  initialDate: selectedRange.start
                );

                if(newDate != null && newDate != selectedRange.start) {
                  fromController.text = dateFormat.format(newDate);
                  selectedRange = DateTimeRange(
                      start: newDate,
                      end: selectedRange.end
                  );
                  checkForPresets();
                }
              },
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 50,
            child: TextField(
              readOnly: true,
              textAlign: TextAlign.center,
              controller: toController,
              decoration: InputDecoration(
                labelText: "To",
                border: OutlineInputBorder()
              ),
              onTap: () async {
                DateTime newDate = await showDatePicker(
                  context: context,
                  initialEntryMode: DatePickerEntryMode.calendar,
                  firstDate: widget.availableRange.start,
                  lastDate: widget.availableRange.end,
                  initialDate: selectedRange.end
                );

                if(newDate != null && newDate != selectedRange.end) {
                  toController.text = dateFormat.format(newDate);
                  selectedRange = DateTimeRange(
                    start: selectedRange.start,
                    end: newDate
                  );
                  checkForPresets();
                }
              },
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          color: Colors.red,
          child: Text('Save'),
          onPressed: () {
            Navigator.of(context).pop(selectedRange);
          },
        ),
      ],
    );
  }

  void checkForPresets() {
    if(selectedRange == preset7)
      selectedOption = 0;
    else if(selectedRange == preset28)
      selectedOption = 1;
    else if(selectedRange == widget.availableRange)
      selectedOption = 2;
    else
      selectedOption = 3;
    setState(() {});
  }
}