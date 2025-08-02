import 'package:eco_system_things/classes/UserManager.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class Post {
  late String id;
  late String userId;
  late String wilaya;
  late String polutionType;
  late String difLVL;
  late String title;
  late double lat;
  late double lon;
  late String description;
  late List<String> pictures;
  late String status;
  late List<String> members = [];

  Post({
    required this.id,
    required this.userId,
    required this.wilaya,
    required this.title,
    required this.description,
    required this.pictures,
    required this.polutionType,
    required this.difLVL,
    required this.status,
    required this.lat,
    required this.lon,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final geo = json['geolocal'] ?? {};
    final pics = json['pictures'];

    return Post(
      id: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      wilaya: json['wilaya'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      polutionType: json['polutionType'] ?? '',
      difLVL: json['difLVL'] ?? '',
      status: json['status'] ?? '',
      lat: (geo['lat'] ?? 0).toDouble(),
      lon: (geo['lng'] ?? 0).toDouble(),
      pictures: pics == null
          ? []
          : List<String>.from(pics is List ? pics : [pics.toString()]),
    );
  }

  Widget postWidget() {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFc3ece8),
            borderRadius: BorderRadius.circular(25),
          ),
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            pictures.isNotEmpty
                                ? pictures[0]
                                : "https://placehold.co/120x120",
                          ),
                          fit: BoxFit.cover,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 130,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xA6000000),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color.fromARGB(127, 0, 0, 0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Row(
                              children: [
                                const Spacer(),
                                _infoBadge(difLVL, _difColor(difLVL)),
                                const SizedBox(width: 8),
                                _infoBadge(polutionType, _pollutionColor(polutionType)),
                                const SizedBox(width: 8),
                                _infoBadge(status, _statusColor(status)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
                        );
                        _launchUrl(url);
                      },
                      child: _actionButton("SEE MAP"),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final selectedDays = await showDialog<List<String>>(
                          context: context,
                          builder: (_) => const WeekdaySelectorDialog(),
                        );
                        if (selectedDays != null) {
                          await UserManager().addUserToPostMembers(postId: id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF91d5d8),
                              content: Text(
                                'You’re free on: ${selectedDays.join(', ')}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      child: _actionButton("JOIN"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget chatTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: pictures.isNotEmpty
              ? Image.network(pictures[0], width: 48, height: 48, fit: BoxFit.cover)
              : Container(
                  width: 48,
                  height: 48,
                  color: const Color(0xFFe2dedd),
                  child: const Icon(Icons.image_not_supported, size: 24),
                ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: const Color(0xFFc3ece8),
        onTap: () {
          // Handle chat open
        },
      ),
    );
  }

  Widget _actionButton(String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF95D4DB),
        borderRadius: BorderRadius.circular(25),
      ),
      height: 40,
      width: 175,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  Widget _infoBadge(String text, Color color) {
    return Row(
      children: [
        Text(text, style: TextStyle(color: color)),
        const SizedBox(width: 4),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: color,
          ),
          width: 20,
          height: 20,
        ),
      ],
    );
  }

  Color _difColor(String lvl) {
    switch (lvl) {
      case "Hard":
        return const Color(0xFFD80A0A);
      case "Easy":
        return const Color(0xFF0A33D8);
      default:
        return const Color(0xFFD8930A);
    }
  }

  Color _pollutionColor(String type) {
    switch (type) {
      case "Water":
        return const Color(0xFF0973A1);
      default:
        return const Color(0xFFB29380);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case "Waiting":
        return const Color(0xFFD8930A);
      case "In Work":
        return const Color(0xFF24A75E);
      default:
        return const Color(0xFF000000);
    }
  }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}


class WeekdaySelectorDialog extends StatefulWidget {
  const WeekdaySelectorDialog({super.key});

  @override
  State<WeekdaySelectorDialog> createState() => _WeekdaySelectorDialogState();
}

class _WeekdaySelectorDialogState extends State<WeekdaySelectorDialog> {
  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Set<String> selected = {};
  bool hasTools = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF95d4db),
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Available Days",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: weekdays.length,
                itemBuilder: (context, index) {
                  final day = weekdays[index];
                  return CheckboxListTile(
                    title: Text(day),
                    value: selected.contains(day),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selected.add(day);
                        } else {
                          selected.remove(day);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const Divider(color: Colors.white),
            CheckboxListTile(
              title: const Text("I have Tools"),
              value: hasTools,
              onChanged: (checked) {
                setState(() {
                  hasTools = checked ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, selected.toList());
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
