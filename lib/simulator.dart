import 'package:yaml/yaml.dart';
import 'processes.dart';
import 'util/stats.dart';

/// Queueing system simulator.
class Simulator {
  final bool verbose;
  final List<Process> processes = [];
  final List<Event> eventQueue = [];

  // Simulator(YamlMap yamlData, {this.verbose = false}) {
  //   for (final name in yamlData.keys) {
  //     final fields = yamlData[name];
  //     switch (fields['type']) {
  //       case 'singleton':
  //         processes.add(SingletonProcess(name, fields['duration'], fields['arrival']));
  //         break;
  //       case 'periodic':
  //         processes.add(PeriodicProcess(name, fields['duration'], fields['interarrival-time'], fields['first-arrival'], fields['num-repetitions']));
  //         break;
  //       case 'stochastic':
  //         processes.add(StochasticProcess(name, fields['mean-duration'], fields['mean-interarrival-time'], fields['first-arrival'], fields['end']));
  //         break;
  //       default:
  //         throw Exception('Unknown process type: ${fields['type']}');
  //     }
  //   }
  // }

  Simulator(YamlMap yamlData, {this.verbose = false}) {
  for (final name in yamlData.keys) {
    final fields = yamlData[name];
    switch (fields['type']) {
      case 'singleton':
        processes.add(SingletonProcess(name, fields['duration'], fields['arrival']));
        break;
      case 'periodic':
        processes.add(PeriodicProcess(name, fields['duration'], fields['interarrival-time'], fields['first-arrival'], fields['num-repetitions']));
        break;
      case 'stochastic':
        processes.add(StochasticProcess(
          name,
          fields['mean-duration'].toDouble(),
          fields['mean-interarrival-time'].toDouble(), 
          fields['first-arrival'],
          fields['end']
        ));
        break;
      default:
        throw Exception('Unknown process type: ${fields['type']}');
    }
  }
}

  void run() {
    // generate all events from processes
    for (var process in processes) {
      eventQueue.addAll(process.generateEvents());
    }
    
    // sort events by arrival time
    eventQueue.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    //currentTime = event.endTime;

    // simulate the queue processing
    int currentTime = 0;
    for (var event in eventQueue) {
      if (currentTime < event.arrivalTime) {
        currentTime = event.arrivalTime;
      }
      event.startTime = currentTime;
      event.endTime = currentTime + event.duration;
      currentTime = event.endTime!;
      if (verbose) {
        // print("Verbose Flag set to True");
        print('t=${event.startTime}: ${event.processName}, duration ${event.duration} started (arrived @ ${event.arrivalTime}, waited ${event.waitTime})');
        // print('\n--------------------------------------------------------------\n');
      }
    }
  }

  void printReport() {

    // print('\n--------------------------------------------------------------\n');

    // print('# Simulation trace');
    // for (var event in eventQueue) {
    //   print('t=${event.startTime}: ${event.processName}, duration ${event.duration} started (arrived @ ${event.arrivalTime}, waited ${event.waitTime})');
    // }
    // print('\n--------------------------------------------------------------\n');
    print('\n');
    print('# Per-process statistics\n');

    // statistics per process
    Map<String, List<int>> waitTimes = {};
    for (var event in eventQueue) {
      if (!waitTimes.containsKey(event.processName)) {
        waitTimes[event.processName] = [];
      }
      waitTimes[event.processName]!.add(event.waitTime);
    }

    waitTimes.forEach((processName, times) {
      int totalWaitTime = times.reduce((a, b) => a + b);
      double averageWaitTime = totalWaitTime / times.length;
      print('$processName:');
      print('  Events generated:  ${times.length}');
      print('  Total wait time:   $totalWaitTime');
      print('  Average wait time: ${averageWaitTime.toStringAsFixed(2)}\n');
    });

    print('--------------------------------------------------------------\n');
    print('# Summary statistics\n');
    int totalEvents = eventQueue.length;
    int totalWaitTime = waitTimes.values.expand((e) => e).reduce((a, b) => a + b);
    double averageWaitTime = totalWaitTime / totalEvents;
    print('Total num events:  $totalEvents');
    print('Total wait time:   ${totalWaitTime.toStringAsFixed(2)}');
    print('Average wait time: ${averageWaitTime.toStringAsFixed(2)}');

    print('\n--------------------------------------------------------------\n');
  }
}
