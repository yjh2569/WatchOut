import 'dart:io';

import 'package:easy_onvif/onvif.dart';
import 'package:loggy/loggy.dart';
import 'package:universal_io/io.dart';
import 'package:yaml/yaml.dart';

String profToken_1 = "profile_1";
String profToken_2 = "profile_2";

void main(List<String> arguments) async {
  //get connection information from the config.yaml file
  final config =
      loadYaml(File('camTest/config.sample.yaml').readAsStringSync());
  // configure device connection
  final onvif = await Onvif.connect(
    host: config['host'],
    username: config['username'],
    password: config['password'],
    logOptions: const LogOptions(
      LogLevel.debug,
      stackTraceLevel: LogLevel.error,
    ),
    printer: const PrettyPrinter(
      showColors: true,
    ),
  );

  //get service capabilities
  // var deviceServiceCapabilities =
  //     await onvif.deviceManagement.getServiceCapabilities();

  // print(
  //     'max password length: ${deviceServiceCapabilities.security.maxPasswordLength}');

  //get service addresses
  // var serviceList = await onvif.deviceManagement.getServices();

  // for (Service service in serviceList) {
  //   print('${service.nameSpace} ${service.xAddr}');
  // }

  //get device info
  var deviceInfo = await onvif.deviceManagement.getDeviceInformation();

  print('Manufacturer: ${deviceInfo.manufacturer}');
  print('Model: ${deviceInfo.model}');

  // var ptzConfigs = await onvif.ptz.getConfigurations();
  //
  // for (var ptzConfiguration in ptzConfigs) {
  //   print('${ptzConfiguration.name}  ${ptzConfiguration.token}');
  // }

  // print('xMax: ${ptzConfigs[0].panTiltLimits!.range.xRange.max}');
  // print('xMin: ${ptzConfigs[0].panTiltLimits!.range.xRange.min}');
  // print('yMax: ${ptzConfigs[0].panTiltLimits!.range.yRange.max}');
  // print('yMin: ${ptzConfigs[0].panTiltLimits!.range.yRange.min}');

  // var media1 = await onvif.media;
  // print("미디어 111 : ${media1.getStreamUri("raw_vs1")}");
  // get device profiles
  // var profs = await onvif.media.getProfiles();
  //
  // print("------------------------------1");
  // for (var profile in profs) {
  //   if (profile.name.isNotEmpty && profile.token.isNotEmpty) {
  //     print("2");
  //     return;
  //   }
  //   print('name: ${profile.name}, token: ${profile.token}');
  // }
  //
  // await onvif.ptz.moveLeft(profs[0].token);

  // var status = await onvif.ptz.getStatus(profs[0].token);

  // print(status);

  // await onvif.ptz.absoluteMove(
  //     profs[0].token,
  //     PtzPosition(
  //         panTilt: PanTilt(
  //             x: status.position.panTilt!.x - 0.025,
  //             y: status.position.panTilt!.y)));

  // final uri = await onvif.media.getStreamUri(profs[0].token);
  // final uri = await onvif.media.getStreamUri(profs[0].token);

  // final rtsp = OnvifUtil.authenticatingUri(
  //     uri.uri, config['username'], config['password']);

  // print('stream uri: $rtsp');

  // var ntpInformation = await onvif.deviceManagement.getNtp();
  //
  // print(ntpInformation);

  // var configurations = await onvif.media.getMetadataConfigurations();
  //
  // for (var configuration in configurations) {
  //   print('${configuration.name} ${configuration.token}');
  // }

  // get compatible configurations
  // var compatibleConfigurations =
  //     await onvif.ptz.getCompatibleConfigurations(profs[0].token);

  // for (var configuration in compatibleConfigurations) {
  //   print('${configuration.name} ${configuration.token}');
  // }

  //get capabilities
  var capabilities = await onvif.deviceManagement.getCapabilities();

  print(capabilities);

  //get hostname
  var hostname = await onvif.deviceManagement.getHostname();

  print("호스트명: $hostname");

  //get Network Protocols
  var networkProtocols = await onvif.deviceManagement.getNetworkProtocols();

  for (var networkProtocol in networkProtocols) {
    print('${networkProtocol.name} ${networkProtocol.port}');
  }

  //get system uris
  // var systemUris = await onvif.deviceManagement.getSystemUris();

  // print(systemUris);

  //create users
  var newUsers = <User>[
    User(username: 'test_1', password: 'onvif.device', userLevel: 'User'),
    User(username: 'test_2', password: 'onvif.device', userLevel: 'User')
  ];

  await onvif.deviceManagement.createUsers(newUsers);

  //get users
  var users = await onvif.deviceManagement.getUsers();

  for (var user in users) {
    print('${user.username} ${user.userLevel}');
  }

  //delete users
  var deleteUsers = ['test_1', 'test_2'];

  await onvif.deviceManagement.deleteUsers(deleteUsers);

  //get users
  users = await onvif.deviceManagement.getUsers();

  for (var user in users) {
    print('${user.username} ${user.userLevel}');
  }

  //get audio sources
  // var audioSources = await onvif.media.getAudioSources();

  // for (var audioSource in audioSources) {
  //   print('${audioSource.token} ${audioSource.channels}');
  // }

  //get video sources
  var videoSources = await onvif.media.getVideoSources();

  for (var videoSource in videoSources) {
    print('${videoSource.token} ${videoSource.resolution}');
  }

  // get snapshot Uri
  // var snapshotUri = await onvif.media.getSnapshotUri(profs[0].token);
  //
  // print(snapshotUri.uri);
  // var snapshotUri = await onvif.media.getSnapshotUri(profToken_1);
  //
  // print(snapshotUri.uri);

  //get stream Uri
  // var streamUri = await onvif.media.getStreamUri(profs[0].token);
  // var profs = await onvif.media.getProfiles();
  // print("xhxhxh토큰: ${profs[0].token}");
  var streamUri = await onvif.media.getStreamUri(profToken_1);
  print(streamUri.uri);

  // print(streamUri.uri);

  //get get configuration
  // var ptzConfig = await onvif.ptz.getConfiguration(ptzConfigs[0].token);

  // print(ptzConfig);
  // var ptzConfig = await onvif.ptz.getConfiguration(ptzConfigs[0].token);
  //
  // print(ptzConfig);

  //get get presets
  // var presets = await onvif.ptz.getPresets(profs[0].token, limit: 5);
  //
  // for (var preset in presets) {
  //   print('${preset.token} ${preset.name}');
  // }

  //get ptz status
  // var status = await onvif.ptz.getStatus(profs[0].token);

  // print(status);

  //set preset
  // var res = await onvif.ptz.setPreset(profs[0].token, 'new test', '20');
  //
  // print(res);
}
