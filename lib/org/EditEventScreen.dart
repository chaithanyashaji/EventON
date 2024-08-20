import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditEventScreen extends StatefulWidget {
  final String eventKey;

  const EditEventScreen({Key? key, required this.eventKey}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _contactController;
  late TextEditingController _detailsController;
  late TextEditingController _locationController;
  late TextEditingController _whatsappLinkController;
  late TextEditingController _deadlineController;
  late TextEditingController _ticketPriceController;
  List<String> _selectedDates = [];
  String _selectedEventType = '';
  String _selectedCommunityType = '';
  String _selectedEventPrice = '';
  bool _isRegistrationOpen = true;
  File? _posterImage;
  String? _posterImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isPaidSelected = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _typeController = TextEditingController();
    _contactController = TextEditingController();
    _detailsController = TextEditingController();
    _locationController = TextEditingController();
    _whatsappLinkController = TextEditingController();
    _deadlineController = TextEditingController();
    _ticketPriceController = TextEditingController();
    _fetchEventDetails();
  }

  void _fetchEventDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('EVENTS')
          .doc(widget.eventKey)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['eventName'] ?? '';
          _selectedEventType = data['eventType'] ?? '';
          _selectedDates = List<String>.from(data['eventDates'] ?? []);
          _contactController.text = data['eventContact'] ?? '';
          _detailsController.text = data['description'] ?? '';
          _locationController.text = data['eventLocation'] ?? '';
          _selectedEventPrice = data['eventPrice'] ?? '';
          _whatsappLinkController.text = data['whatsappLink'] ?? '';
          _selectedCommunityType = data['communityType'] ?? '';
          _deadlineController.text = data['deadlineDate'] ?? '';
          _posterImageUrl = data['eventPosterUrl'] ?? '';
          _isPaidSelected = _selectedEventPrice == 'Paid';
          _isRegistrationOpen = data['isRegistrationOpen'] ?? true;
        });
      } else {
        // Handle the case when the document does not exist.
        print("Document does not exist");
      }
    } catch (e) {
      print("Failed to fetch event details: $e");
      // You can also show an error message to the user here if needed.
    }
  }

  void _pickPosterImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _posterImage = File(image.path);
      });
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      String? posterImageUrl = _posterImageUrl;

      if (_posterImage != null) {
        // Add your image upload logic here and get the URL
        posterImageUrl = 'path/to/your/uploaded/image'; // Replace with actual URL
      }

      await FirebaseFirestore.instance
          .collection('EVENTS')
          .doc(widget.eventKey)
          .update({
        'eventName': _nameController.text,
        'eventType': _selectedEventType,
        'eventDates': _selectedDates,
        'eventContact': _contactController.text,
        'description': _detailsController.text,
        'eventLocation': _locationController.text,
        'eventPrice': _selectedEventPrice,
        'ticketPrice': _isPaidSelected ? _ticketPriceController.text : null,
        'whatsappLink': _whatsappLinkController.text,
        'communityType': _selectedCommunityType,
        'deadlineDate': _deadlineController.text,
        'isRegistrationOpen': _isRegistrationOpen,
        if (posterImageUrl != null) 'eventPosterUrl': posterImageUrl,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double fieldWidth = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Event Details"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Event Name", _nameController),
                SizedBox(height: 16),
                _buildCommunityTypeDropdown(),
                if (_selectedCommunityType == 'Other')
                  _buildTextField("Specify Community", _typeController),
                SizedBox(height: 16),
                _buildEventTypeDropdown(),
                if (_selectedEventType == 'Other')
                  _buildTextField("Specify Event Type", _typeController),
                SizedBox(height: 16),
                _buildMultipleDatePicker(),
                SizedBox(height: 16),
                _buildDatePicker("Deadline Date", _deadlineController),
                SizedBox(height: 16),
                _buildTextField("Contact", _contactController),
                SizedBox(height: 16),
                _buildTextField("Description", _detailsController, maxLines: 3),
                SizedBox(height: 16),
                _buildTextField("Location", _locationController),
                SizedBox(height: 16),
                _buildEventPriceDropdown(),
                if (_isPaidSelected)
                  _buildTextField("Enter Price", _ticketPriceController),
                SizedBox(height: 16),
                _buildTextField("WhatsApp Group Link", _whatsappLinkController),
                SizedBox(height: 16),
                _buildImagePicker(),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text("Registration Open"),
                  value: _isRegistrationOpen,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() {
                      _isRegistrationOpen = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text("Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: Size(fieldWidth, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.black),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildMultipleDatePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Stack(
        children: [
          TextFormField(
            controller: TextEditingController(text: _selectedDates.join(', ')),
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Event Date(s)',
              labelStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2)
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black, width: 2)
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
            onTap: () async {
              final DateTimeRange? pickedDateRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDateRange != null) {
                final selectedDates = _getFormattedDateList(pickedDateRange);
                setState(() {
                  _selectedDates = selectedDates;
                });
              }
            },
          ),
          Positioned(
            right: 5,
            top: 10,
            child: IconButton(
              icon: Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                setState(() {
                  _selectedDates.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getFormattedDateList(DateTimeRange dateRange) {
    List<String> formattedDates = [];
    for (DateTime date = dateRange.start;
    date.isBefore(dateRange.end.add(const Duration(days: 1)));
    date = date.add(const Duration(days: 1))) {
      formattedDates.add(
        '${date.day}-${date.month}-${date.year}',
      );
    }
    return formattedDates;
  }

  Widget _buildDatePicker(
      String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          setState(() {
            controller.text =
            '${pickedDate.day}-${pickedDate.month}-${pickedDate.year}';
          });
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(label, controller),
      ),
    );
  }

  Widget _buildCommunityTypeDropdown() {
    List<String> communityTypes = [
      "IEEE",
      "IEDC",
      "CSI",
      "Other"
    ];
    return _buildDropdown(
      label: 'Community Type',
      value: _selectedCommunityType,
      items: communityTypes,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCommunityType = newValue!;
        });
      },
    );
  }

  Widget _buildEventTypeDropdown() {
    List<String> eventTypes = [
      "Workshop",
      "Webinar",
      "Competition",
      "Other"
    ];
    return _buildDropdown(
      label: 'Event Type',
      value: _selectedEventType,
      items: eventTypes,
      onChanged: (String? newValue) {
        setState(() {
          _selectedEventType = newValue!;
        });
      },
    );
  }

  Widget _buildEventPriceDropdown() {
    List<String> eventPrices = ["Free", "Paid"];
    return _buildDropdown(
      label: 'Event Price',
      value: _selectedEventPrice,
      items: eventPrices,
      onChanged: (String? newValue) {
        setState(() {
          _selectedEventPrice = newValue!;
          _isPaidSelected = newValue == "Paid";
        });
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        hint: Text(label),
        decoration: InputDecoration(border: InputBorder.none),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal:5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Change Poster:",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickPosterImage,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                image: _posterImage != null
                    ? DecorationImage(
                  image: FileImage(_posterImage!),
                  fit: BoxFit.cover,
                )
                    : _posterImageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(_posterImageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _posterImage == null && _posterImageUrl == null
                  ? const Center(
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.black,
                  size: 50,
                ),
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

}
