import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../../config/app_strings.dart';
import '../../../config/device_info_constants.dart';

class DeviceInfoController extends ChangeNotifier {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Battery _battery = Battery();

  // Platform channel for battery cycles
  static const platform = MethodChannel(DeviceInfoConstants.batteryInfoChannel);

  Map<String, String> _deviceData = {};
  Map<String, String> _batteryData = {};
  bool _isLoading = true;
  int _chargingCycles = 0;

  // Getters
  Map<String, String> get deviceData => _deviceData;
  Map<String, String> get batteryData => _batteryData;
  bool get isLoading => _isLoading;
  int get chargingCycles => _chargingCycles;
  bool get hasBatteryInfo =>
      !_batteryData.containsKey(DeviceInfoConstants.errorKey);

  Future<void> initialize() async {
    await loadDeviceInfo();
    await loadBatteryInfo();
    await loadChargingCycles();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await initialize();
  }

  Future<void> loadDeviceInfo() async {
    Map<String, String> deviceData = {};

    try {
      if (Platform.isAndroid) {
        deviceData = await _getAndroidInfo();
      } else if (Platform.isIOS) {
        deviceData = await _getIosInfo();
      } else if (Platform.isWindows) {
        deviceData = await _getWindowsInfo();
      } else if (Platform.isLinux) {
        deviceData = await _getLinuxInfo();
      } else if (Platform.isMacOS) {
        deviceData = await _getMacOsInfo();
      }
    } catch (e) {
      deviceData = {
        DeviceInfoConstants.errorKey: '${AppStrings.deviceInfoErrorPrefix}$e',
      };
    }

    _deviceData = deviceData;
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, String>> _getAndroidInfo() async {
    AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    return {
      AppStrings.deviceInfoBrand: androidInfo.brand,
      AppStrings.deviceInfoModel: androidInfo.model,
      AppStrings.deviceInfoDevice: androidInfo.device,
      AppStrings.deviceInfoManufacturer: androidInfo.manufacturer,
      AppStrings.deviceInfoProduct: androidInfo.product,
      AppStrings.deviceInfoAndroidVersion: androidInfo.version.release,
      AppStrings.deviceInfoSdkVersion: androidInfo.version.sdkInt.toString(),
      AppStrings.deviceInfoSecurityPatch:
          androidInfo.version.securityPatch ??
          DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoBoard: androidInfo.board,
      AppStrings.deviceInfoHardware: androidInfo.hardware,
      AppStrings.deviceInfoSupportedAbis: androidInfo.supportedAbis.join(', '),
      AppStrings.deviceInfoIsPhysicalDevice: androidInfo.isPhysicalDevice
          .toString(),
    };
  }

  Future<Map<String, String>> _getIosInfo() async {
    IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
    return {
      AppStrings.deviceInfoName: iosInfo.name,
      AppStrings.deviceInfoModel: iosInfo.model,
      AppStrings.deviceInfoSystemName: iosInfo.systemName,
      AppStrings.deviceInfoSystemVersion: iosInfo.systemVersion,
      AppStrings.deviceInfoLocalModel: iosInfo.localizedModel,
      AppStrings.deviceInfoIdentifier:
          iosInfo.identifierForVendor ?? DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoIsPhysicalDevice: iosInfo.isPhysicalDevice
          .toString(),
    };
  }

  Future<Map<String, String>> _getWindowsInfo() async {
    WindowsDeviceInfo windowsInfo = await _deviceInfo.windowsInfo;
    return {
      AppStrings.deviceInfoComputerName: windowsInfo.computerName,
      AppStrings.deviceInfoNumberOfCores: windowsInfo.numberOfCores.toString(),
      AppStrings.deviceInfoSystemMemory:
          (windowsInfo.systemMemoryInMegabytes /
                  DeviceInfoConstants.megabytesToGigabytes)
              .toStringAsFixed(DeviceInfoConstants.memoryDecimalPlaces),
      AppStrings.deviceInfoProductName: windowsInfo.productName,
      AppStrings.deviceInfoDisplayVersion: windowsInfo.displayVersion,
      AppStrings.deviceInfoPlatformId: windowsInfo.platformId.toString(),
      AppStrings.deviceInfoMajorVersion: windowsInfo.majorVersion.toString(),
      AppStrings.deviceInfoMinorVersion: windowsInfo.minorVersion.toString(),
      AppStrings.deviceInfoBuildNumber: windowsInfo.buildNumber.toString(),
    };
  }

  Future<Map<String, String>> _getLinuxInfo() async {
    LinuxDeviceInfo linuxInfo = await _deviceInfo.linuxInfo;
    return {
      AppStrings.deviceInfoName: linuxInfo.name,
      AppStrings.deviceInfoVersion:
          linuxInfo.version ?? DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoId: linuxInfo.id,
      AppStrings.deviceInfoIdLike:
          linuxInfo.idLike?.join(', ') ?? DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoVersionCodename:
          linuxInfo.versionCodename ?? DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoVersionId:
          linuxInfo.versionId ?? DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoPrettyName: linuxInfo.prettyName,
      AppStrings.deviceInfoBuildId:
          linuxInfo.buildId ?? DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoVariant:
          linuxInfo.variant ?? DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoVariantId:
          linuxInfo.variantId ?? DeviceInfoConstants.notAvailableValue,
      AppStrings.deviceInfoMachineId:
          linuxInfo.machineId ?? DeviceInfoConstants.notAvailableValue,
    };
  }

  Future<Map<String, String>> _getMacOsInfo() async {
    MacOsDeviceInfo macInfo = await _deviceInfo.macOsInfo;
    return {
      AppStrings.deviceInfoComputerName: macInfo.computerName,
      AppStrings.deviceInfoHostName: macInfo.hostName,
      AppStrings.deviceInfoModel: macInfo.model,
      AppStrings.deviceInfoKernelVersion: macInfo.kernelVersion,
      AppStrings.deviceInfoOsRelease: macInfo.osRelease,
      AppStrings.deviceInfoMajorVersion: macInfo.majorVersion.toString(),
      AppStrings.deviceInfoMinorVersion: macInfo.minorVersion.toString(),
      AppStrings.deviceInfoPatchVersion: macInfo.patchVersion.toString(),
      AppStrings.deviceInfoSystemGuid:
          macInfo.systemGUID ?? DeviceInfoConstants.notAvailableValue,
    };
  }

  Future<void> loadBatteryInfo() async {
    Map<String, String> batteryData = {};

    try {
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;

      batteryData = {
        AppStrings.deviceInfoBatteryLevel: '$batteryLevel%',
        AppStrings.deviceInfoBatteryState: _getBatteryStateText(batteryState),
        AppStrings.deviceInfoHealthStatus: _getBatteryHealth(batteryLevel),
      };
    } catch (e) {
      batteryData = {
        DeviceInfoConstants.errorKey: AppStrings.deviceInfoBatteryError,
      };
    }

    _batteryData = batteryData;
    notifyListeners();
  }

  String _getBatteryStateText(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return AppStrings.deviceInfoBatteryCharging;
      case BatteryState.full:
        return AppStrings.deviceInfoBatteryFull;
      case BatteryState.discharging:
        return AppStrings.deviceInfoBatteryDischarging;
      case BatteryState.unknown:
      default:
        return AppStrings.deviceInfoBatteryUnknown;
    }
  }

