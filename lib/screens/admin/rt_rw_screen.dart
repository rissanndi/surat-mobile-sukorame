import 'package:flutter/material.dart';
import '../../models/rt_rw_model.dart';
import '../../services/rt_rw_service.dart';

class RTRWScreen extends StatefulWidget {
  const RTRWScreen({super.key});

  @override
  State<RTRWScreen> createState() => _RTRWScreenState();
}

class _RTRWScreenState extends State<RTRWScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RTRWService _rtrwService = RTRWService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RT/RW Aktif'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'RT'),
            Tab(text: 'RW'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // RT Tab
          StreamBuilder<List<RT>>(
            stream: _rtrwService.getActiveRT(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final rtList = snapshot.data ?? [];
              
              if (rtList.isEmpty) {
                return const Center(child: Text('Tidak ada RT yang aktif'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: rtList.length,
                itemBuilder: (context, index) {
                  final rt = rtList[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      title: Text(rt.nama),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RT ${rt.nomorRt}'),
                          Text('Periode: ${rt.periodeMulai.split('T')[0]} - ${rt.periodeAkhir.split('T')[0]}'),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text('RT'),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // RW Tab
          StreamBuilder<List<RW>>(
            stream: _rtrwService.getActiveRW(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final rwList = snapshot.data ?? [];
              
              if (rwList.isEmpty) {
                return const Center(child: Text('Tidak ada RW yang aktif'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: rwList.length,
                itemBuilder: (context, index) {
                  final rw = rwList[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      title: Text(rw.nama),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RW ${rw.nomorRw}'),
                          Text('Periode: ${rw.periodeMulai.split('T')[0]} - ${rw.periodeAkhir.split('T')[0]}'),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[700],
                        child: Text('RW'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}