import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:hive/hive.dart';
import 'package:task_management_app/data/datasources/hive_task_data_source.dart';
import 'package:task_management_app/domain/entities/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('write and read tasks persists correctly (Hive)', () async {
    await setUpTestHive();
    final box = await Hive.openBox<Map>('test_tasks');
    final ds = HiveTaskDataSource(box: box);

    final t1 = Task(id: '1', title: 'A');
    final t2 = Task(id: '2', title: 'B');
    await ds.writeTasks([t1, t2]);

    final readBack = await ds.readTasks();
    expect(readBack.length, 2);
    expect(readBack.first.title, 'A');
    await tearDownTestHive();
  });
}

