import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const WashWaitApp());
}

class WashWaitApp extends StatelessWidget {
  const WashWaitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WashWait MVP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const WashWaitHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Machine {
  final int id;
  bool isAvailable;
  DateTime? endTime;
  String? currentUser;

  Machine({required this.id, this.isAvailable = true, this.endTime, this.currentUser});
}

class WashWaitHome extends StatefulWidget {
  const WashWaitHome({super.key});

  @override
  State<WashWaitHome> createState() => _WashWaitHomeState();
}

class _WashWaitHomeState extends State<WashWaitHome> {
  final TextEditingController _nameController = TextEditingController();
  Timer? _timer;

  // Initializing 3 machines for the MVP
  List<Machine> machines = [
    Machine(id: 1),
    Machine(id: 2),
    Machine(id: 3),
  ];

  // Global Queue
  List<String> queue = [];

  @override
  void initState() {
    super.initState();
    // Refresh the UI every second to update countdown timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkMachineTimers();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _checkMachineTimers() {
    bool needsUpdate = false;
    final now = DateTime.now();

    for (var machine in machines) {
      if (!machine.isAvailable && machine.endTime != null) {
        if (now.isAfter(machine.endTime!)) {
          // Wash is done, free the machine
          machine.isAvailable = true;
          machine.endTime = null;
          machine.currentUser = null;
          needsUpdate = true;
        } else {
          // Just trigger a rebuild to update the clock text
          needsUpdate = true; 
        }
      }
    }
    if (needsUpdate) setState(() {});
  }

  void _joinQueue(String name) {
    if (name.trim().isEmpty) return;
    setState(() {
      queue.add(name.trim());
      _nameController.clear();
    });
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  void _assignNextInQueue(Machine machine) {
    if (queue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Queue is empty!')),
      );
      return;
    }

    setState(() {
      String nextStudent = queue.removeAt(0); // Pop front of queue
      machine.isAvailable = false;
      machine.currentUser = nextStudent;
      // Set to 2 minutes for interview demo purposes (normally 45 mins)
      machine.endTime = DateTime.now().add(const Duration(minutes: 2)); 
    });
  }

  String _formatTimeLeft(DateTime endTime) {
    final diff = endTime.difference(DateTime.now());
    if (diff.isNegative) return "00:00";
    final m = diff.inMinutes.toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WashWait - Block A', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Washing Machines", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Machines Grid
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  final m = machines[index];
                  return Card(
                    color: m.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_laundry_service, size: 40, color: m.isAvailable ? Colors.green : Colors.red),
                          const SizedBox(height: 8),
                          Text("Machine ${m.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (!m.isAvailable) ...[
                            const SizedBox(height: 4),
                            Text(m.currentUser!, style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis)),
                            Text(_formatTimeLeft(m.endTime!), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ] else ...[
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _assignNextInQueue(m),
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                              child: const Text("Assign Next", style: TextStyle(fontSize: 12)),
                            )
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text("Global Queue", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Queue List
            Expanded(
              child: queue.isEmpty
                  ? const Center(child: Text("No one is waiting in the queue.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: queue.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(child: Text("${index + 1}")),
                          title: Text(queue[index]),
                          trailing: const Icon(Icons.person),
                        );
                      },
                    ),
            ),
            const Divider(),
            // Join Queue Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Enter Registration No. / Name",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _joinQueue,
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: () => _joinQueue(_nameController.text),
                  child: const Icon(Icons.add),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
