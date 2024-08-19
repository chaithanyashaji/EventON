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
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _contactController;
  late TextEditingController _detailsController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _whatsappLinkController;
  bool _isRegistrationOpen = true;
  File? _posterImage;
  final ImagePicker _picker = ImagePicker();

  String _selectedEventType = '';
  String _selectedCommunityType = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _typeController = TextEditingController();
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _contactController = TextEditingController();
    _detailsController = TextEditingController();
    _locationController = TextEditingController();
    _priceController = TextEditingController();
    _whatsappLinkController = TextEditingController();
    _fetchEventDetails();
  }

  void _fetchEventDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('EVENTS')
        .doc(widget.eventKey)
        .get();
    var data = doc.data() as Map<String, dynamic>;
    _nameController.text = data['eventName'] ?? '';
    _selectedEventType = data['eventType'] ?? '';
    _dateController.text = data['eventDate'] ?? '';
    _timeController.text = data['eventTime'] ?? '';
    _contactController.text = data['eventContact'] ?? '';
    _detailsController.text = data['description'] ?? '';
    _locationController.text = data['eventLocation'] ?? '';
    _priceController.text = data['eventPrice'] ?? '';
    _whatsappLinkController.text = data['whatsappLink'] ?? '';
    _selectedCommunityType = data['communityType'] ?? '';
    setState(() {
      _isRegistrationOpen = data['isRegistrationOpen'] ?? true;
    });
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
      String? posterImageUrl;
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
        'eventDate': _dateController.text,
        'eventTime': _timeController.text,
        'eventContact': _contactController.text,
        'description': _detailsController.text,
        'eventLocation': _locationController.text,
        'eventPrice': _priceController.text,
        'whatsappLink': _whatsappLinkController.text,
        'communityType': _selectedCommunityType,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                _buildDatePicker("Event Date", _dateController),
                SizedBox(height: 16),
                _buildTimePicker("Event Time", _timeController),
                SizedBox(height: 16),
                _buildTextField("Contact", _contactController),
                SizedBox(height: 16),
                _buildTextField("Description", _detailsController, maxLines: 3),
                SizedBox(height: 16),
                _buildTextField("Location", _locationController),
                SizedBox(height: 16),
                _buildTextField("Price", _priceController),
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

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
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
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            String formattedDate =
                "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
            controller.text = formattedDate;
          }
        },
      ),
    );
  }

  Widget _buildTimePicker(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
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
        onTap: () async {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (pickedTime != null) {
            final now = DateTime.now();
            final formattedTime = TimeOfDay(
              hour: pickedTime.hour,
              minute: pickedTime.minute,
            );
            controller.text = formattedTime.format(context);
          }
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Event Poster",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _posterImage != null
                  ? Image.file(
                _posterImage!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: Icon(Icons.image, color: Colors.grey[800]),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _pickPosterImage,
                child: Text("Pick Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCommunityType.isNotEmpty ? _selectedCommunityType : null,
      onChanged: (String? newValue) {
        setState(() {
          _selectedCommunityType = newValue ?? '';
        });
      },
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
      items: <String>['Technical', 'Cultural', 'Other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildEventTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedEventType.isNotEmpty ? _selectedEventType : null,
      onChanged: (String? newValue) {
        setState(() {
          _selectedEventType = newValue ?? '';
        });
      },
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
      items: <String>['Workshop', 'Seminar', 'Hackathon', 'Other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
