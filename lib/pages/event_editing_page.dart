
import 'package:countdown_event/provider/EventProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/event.dart';

import '../utils.dart';
import 'home_page.dart';

class EventEditingPage extends StatefulWidget {
  const EventEditingPage({super.key, this.event});
  final Event? event;

  @override
  State<EventEditingPage> createState() => _EventEditingPageState();
}

class _EventEditingPageState extends State<EventEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void initState() {
    super.initState();
  
    toDate = widget.event?.dateTime ?? fromDate.add(const Duration(hours: 2));

    // Initialize controllers if event exists
    if (widget.event != null) {
      titleController.text = widget.event!.title;
      descriptionController.text = widget.event!.details;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8E2DE2), // Purple
              Color(0xFF4A00E0), // Darker Purple
              Color(0xFF00C6FF), // Light Blue
            ],
          ),
        ),
      child: Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          actions: buildEditingActions(),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildTitle(),
                buildDateTimePicker(),
                buildDescription(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildEditingActions() {
    return [
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: saveForm,
        label: const Text("SAVE"),
        icon: const Icon(Icons.done),
      )
    ];
  }

  Widget buildTitle() {
    return TextFormField(
      style: const TextStyle(fontSize: 24),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        hintText: "Add title",
      ),
      validator: (title) =>
          title?.isEmpty ?? true ? "Title cannot be empty" : null,
      controller: titleController,
    );
  }

  Widget buildDescription() {
    return TextFormField(
      style: const TextStyle(fontSize: 18),
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        hintText: "Add description",
      ),
      controller: descriptionController,
    );
  }

  Widget buildDateTimePicker() {
    return Column(
      children: [buildFrom(), buildTo()],
    );
  }

  Widget buildFrom() {
    return buildHeader(
      header: "From",
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: buildDropDownField(
                text: Utils.toDate(fromDate),
                onClicked: () => pickFromDateTime(pickDate: true)),
          ),
          Expanded(
            child: buildDropDownField(
                text: Utils.toTime(fromDate),
                onClicked: () => pickFromDateTime(pickDate: false)),
          ),
        ],
      ),
    );
  }

  Widget buildTo() {
    return buildHeader(
      header: "To",
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: buildDropDownField(
                text: Utils.toDate(toDate),
                onClicked: () => pickToDateTime(pickDate: true)),
          ),
          Expanded(
            child: buildDropDownField(
                text: Utils.toTime(toDate),
                onClicked: () => pickToDateTime(pickDate: false)),
          ),
        ],
      ),
    );
  }

  Widget buildDropDownField(
          {required String text, required VoidCallback onClicked}) =>
      ListTile(
        title: Text(text),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Widget buildHeader({required String header, required Widget child}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child
        ],
      );

 
Future saveForm() async {
  final isValid = _formKey.currentState!.validate();
  if (isValid) {
    // Create the updated event
    final newEvent = Event(
      title: titleController.text,
      dateTime: toDate,
      details: descriptionController.text,  
      needEndDate: false,
      needNotify: false,
      notifications: [],
      
    );

    final provider = Provider.of<EventProvider>(context, listen: false);

    // Check if editing an existing event or adding a new one
    if (widget.event != null) {
      // Edit the existing event
      provider.editEvent(newEvent, widget.event!);
    } else {
      // Add new event
      provider.addEvent(newEvent);
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const HomePage()));
  }
}



  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate =
          DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }
    setState(() {
      fromDate = date;
    });
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(toDate,
        pickDate: pickDate, firstDate: pickDate ? fromDate : null);
    if (date == null) return;

    setState(() {
      toDate = date;
    });
  }

  Future<DateTime?> pickDateTime(DateTime initialDate,
      {required bool pickDate, DateTime? firstDate}) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (date == null) return null;

      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(initialDate));
      if (timeOfDay == null) return null;

      final date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);

      return date.add(time);
    }
  }
}
