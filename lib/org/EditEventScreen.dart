import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isRegistrationOpen = true;

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
    _fetchEventDetails();
  }

  void _fetchEventDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('event').doc(widget.eventKey).get();
    var data = doc.data() as Map<String, dynamic>;
    _nameController.text = data['eventName'];
    _typeController.text = data['eventtype'];
    _dateController.text = data['eventDate'];
    _timeController.text = data['eventtime'];
    _contactController.text = data['eventcontact'];
    _detailsController.text = data['eventdetails'];
    _locationController.text = data['eventLocation'];
    _priceController.text = data['eventPrice'];
    setState(() {
      _isRegistrationOpen = data['isRegistrationOpen'];
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('event').doc(widget.eventKey).update({
        'eventName': _nameController.text,
        'eventtype': _typeController.text,
        'eventDate': _dateController.text,
        'eventtime': _timeController.text,
        'eventcontact': _contactController.text,
        'eventdetails': _detailsController.text,
        'eventLocation': _locationController.text,
        'eventPrice': _priceController.text,
        'isRegistrationOpen': _isRegistrationOpen,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text("Edit Event"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Event Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Event Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(labelText: 'Event Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _detailsController,
                decoration: InputDecoration(labelText: 'Details'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event details';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event price';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: Text("Registration Open"),
                value: _isRegistrationOpen,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
