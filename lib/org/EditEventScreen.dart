import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _deadlineController;
  late TextEditingController _ticketPriceController;
  late TextEditingController _upiIDController;
  String? _selectedEventType;
  String? _selectedCommunityType;
  String? _selectedEventPrice;
  String? _selectedEventLevel;
  bool _isRegistrationOpen = true;
  File? _image;
  String? _imageUrl;
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
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
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
          _selectedEventLevel=data['eventLevel']??'';

          // Parse and format dates
          _startDateController.text = _formatDate(data['eventDate']);
          _endDateController.text = _formatDate(data['endDate']);
          _deadlineController.text = _formatDate(data['deadline']);

          _contactController.text = data['eventContact'] ?? '';
          _detailsController.text = data['description'] ?? '';
          _locationController.text = data['eventLocation'] ?? '';
          _selectedEventPrice = data['eventPrice'] ?? '';
          _selectedEventLevel=data['eventLevel']??'';
          _whatsappLinkController.text = data['whatsappLink'] ?? '';
          _selectedCommunityType = data['communityType'] ?? '';
          _imageUrl = data['imageUrl'] ?? '';
          _isRegistrationOpen = data['isRegistrationOpen'] ?? true;
        });
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("Failed to fetch event details: $e");
    }
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate().toString().substring(0, 10); // Format as yyyy-MM-dd
    } else if (date is String) {
      return date;
    } else {
      return '';
    }
  }


  Future<String?> _uploadImage(File image) async {
    try {
      String fileName =
          'EVENTS/${widget.eventKey}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(image);

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  void _pickPosterImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = _imageUrl;

      if (_image != null) {
        _imageUrl = await _uploadImage(_image!);
      }

      if (imageUrl != null || _imageUrl != null) {
        await FirebaseFirestore.instance
            .collection('EVENTS')
            .doc(widget.eventKey)
            .update({
          'eventName': _nameController.text,
          'eventType': _selectedEventType,
          'eventLevel':_selectedEventLevel,
          'eventDate': _startDateController.text,
          'endDate': _endDateController.text,
          'eventContact': _contactController.text,
          'description': _detailsController.text,
          'eventLocation': _locationController.text,
          'eventPrice': _selectedEventPrice,
          'eventLevel':_selectedEventLevel,
          'whatsappLink': _whatsappLinkController.text,
          'communityType': _selectedCommunityType,
          'deadline': _deadlineController.text,
          'isRegistrationOpen': _isRegistrationOpen,
          if (imageUrl != null) 'imageUrl': imageUrl,
        });
        Navigator.pop(context);
      } else {
        print("Image upload failed, changes not saved.");
      }
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField("Event Name", _nameController),
                SizedBox(height: 16),
                _buildCommunityTypeDropdown(),
                if (_selectedCommunityType == 'Other')
                  _buildTextField("Specify Community", _typeController),
                SizedBox(height: 16),
                _buildEventLevelDropdown(),
                SizedBox(height: 16),
                _buildEventTypeDropdown(),
                if (_selectedEventType == 'Other')
                  _buildTextField("Specify Event Type", _typeController),
                SizedBox(height: 16),
                _buildDatePicker("Start Date", _startDateController),
                SizedBox(height: 16),
                _buildDatePicker("End Date", _endDateController),
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
                _buildImagePickerSection(),  // Updated to include the new section
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

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = pickedDate.toString().substring(0, 10);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
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
              contentPadding:
              EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    List<String> eventTypes = [
      'Conference',
      'Workshop',
      'Seminar',
      'Webinar',
      'Other'
    ];
    return DropdownButtonFormField<String>(
      value: eventTypes.contains(_selectedEventType)
          ? _selectedEventType
          : eventTypes.first,
      decoration: InputDecoration(
        labelText: "Event Type",
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
      items: eventTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedEventType = newValue;
        });
      },
    );
  }
  Widget _buildEventLevelDropdown() {
    List<String> eventLevels = [
      'Level I',
      'Level II',
      'Level III',
      'Level IV',
      'Level V',
    ];
    return DropdownButtonFormField<String>(
      value: eventLevels.contains(_selectedEventLevel)
          ? _selectedEventLevel
          : eventLevels.first,
      decoration: InputDecoration(
        labelText: "Event Level",
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
      items: eventLevels.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedEventLevel = newValue;
        });
      },
    );
  }

  Widget _buildCommunityTypeDropdown() {
    List<String> communityTypes = [
      'IEEE',
      'IEDC',
      'CSI',
      'Other'
    ];
    return DropdownButtonFormField<String>(
      value: communityTypes.contains(_selectedCommunityType)
          ? _selectedCommunityType
          : communityTypes.first,
      decoration: InputDecoration(
        labelText: "Community Type",
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
      items: communityTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCommunityType = newValue;
        });
      },
    );
  }

  Widget _buildEventPriceDropdown() {
    List<String> eventPrices = ['Free', 'Paid'];
    return DropdownButtonFormField<String>(
      value: eventPrices.contains(_selectedEventPrice)
          ? _selectedEventPrice
          : eventPrices.first,
      decoration: InputDecoration(
        labelText: "Event Price",
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
      items: eventPrices.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedEventPrice = newValue;
          _isPaidSelected = newValue == 'Paid';
        });
      },
    );
  }


  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickPosterImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
          image: _image != null
              ? DecorationImage(
            image: FileImage(_image!),
            fit: BoxFit.cover,
          )
              : (_imageUrl != null && _imageUrl!.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(_imageUrl!),
            fit: BoxFit.cover,
          )
              : null),
        ),
        child: _image == null && _imageUrl == null
            ? Center(child: Icon(Icons.add_a_photo))
            : null,
      ),
    );
  }
  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Edit Poster",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8), // Add some spacing between the label and the image picker
        _buildImagePicker(),
      ],
    );
  }

}