  String _getBatteryHealth(int level) {
    if (level >= DeviceInfoConstants.batteryGoodThreshold) {
      return AppStrings.deviceInfoHealthGood;
    }
    if (level >= DeviceInfoConstants.batteryFairThreshold) {
      return AppStrings.deviceInfoHealthFair;
    }
    if (level >= DeviceInfoConstants.batteryLowThreshold) {
      return AppStrings.deviceInfoHealthLow;
    }
    return AppStrings.deviceInfoHealthCritical;
  }

  Future<void> loadChargingCycles() async {
    try {
      if (Platform.isAndroid) {
        final result = await _readAndroidBatteryCycles();
        _chargingCycles = result;
      } else if (Platform.isMacOS) {
        final result = await _readMacOSBatteryCycles();
        _chargingCycles = result;
      } else {
        _chargingCycles = DeviceInfoConstants.batteryUnknownCycles;
      }
    } catch (e) {
      _chargingCycles = DeviceInfoConstants.batteryUnknownCycles;
    }
    notifyListeners();
  }

  Future<int> _readAndroidBatteryCycles() async {
    try {
      final int cycles = await platform.invokeMethod(
        DeviceInfoConstants.getBatteryCyclesMethod,
      );
      return cycles;
    } on PlatformException catch (e) {
      debugPrint("Failed to get battery cycles: '${e.message}'.");
      return DeviceInfoConstants.batteryUnknownCycles;
    }
  }

  Future<int> _readMacOSBatteryCycles() async {
    try {
      final result = await Process.run(
        DeviceInfoConstants.macOSSystemProfiler,
        [DeviceInfoConstants.macOSPowerDataType],
      );
      final output = result.stdout.toString();

      final cycleMatch = RegExp(
        DeviceInfoConstants.macOSCycleCountPattern,
      ).firstMatch(output);
      if (cycleMatch != null) {
        return int.parse(cycleMatch.group(1)!);
      }
    } catch (e) {
      // Command failed or not available
    }
    return DeviceInfoConstants.batteryUnknownCycles;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
