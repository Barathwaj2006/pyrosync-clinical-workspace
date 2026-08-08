import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/components/pyro_card.dart';
import '../../design_system/typography/pyro_typography.dart';
import '../../design_system/colors/pyro_colors.dart';
import '../../design_system/theme/pyro_theme.dart';
import '../../core_engines/auth/auth_engine.dart';
import '../../core_engines/theme/theme_engine_controller.dart';
import '../../device_connectivity/device_manager/device_manager.dart';
import '../../device_connectivity/models/device_models.dart';
import '../../hardware_integration/pokidex/pokidex_dual_transport_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Clinician Profile Controllers
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _institutionController;
  late TextEditingController _credentialsController;
  late TextEditingController _emailController;

  // Signal Settings
  String _samplingRate = '2500 Hz';
  String _notchFilter = '50 Hz';
  String _highPass = '1.0 Hz';
  String _lowPass = '100 Hz';

  // Network Manual Entry Controllers
  late TextEditingController _ipController;
  late TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    final profile = ref.read(authEngineProvider).profile;
    _nameController = TextEditingController(text: profile.fullName);
    _titleController = TextEditingController(text: profile.title);
    _institutionController = TextEditingController(text: profile.institution);
    _credentialsController = TextEditingController(text: profile.credentials);
    _emailController = TextEditingController(text: profile.email);
    _ipController = TextEditingController(text: '192.168.1.42');
    _portController = TextEditingController(text: '5000');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _institutionController.dispose();
    _credentialsController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final deviceState = ref.watch(deviceManagerProvider);
    final deviceNotifier = ref.read(deviceManagerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SYSTEM CONFIGURATION & CLINICAL SETTINGS', style: PyroTypography.heading1(true)),
          Text('Manage clinician profile, hardware connections, signal DSP parameters, and visual appearance.', style: PyroTypography.body(true).copyWith(color: const Color(0xFF94A3B8))),
          const SizedBox(height: 20),

          // Settings Tab Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF151C2C),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: PyroColors.medicalBlue,
              labelColor: PyroColors.medicalBlue,
              unselectedLabelColor: const Color(0xFF94A3B8),
              tabs: const [
                Tab(icon: Icon(Icons.person_outline, size: 18), text: 'General & Profile'),
                Tab(icon: Icon(Icons.palette_outlined, size: 18), text: 'Appearance'),
                Tab(icon: Icon(Icons.developer_board, size: 18), text: 'Device & Hardware'),
                Tab(icon: Icon(Icons.graphic_eq, size: 18), text: 'Signal / Acquisition'),
                Tab(icon: Icon(Icons.folder_open_outlined, size: 18), text: 'Data Storage'),
                Tab(icon: Icon(Icons.info_outline, size: 18), text: 'About PyroSync'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. GENERAL & CLINICIAN PROFILE
                PyroCard(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ATTENDING CLINICIAN PROFILE', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 8),
                        const Text('Configured clinician details are automatically applied to electronic signatures and patient reports.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 20),
                        _buildInputField('Full Name', _nameController, 'e.g. Dr. Jane Smith'),
                        _buildInputField('Professional Title', _titleController, 'e.g. Attending Neurologist'),
                        _buildInputField('Institution / Medical Center', _institutionController, 'e.g. Pyromatics Bio Solutions Medical Center'),
                        _buildInputField('Credentials', _credentialsController, 'e.g. MD, PhD'),
                        _buildInputField('Email Address', _emailController, 'e.g. j.smith@pyromaticsbio.com'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                          icon: const Icon(Icons.save, size: 16),
                          label: const Text('Save Clinician Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            ref.read(authEngineProvider.notifier).updateProfile(
                                  fullName: _nameController.text.trim(),
                                  title: _titleController.text.trim(),
                                  institution: _institutionController.text.trim(),
                                  credentials: _credentialsController.text.trim(),
                                  email: _emailController.text.trim(),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Clinician profile updated successfully.')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. APPEARANCE & THEME
                PyroCard(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('APPLICATION THEME & DISPLAY OPTIONS', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 8),
                        const Text('Select a global visual system for the PyroSync Clinical Workspace.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 24),

                        _buildThemeCard(
                          title: 'Clinical Dark Mode (Default Recommended)',
                          description: 'High-contrast obsidian theme optimized for dark electrophysiology rooms and high-density waveform inspection.',
                          isSelected: themeMode == PyroThemeMode.clinicalDark,
                          onTap: () => themeNotifier.setTheme(PyroThemeMode.clinicalDark),
                        ),
                        const SizedBox(height: 12),
                        _buildThemeCard(
                          title: 'Glassmorphic Mode',
                          description: 'Modern glass blur effects with glowing bio-frequency trace accents.',
                          isSelected: themeMode == PyroThemeMode.glassMode,
                          onTap: () => themeNotifier.setTheme(PyroThemeMode.glassMode),
                        ),
                        const SizedBox(height: 12),
                        _buildThemeCard(
                          title: 'Clinical Light Mode',
                          description: 'High-visibility light theme suited for bright clinical examination offices.',
                          isSelected: themeMode == PyroThemeMode.clinicalLight,
                          onTap: () => themeNotifier.setTheme(PyroThemeMode.clinicalLight),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. DEVICE & HARDWARE
                PyroCard(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('HARDWARE CONNECTION & DISCOVERY', style: PyroTypography.heading2(true)),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: PyroColors.medicalBlue, foregroundColor: Colors.black),
                              icon: const Icon(Icons.search, size: 16),
                              label: Text(deviceState.isScanning ? 'Scanning...' : 'Scan For Hardware'),
                              onPressed: deviceState.isScanning ? null : () => deviceNotifier.scanForDevices(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121620),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: deviceState.isConnected
                                  ? PyroColors.statusSuccess
                                  : (deviceState.hasError ? PyroColors.statusDanger : const Color(0xFF1E293B)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    deviceState.isConnected
                                        ? Icons.check_circle
                                        : (deviceState.hasError
                                            ? Icons.warning_amber_rounded
                                            : Icons.electrical_services),
                                    color: deviceState.isConnected
                                        ? PyroColors.statusSuccess
                                        : (deviceState.hasError
                                            ? PyroColors.statusDanger
                                            : PyroColors.statusWarning),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      deviceState.isConnected
                                          ? 'HARDWARE CONNECTED: ${deviceState.activeDeviceInfo?.deviceName}'
                                          : (deviceState.isConnecting
                                              ? 'CONNECTING & VERIFYING HARDWARE...'
                                              : (deviceState.isScanning
                                                  ? 'SCANNING FOR ACQUISITION HARDWARE...'
                                                  : (deviceState.hasError
                                                      ? 'CONNECTION / HANDSHAKE FAILED'
                                                      : 'NO ACQUISITION DEVICE CONNECTED'))),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: deviceState.isConnected
                                            ? PyroColors.statusSuccess
                                            : (deviceState.hasError
                                                ? PyroColors.statusDanger
                                                : Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (deviceState.hasError && deviceState.errorMessage != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: PyroColors.statusDanger.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: PyroColors.statusDanger.withOpacity(0.4)),
                                  ),
                                  child: Text(
                                    deviceState.errorMessage!,
                                    style: const TextStyle(color: PyroColors.statusDanger, fontSize: 12),
                                  ),
                                ),
                              ],
                              if (deviceState.isConnected) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Transport: ${deviceState.activeDeviceInfo?.providerType.name.toUpperCase()} • Sampling Rate: ${deviceState.activeDeviceInfo?.samplingRateHz} Hz • Channels: ${deviceState.activeDeviceInfo?.channelCount}',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hardware Mode: ${deviceState.activeDeviceInfo?.isSimulated == true ? "Virtual Simulator (Dev Mode)" : "Physical Hardware (Verified)"}',
                                  style: TextStyle(
                                    color: deviceState.activeDeviceInfo?.isSimulated == true
                                        ? PyroColors.statusWarning
                                        : PyroColors.statusSuccess,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: PyroColors.statusDanger,
                                    side: const BorderSide(color: PyroColors.statusDanger),
                                  ),
                                  onPressed: () => deviceNotifier.disconnectDevice(),
                                  child: const Text('Disconnect Device'),
                                ),
                              ],
                              if (!deviceState.isConnected && !deviceState.isConnecting) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'No serial or network biosignal acquisition hardware is currently connected. Click "Scan For Hardware" above to enumerate available ports.',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text('DISCOVERED ACQUISITION TRANSPORTS', style: TextStyle(color: PyroColors.medicalBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 12),

                        // 1. Bluetooth LE
                        const Text('Bluetooth Low Energy (BLE):', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        _buildBleList(context, deviceState, deviceNotifier),

                        const SizedBox(height: 16),
                        // 2. Bluetooth Classic / RFCOMM
                        const Text('Bluetooth Classic / RFCOMM (SPP):', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        _buildRfcommList(context, deviceState, deviceNotifier),

                        const SizedBox(height: 16),
                        // 3. USB / Serial
                        const Text('USB / Serial Ports:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        _buildSerialPortList(context, deviceState, deviceNotifier),

                        const SizedBox(height: 16),
                        // 4. Network / Wi-Fi Discovery & Manual Entry
                        const Text('Network / Wi-Fi Biosignal Nodes:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        _buildNetworkNodeList(context, deviceState, deviceNotifier),

                        const SizedBox(height: 24),

                        const Text('POKIDEX ANDROID EEG STIMULATOR (DUAL TRANSPORT RESEARCH)', style: TextStyle(color: PyroColors.medicalBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 12),
                        _buildPokidexSection(context, deviceState, deviceNotifier),

                        const SizedBox(height: 24),

                        const Text('DEVELOPMENT & TESTING SIMULATOR', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF94A3B8), side: const BorderSide(color: Color(0xFF1E293B))),
                          icon: const Icon(Icons.science, size: 16),
                          label: const Text('Enable Virtual NeuroLab Simulator Mode (Dev Only)'),
                          onPressed: () => deviceNotifier.connectSimulationDevice(),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. SIGNAL / ACQUISITION
                PyroCard(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SIGNAL PROCESSING & DSP FILTER PARAMETERS', style: PyroTypography.heading2(true)),
                        const SizedBox(height: 16),
                        _buildDropdownRow('Sampling Frequency', _samplingRate, ['2500 Hz', '1000 Hz', '500 Hz'], (val) => setState(() => _samplingRate = val!)),
                        _buildDropdownRow('Line Noise Notch Filter', _notchFilter, ['50 Hz', '60 Hz', 'Disabled'], (val) => setState(() => _notchFilter = val!)),
                        _buildDropdownRow('High-Pass Cutoff Filter', _highPass, ['0.1 Hz', '0.5 Hz', '1.0 Hz', '2.0 Hz'], (val) => setState(() => _highPass = val!)),
                        _buildDropdownRow('Low-Pass Cutoff Filter', _lowPass, ['30 Hz', '50 Hz', '100 Hz', '200 Hz'], (val) => setState(() => _lowPass = val!)),
                      ],
                    ),
                  ),
                ),

                // 5. DATA STORAGE
                PyroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DATA STORAGE & EDF EXPORT DIRECTORY', style: PyroTypography.heading2(true)),
                      const SizedBox(height: 16),
                      const Text('Local Data Directory Path:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('C:\\Users\\barat\\OneDrive\\Documents\\Pyromatics Bio-Solution\\data\\', style: PyroTypography.monoData(isDark: true, fontSize: 12)),
                    ],
                  ),
                ),

                // 6. ABOUT
                PyroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ABOUT PYROSYNC WORKSPACE', style: PyroTypography.heading2(true)),
                      const SizedBox(height: 16),
                      const Text('PyroSync Clinical Workspace v1.0.0 (Build 2026-08)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      const Text('Pyromatics Bio Solutions — Connecting Brain Signals to Clinical Intelligence', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: PyroColors.medicalBlue, fontSize: 12),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildThemeCard({required String title, required String description, required bool isSelected, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? PyroColors.medicalBlue.withOpacity(0.12) : const Color(0xFF121620),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? PyroColors.medicalBlue : const Color(0xFF1E293B)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? PyroColors.medicalBlue : Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          Radio<bool>(
            value: true,
            groupValue: isSelected,
            activeColor: PyroColors.medicalBlue,
            onChanged: (val) => onTap(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF151C2C),
            style: const TextStyle(color: PyroColors.medicalBlue, fontWeight: FontWeight.bold),
            items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBleList(BuildContext context, DeviceManagerState deviceState, DeviceManagerNotifier deviceNotifier) {
    final bles = deviceState.discoveredDevices
        .where((d) => d.transportCategory == HardwareTransportCategory.ble)
        .toList();

    if (bles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF121620),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Text(
          deviceState.isScanning
              ? 'Scanning nearby Windows Bluetooth LE devices...'
              : 'No Bluetooth LE devices discovered on Windows host. Ensure Bluetooth is ON and click "Scan For Hardware".',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      );
    }

    return Column(
      children: bles.map((device) {
        final isSelected = deviceState.activeDeviceInfo?.deviceId == device.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF121620),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? PyroColors.statusSuccess
                  : (device.isEegServiceDetected ? PyroColors.medicalBlue : const Color(0xFF1E293B)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                        const SizedBox(width: 8),
                        if (device.rssiDbm != null)
                          Text('(${device.rssiDbm} dBm)', style: const TextStyle(color: PyroColors.medicalBlue, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MAC: ${device.portOrAddress} • ${device.statusNote}',
                      style: TextStyle(
                        color: device.isEegServiceDetected ? PyroColors.statusSuccess : const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: device.isEegServiceDetected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? PyroColors.statusSuccess : PyroColors.medicalBlue,
                  foregroundColor: Colors.black,
                ),
                onPressed: deviceState.isConnecting ? null : () => deviceNotifier.connectHardwareDevice(device),
                child: Text(isSelected ? 'Connected' : 'Connect'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRfcommList(BuildContext context, DeviceManagerState deviceState, DeviceManagerNotifier deviceNotifier) {
    final rfcomms = deviceState.discoveredDevices
        .where((d) => d.transportCategory == HardwareTransportCategory.bluetoothClassic)
        .toList();

    if (rfcomms.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF121620),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Text(
          deviceState.isScanning
              ? 'Querying Windows Bluetooth Classic SPP services...'
              : 'No Bluetooth Classic / RFCOMM serial devices paired on Windows.',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      );
    }

    return Column(
      children: rfcomms.map((device) {
        final isSelected = deviceState.activeDeviceInfo?.deviceId == device.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF121620),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? PyroColors.statusSuccess : const Color(0xFF1E293B)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text('Profile: RFCOMM / SPP • ${device.statusNote}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? PyroColors.statusSuccess : PyroColors.medicalBlue,
                  foregroundColor: Colors.black,
                ),
                onPressed: deviceState.isConnecting ? null : () => deviceNotifier.connectHardwareDevice(device),
                child: Text(isSelected ? 'Connected' : 'Connect'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSerialPortList(BuildContext context, DeviceManagerState deviceState, DeviceManagerNotifier deviceNotifier) {
    final serials = deviceState.discoveredDevices
        .where((d) => d.transportCategory == HardwareTransportCategory.usbSerial)
        .toList();

    if (serials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF121620),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Text(
          deviceState.isScanning
              ? 'Enumerating Windows serial ports...'
              : 'No USB serial hardware detected on system. Connect a bio-amplifier and click "Scan For Hardware".',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      );
    }

    return Column(
      children: serials.map((device) {
        final isSelected = deviceState.activeDeviceInfo?.deviceId == device.id;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF121620),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? PyroColors.statusSuccess : const Color(0xFF1E293B)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      '${device.description} • ${device.statusNote ?? "Protocol Handshake Required"}',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? PyroColors.statusSuccess : PyroColors.medicalBlue,
                  foregroundColor: Colors.black,
                ),
                onPressed: deviceState.isConnecting ? null : () => deviceNotifier.connectHardwareDevice(device),
                child: Text(isSelected ? 'Connected' : 'Connect'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNetworkNodeList(BuildContext context, DeviceManagerState deviceState, DeviceManagerNotifier deviceNotifier) {
    final networks = deviceState.discoveredDevices
        .where((d) => d.transportCategory == HardwareTransportCategory.network)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (networks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF121620),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Text(
              deviceState.isScanning
                  ? 'Listening for UDP subnet discovery responses...'
                  : 'No network acquisition nodes discovered via UDP broadcast.',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          )
        else
          Column(
            children: networks.map((device) {
              final isSelected = deviceState.activeDeviceInfo?.deviceId == device.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF121620),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? PyroColors.statusSuccess : const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('Endpoint: ${device.portOrAddress} • ${device.description}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? PyroColors.statusSuccess : PyroColors.medicalBlue,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: deviceState.isConnecting ? null : () => deviceNotifier.connectHardwareDevice(device),
                      child: Text(isSelected ? 'Connected' : 'Connect'),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        // Manual Network Entry Form
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF121620),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _ipController,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'Device IP Address',
                    labelStyle: TextStyle(color: PyroColors.medicalBlue, fontSize: 11),
                    hintText: 'e.g. 192.168.1.42',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    labelStyle: TextStyle(color: PyroColors.medicalBlue, fontSize: 11),
                    hintText: '5000',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PyroColors.medicalBlue,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.wifi, size: 16),
                label: const Text('Test & Connect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: deviceState.isConnecting
                    ? null
                    : () {
                        final ip = _ipController.text.trim();
                        final port = int.tryParse(_portController.text.trim()) ?? 5000;
                        if (ip.isNotEmpty) {
                          deviceNotifier.connectManualNetworkDevice(ip, port);
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPokidexSection(BuildContext context, DeviceManagerState deviceState, DeviceManagerNotifier deviceNotifier) {
    final mgr = deviceNotifier.pokidexManager;
    final isWifiConnected = mgr.wifiTransport.isConnected;
    final isBleConnected = mgr.bleTransport.isConnected;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121620),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PyroColors.medicalBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pokidex Android EEG Stimulator — Concurrent Research Transports',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Streams real-time JSON SignalFrames concurrently over Wi-Fi (WebSocket ws://<IP>:8765) and Bluetooth LE (Service 0000fe50, Notify 0000fe51).',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
          const SizedBox(height: 12),

          // Wi-Fi Controls
          Row(
            children: [
              Expanded(
                child: Text(
                  '1. Wi-Fi WebSocket: ${isWifiConnected ? "CONNECTED" : "DISCONNECTED"}',
                  style: TextStyle(
                    color: isWifiConnected ? PyroColors.statusSuccess : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWifiConnected ? PyroColors.statusDanger : PyroColors.medicalBlue,
                  foregroundColor: isWifiConnected ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  if (isWifiConnected) {
                    deviceNotifier.disconnectPokidexWifi();
                  } else {
                    final ip = _ipController.text.trim();
                    deviceNotifier.connectPokidexWifi(ip.isNotEmpty ? ip : '192.168.1.42', port: 8765);
                  }
                },
                child: Text(isWifiConnected ? 'Disconnect Wi-Fi' : 'Connect Wi-Fi (ws://:8765)'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // BLE Controls
          Row(
            children: [
              Expanded(
                child: Text(
                  '2. Bluetooth LE (FE50/FE51 Notify): ${isBleConnected ? "CONNECTED" : "DISCONNECTED"}',
                  style: TextStyle(
                    color: isBleConnected ? PyroColors.statusSuccess : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBleConnected ? PyroColors.statusDanger : PyroColors.medicalBlue,
                  foregroundColor: isBleConnected ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  if (isBleConnected) {
                    deviceNotifier.disconnectPokidexBle();
                  } else {
                    deviceNotifier.connectPokidexBle('00:1A:7D:DA:71:13');
                  }
                },
                child: Text(isBleConnected ? 'Disconnect BLE' : 'Connect BLE (FE50/FE51)'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text('CONCURRENT RESEARCH METRICS & LATENCY COMPARISON:', style: TextStyle(color: PyroColors.medicalBlue, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 8),

          // Side-by-Side Comparison Metrics Table
          Row(
            children: [
              Expanded(
                child: _buildTransportStatsCard('Wi-Fi (WebSocket)', mgr.wifiStats, PyroColors.medicalBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTransportStatsCard('Bluetooth LE (FE51 Notify)', mgr.bleStats, const Color(0xFFA855F7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportStatsCard(String title, TransportStats stats, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 6),
          Text('Frames Rx: ${stats.framesReceived}', style: const TextStyle(color: Colors.white, fontSize: 11)),
          Text('Jitter: ${stats.jitterMs.toStringAsFixed(2)} ms', style: const TextStyle(color: Colors.white, fontSize: 11)),
          Text('Dropped Sequences: ${stats.droppedSequenceFrames}', style: const TextStyle(color: Colors.white, fontSize: 11)),
          Text('Connection Events: ${stats.connectionEventsCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}
