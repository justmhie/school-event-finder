import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient supabase = Supabase.instance.client;

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  List<dynamic> events = [];
  Map<String, dynamic> organizations = {};

  @override
  void initState() {
    super.initState();
    fetchEventsAndOrgs();
  }

  Future<void> fetchEventsAndOrgs() async {
    try {
      final eventResponse = await supabase.from('events').select();
      final orgResponse = await supabase.from('organizations').select();

      final Map<String, dynamic> orgMap = {
        for (var org in orgResponse) org['uid']: org,
      };

      setState(() {
        events = eventResponse;
        organizations = orgMap;
      });
    } catch (e) {
      debugPrint('Error fetching events or organizations: $e');
    }
  }

  String formatDateRange(String? start, String? end) {
    if (start == null || end == null) return '';

    final DateTime startDate = DateTime.parse(start);
    final DateTime endDate = DateTime.parse(end);

    final String startFormatted = DateFormat('MMMM d, yyyy h:mm a').format(startDate);
    final String endFormatted = DateFormat('MMMM d, yyyy h:mm a').format(endDate);

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      // Same day
      return '${DateFormat('MMMM d, yyyy').format(startDate)} • ${DateFormat('h:mm a').format(startDate)} - ${DateFormat('h:mm a').format(endDate)}';
    } else {
      // Different day
      return '$startFormatted - $endFormatted';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: events.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final event = events[index];
                  final org = organizations[event['orguid']];

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(event['title'] ?? ''),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${event['description'] ?? 'No description.'}'),
                                const SizedBox(height: 12),
                                Text('Location: ${event['location'] ?? 'TBA'}'),
                                Text('Start: ${event['datetimestart'] ?? ''}'),
                                Text('End: ${event['datetimeend'] ?? ''}'),
                                Text('Type: ${event['type'] ?? ''}'),
                                Text('Tags: ${event['tags'] ?? ''}'),
                                Text('Status: ${event['status'] ?? ''}'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.network(
                              event['eventbanner'] ?? '',
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: org?['logo'] != null
                                  ? NetworkImage(org['logo'])
                                  : null,
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  event['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  event['location'] ?? '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatDateRange(event['datetimestart'], event['datetimeend']),
                                  style: const TextStyle(fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                // TYPE first
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    event['type'] ?? '',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // THEN tags below
                                Text(
                                  event['tags'] ?? '',
                                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
