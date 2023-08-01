import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<List<DateTime>?> showPlayerDateTimePicker(BuildContext context,
    [DateTime? startTime, DateTime? endTime]) {
  return showDialog<List<DateTime>?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          clipBehavior: Clip.hardEdge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            child: _PlayerDateTimeDialog(
              startTime: startTime,
              endTime: endTime,
            ),
          ),
        );
      });
}

class _PlayerDateTimeDialog extends StatefulWidget {
  final DateTime? startTime;
  final DateTime? endTime;

  const _PlayerDateTimeDialog({this.startTime, this.endTime});

  @override
  State<StatefulWidget> createState() => _PlayerDateTimeDialogState();
}

class _PlayerDateTimeDialogState extends State<_PlayerDateTimeDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.startTime;
    _end = widget.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              '选择回放时间',
              style: TextStyle(fontSize: 18),
            ),
          ),
          _DialogTimeField(
            label: '开始时间',
            initialTime: _start,
            onDateChange: (DateTime? time) {
              _start = time;
            },
          ),
          _DialogTimeField(
            label: '结束时间',
            initialTime: _end,
            onDateChange: (DateTime? time) {
              _end = time;
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('取消')),
                ElevatedButton(
                    onPressed: () {
                      List<DateTime>? result;
                      if (_start != null && _end != null) {
                        result = [_start!, _end!];
                      }
                      Navigator.pop(context, result);
                    },
                    child: const Text('确认')),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _DialogTimeField extends StatefulWidget {
  final String label;

  final DateTime? initialTime;

  final ValueChanged<DateTime?>? onDateChange;

  const _DialogTimeField(
      {required this.label, this.initialTime, this.onDateChange});

  @override
  State<StatefulWidget> createState() => _DialogTimeFieldState();
}

class _DialogTimeFieldState extends State<_DialogTimeField> {
  DateTime? _time;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('${widget.label}：'),
        Expanded(
          child: _PlayerTimeField(
              onTap: () => _showBottomDateTimePicker(context),
              text: _time?.toString().split('.')[0],
              hintText: '请选择日期时间'),
        )
      ],
    );
  }

  void _showBottomDateTimePicker(BuildContext context) {
    showModalBottomSheet<DateTime>(
        context: context,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
            child: _PlayerDateTimePicker(
              initialTime: _time,
            ),
          );
        }).then((value) {
      if (value == null) return;
      if (widget.onDateChange != null) {
        widget.onDateChange!(value);
      }

      setState(() {
        _time = value;
      });
    });
  }
}

class _PlayerTimeField extends StatelessWidget {
  final VoidCallback? onTap;

  final String? text;

  final String? hintText;

  final bool showIcon;

  const _PlayerTimeField(
      {this.onTap, this.text, this.hintText, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.black12,
        ),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            if (showIcon)
              const Padding(
                padding: EdgeInsets.only(right: 3),
                child: Icon(Icons.access_time, size: 18, color: Colors.black54),
              ),
            Text(
              text ?? hintText ?? '请选择',
              style: const TextStyle(color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}

class _PlayerDateTimePicker extends StatefulWidget {
  final DateTime? initialTime;

  const _PlayerDateTimePicker({this.initialTime});

  @override
  State<StatefulWidget> createState() => _PlayerDateTimePickerState();
}

class _PlayerDateTimePickerState extends State<_PlayerDateTimePicker> {
  //是否正在选择时分秒
  bool _selectTime = false;

  //选择的时间
  DateTime? _dateTime;
  //年月日字符串
  String? _date;
  //时分秒字符串
  String? _time;
  //时分秒状态刷新
  late StateSetter _timeSetter;

  @override
  void initState() {
    if (widget.initialTime != null) {
      _settingTime(widget.initialTime!);
    }
    super.initState();
  }

  void _settingTime(DateTime time) {
    _dateTime = time;
    List<String> times = time.toString().split(' ');
    _date = times[0];
    _time = times[1].split('.')[0];
  }

  void _dateTimeChange(DateTime time) {
    _settingTime(time);
    setState(() {});
  }

  void _setSelectTime(bool enabled) {
    if (_selectTime == enabled) return;
    setState(() {
      _selectTime = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget header = Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _PlayerTimeField(
              hintText: '选择日期',
              text: _date,
              showIcon: false,
              onTap: () => _setSelectTime(false),
            ),
          ),
        ),
        Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: StatefulBuilder(
                builder: (BuildContext ctx, StateSetter setter) {
                  _timeSetter = setter;
                  return _PlayerTimeField(
                    hintText: '选择时间',
                    text: _time,
                    showIcon: false,
                    onTap: () {
                      if (_date == null) return;
                      _setSelectTime(true);
                    },
                  );
                },
              ),
            )),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(child: Container()),
              TextButton(
                onPressed: () {
                  setState(() {
                    _dateTimeChange(DateTime.now());
                  });
                },
                child: const Text('此刻'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _dateTime);
                  },
                  child: const Text('确认'),
                ),
              )
            ],
          ),
        )
      ],
    );

    Widget body;
    if (_selectTime) {
      body = SizedBox(
        height: 300,
        child: _buildTimePicker(),
      );
    } else {
      DateTime now = DateTime.now();
      body = CalendarDatePicker(
        initialDate: _dateTime ?? now,
        lastDate: now,
        firstDate: now.subtract(const Duration(days: 366)),
        onDateChanged: (DateTime value) {
          _dateTimeChange(value);
        },
      );
    }

    return Column(
      children: [header, body],
    );
  }

  Widget _buildTimePicker() {
    FixedExtentScrollController? hourController;
    FixedExtentScrollController? minuteController;
    FixedExtentScrollController? secondController;
    List<String>? times = _time?.split(':');
    if (times != null && times.length == 3) {
      hourController =
          FixedExtentScrollController(initialItem: int.parse(times[0]));
      minuteController =
          FixedExtentScrollController(initialItem: int.parse(times[1]));
      secondController =
          FixedExtentScrollController(initialItem: int.parse(times[2]));
    }

    List<Widget> hourChildren = _buildPickerItem(24);
    Widget hourPicker = CupertinoPicker(
      itemExtent: 46,
      onSelectedItemChanged: (int index) {
        _timeChange(hour: index);
      },
      scrollController: hourController,
      children: hourChildren,
    );

    List<Widget> minuteChildren = _buildPickerItem(60);
    Widget minutePicker = CupertinoPicker(
      itemExtent: 46,
      onSelectedItemChanged: (int index) {
        _timeChange(minute: index);
      },
      scrollController: minuteController,
      children: minuteChildren,
    );

    List<Widget> secondChildren = _buildPickerItem(60);
    Widget secondPicker = CupertinoPicker(
      itemExtent: 46,
      onSelectedItemChanged: (int index) {
        _timeChange(second: index);
      },
      scrollController: secondController,
      children: secondChildren,
    );

    return Row(
      children: [
        Expanded(child: hourPicker),
        Expanded(child: minutePicker),
        Expanded(child: secondPicker)
      ],
    );
  }

  List<Widget> _buildPickerItem(int length) {
    return List<String>.generate(
            length, (index) => index > 9 ? index.toString() : '0$index')
        .map((e) => Center(
              child: Text(e),
            ))
        .toList(growable: false);
  }

  void _timeChange({int? hour, int? minute, int? second}) {
    DateTime? time =
        _dateTime?.copyWith(hour: hour, minute: minute, second: second);
    if (time != null) {
      _settingTime(time);
      _timeSetter(() {});
    }
  }
}
