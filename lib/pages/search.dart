import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:EventON/pages/Eventdetails.dart';
import 'package:EventON/pages/communitypage.dart';
import '../org/orgprofile.dart';
import '../Utiles/app_styles.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late String searchQuery;

  @override
  void initState() {
    super.initState();
    searchQuery = '';
  }

  Future<List<DocumentSnapshot>> _fetchData() async {
    // Fetch all documents from 'users' and 'EVENTS' collections
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final eventsSnapshot = await FirebaseFirestore.instance.collection('EVENTS').get();

    // Filter users based on search query and role
    final filteredUsers = usersSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['name']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) == true &&
          data['roll'] == "Community";
    }).toList();

    // Filter events based on search query
    final filteredEvents = eventsSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['eventName']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) == true;
    }).toList();

    // Combine the results from both collections
    return [...filteredUsers, ...filteredEvents];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Search ",
                        hintStyle: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 30.0, color: Colors.white),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: searchQuery.isEmpty
          ? const Center(
        child: Text(
          'Search Events and Communities ;)',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14, // You can adjust the font size as needed
          ),
        ),
      )
          : FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No results found'));
          } else {
            final combinedResults = snapshot.data!;

            return ListView.builder(
              itemCount: combinedResults.length,
              itemBuilder: (context, index) {
                final data = combinedResults[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    if (combinedResults[index].reference.parent.id == 'EVENTS') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetails(
                            eventKey: combinedResults[index].id, // Pass the document ID
                          ),
                        ),
                      );
                    } else {
                      String userId = combinedResults[index].id; // Get the user ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityPage(
                            communityId: userId,
                          ),
                        ),
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(
                      combinedResults[index].reference.parent.id == 'users'
                          ? data['name']
                          : data['eventName'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      combinedResults[index].reference.parent.id == 'EVENTS'
                          ? data['eventLocation']
                          : data['collegeName'] ?? 'N/A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
