import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import 'package:universe2024/pages/Eventdetails.dart';
import 'package:universe2024/pages/communitypage.dart';
import '../Utiles/app_styles.dart';

class searchpage extends StatefulWidget {
  const searchpage({Key? key}) : super(key: key);

  @override
  State<searchpage> createState() => _searchpageState();
}

class _searchpageState extends State<searchpage> {
  late String searchQuery;

  @override
  void initState() {
    super.initState();
    searchQuery = '';
  }

  Future<List<DocumentSnapshot>> _fetchData() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final eventsSnapshot = await FirebaseFirestore.instance.collection('event').get();

    final filteredUsers = usersSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) && data['roll'] == "Community";
    }).toList();

    final filteredEvents = eventsSnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['eventName']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    return [...filteredUsers, ...filteredEvents];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Styles.blueColor,
                  Styles.lblueColor,
                  Styles.yellowColor
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(23),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Search",
                      hintStyle: TextStyle(fontSize: 20.0),
                      prefixIcon: Icon(Icons.search, size: 30.0),
                      prefixIconColor: Colors.black38,
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No results found'),
            );
          } else {
            final combinedResults = snapshot.data!;

            return ListView.builder(
              itemCount: combinedResults.length,
              itemBuilder: (context, index) {
                final data = combinedResults[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    if (combinedResults[index].reference.parent.id == 'event') {
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
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      combinedResults[index].reference.parent.id == 'event'
                          ? data['eventLocation']
                          : data['collegeName'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
