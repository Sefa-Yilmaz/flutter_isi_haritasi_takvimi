import 'package:flutter_isi_haritasi_takvimi/datetime/date_time.dart';
import 'package:hive/hive.dart';

final _myBox = Hive.box('Habit_Database');

class HabitDatabase {
  List todaysHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  void createDefaulData() {
    todaysHabitList = [
      ['Run', false],
      ['Read', false],
    ];
    _myBox.put('START_DATE', todaysDateFormatted());
  }

  void loadData() {
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get('CURRENT_HABIT_LIST');
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    } else {
      todaysHabitList = _myBox.get(todaysDateFormatted());
    }
  }

  void updateDatabase() {
    _myBox.put(todaysDateFormatted(), todaysHabitList);

    _myBox.put('CURRENT_HABIT_LIST', todaysHabitList);

    calculateHabitPercentages();

    loadHeatMap();
  }

  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }
    String percent = todaysHabitList.isNotEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);
    _myBox.put('PERCENTAGE_SUMMARY_${todaysDateFormatted()}', percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get('START_DATE'));

    int daysInBetween = DateTime.now().difference(startDate).inDays;

    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesn't worry about hours/mins/secs etc.

      // year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
      print(heatMapDataSet);
    }
  }
}
