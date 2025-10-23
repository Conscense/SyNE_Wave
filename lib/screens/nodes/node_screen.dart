import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../../constants.dart';
import '../../main.dart';
import '../../models/chat.dart';

class NodesScreen extends StatefulWidget {
  const NodesScreen({super.key});

  @override
  State<NodesScreen> createState() => _NodesScreenState();
}

class _NodesScreenState extends State<NodesScreen> {
  bool gridView = true;

  String? connectedNodeName;
  List<Map<String, String>> discoveredNodes = [];
  List<Map<String, String>> people = [];

  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void initState() {
    super.initState();
    _updateNodes();
    _listenForPeople();
  }

  Future<void> _updateNodes() async {
    final ssid = await _networkInfo.getWifiName();
    setState(() {
      connectedNodeName = ssid ?? "Not connected";
    });

    // For simplicity, let's assume ESP nodes broadcast their SSIDs in a known format
    final List<String> availableNodes = []; // implement your scanning logic or ESP broadcast
    setState(() {
      discoveredNodes = availableNodes
          .where((n) => n != ssid)
          .map((n) => {"name": n, "status": "Available"})
          .toList();
    });
  }

  void _listenForPeople() {
    espClient.messages.listen((raw) {
      try {
        final Map<String, dynamic> doc = jsonDecode(raw);
        final String type = doc['type'];

        if (type == 'new_user') {
          final userId = doc['userId'];
          if (!people.any((p) => p['name'] == userId)) {
            setState(() {
              people.add({"name": userId, "status": "Online"});
            });
          }
        } else if (type == 'user_left') {
          final userId = doc['userId'];
          setState(() {
            people.removeWhere((p) => p['name'] == userId);
          });
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ConnectedNodeBar(name: connectedNodeName ?? "None"),
              const SizedBox(height: 8),
              OtherNodesPill(nodes: discoveredNodes),
              const SizedBox(height: 16),
              PeopleSection(
                people: people,
                gridView: gridView,
                onToggle: (value) => setState(() => gridView = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectedNodeBar extends StatelessWidget {
  final String name;
  const ConnectedNodeBar({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kItemBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kDarkBackground, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class OtherNodesPill extends StatelessWidget {
  final List<Map<String, String>> nodes;
  const OtherNodesPill({required this.nodes, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (_) => DiscoveredNodesSheet(nodes: nodes),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Text("Other Nodes", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class PeopleSection extends StatelessWidget {
  final List<Map<String, String>> people;
  final bool gridView;
  final ValueChanged<bool> onToggle;

  const PeopleSection({
    required this.people,
    required this.gridView,
    required this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "People Nearby",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GridListToggle(gridView: gridView, onToggle: onToggle),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: gridView
                ? GridView.builder(
              itemCount: people.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final person = people[index];
                return ProfileCard(name: person["name"]!, status: person["status"]!);
              },
            )
                : ListView.builder(
              itemCount: people.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final person = people[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: SizedBox(
                    height: 60,
                    child: ProfileCard(name: person["name"]!, status: person["status"]!, compact: true),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GridListToggle extends StatelessWidget {
  final bool gridView;
  final ValueChanged<bool> onToggle;

  const GridListToggle({required this.gridView, required this.onToggle, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(color: kItemBackground, borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(icon: Icons.grid_view, active: gridView, onTap: () => onToggle(true)),
          _ToggleButton(icon: Icons.view_list, active: !gridView, onTap: () => onToggle(false)),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleButton({required this.icon, required this.active, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 32,
        decoration: BoxDecoration(color: active ? kPrimaryColor : Colors.transparent, borderRadius: BorderRadius.circular(50)),
        alignment: Alignment.center,
        child: Icon(icon, color: active ? Colors.white : Colors.white70, size: 18),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String status;
  final bool compact;

  const ProfileCard({required this.name, required this.status, this.compact = false, super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = status.toLowerCase() == "online";

    if (compact) {
      return Container(
        decoration: BoxDecoration(
          color: kItemBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isOnline ? Colors.greenAccent : Colors.white.withOpacity(0.2), width: 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(radius: 20, backgroundColor: isOnline ? Colors.greenAccent : Colors.grey, child: Text(name[0], style: const TextStyle(color: Colors.white))),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6)),
              child: const Text("Add", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: kItemBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOnline ? Colors.greenAccent : Colors.white.withOpacity(0.2), width: 2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 40, backgroundColor: isOnline ? Colors.greenAccent : Colors.grey, child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 24))),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(status, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8)), child: const Text("Add", style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class DiscoveredNodesSheet extends StatelessWidget {
  final List<Map<String, String>> nodes;
  const DiscoveredNodesSheet({required this.nodes, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkBackground,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Discovered Nodes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...nodes.map((node) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(color: kItemBackground, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.2), width: 2)),
              alignment: Alignment.center,
              child: Text(node["name"]!, style: const TextStyle(color: Colors.white)),
            ),
          )),
        ],
      ),
    );
  }
}
