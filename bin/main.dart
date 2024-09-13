import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import 'package:queueing_simulator/simulator.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption('conf', abbr: 'c', help: 'Config file path')
    ..addFlag('verbose', abbr: 'v', defaultsTo: false, negatable: false, help: 'Print verbose output');
  
  final results = parser.parse(args);

  if (!results.wasParsed('conf')) {
    print(parser.usage);
    exit(0);
  } 

  final verbose = results['verbose'];

  final file = File(results['conf']);
  if (!file.existsSync()) {
    print('Config file not found: ${results['conf']}');
    exit(1);
  }

  final yamlString = file.readAsStringSync();
  final yamlData = loadYaml(yamlString);

  final simulator = Simulator(yamlData, verbose: verbose); // Pass the verbose flag to the Simulator constructor
  simulator.run();
  simulator.printReport();
}
