import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/navbar.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/note.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/signature_screen.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user.dart';
import 'package:fuesse_und_fusspflege_cw/src/registration/user_list_provider.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RegistrationForm extends StatefulWidget {
  final User? user;
  final int? index;
  static const routeName = 'registration_form';

  const RegistrationForm({super.key, this.user, this.index});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final formValidNotifier = ValueNotifier<bool>(false);

  final _nameController = TextEditingController();
  final _plzOrtController = TextEditingController();
  final _strasseController = TextEditingController();
  final _telefonnummerController = TextEditingController();
  final _emailController = TextEditingController();
  final _berufController = TextEditingController();
  final _besonderheitenController = TextEditingController();
  final _erkrankungenController = TextEditingController();
  final _uebertragbareErkrankungenController = TextEditingController();
  final _einnahmeVonHormonenController = TextEditingController();
  final _einnahmeVonMedikamentenController = TextEditingController();
  final _allergienController = TextEditingController();
  bool? _erfahrungenGelAcrylmodellage = false;
  bool? _bluter = false;
  bool? _diabetiker = false;
  bool? _schwangerschaft = false;
  bool? _einwilligungCheck = true;
  bool? _informationsbogenCheck = true;

  DateTime? _dateOfBirth;
  DateTime? _informationsbogenDate;
  DateTime? _einwilligungDate;
  // selectBoxes
  String? _selectedHautZustandFussruecken;
  String? _selectedHautZustandFussohle;
  String? _selectedNagelzustand;
  String? _selectedNagelerkrankungen;
  String? _selectedNagelform;
  String? _selectedNagelspitzenform;
  List<Note> userNotes = [];

  final informationsbogenDateController = TextEditingController(
    text: DateFormat('dd.MM.yyyy').format(DateTime.now()),
  );
  final einwilligungDateController = TextEditingController(
    text: DateFormat('dd.MM.yyyy').format(DateTime.now()),
  );

  final birthDateController = TextEditingController();
  // final _dateController2 = TextEditingController();

  // final _signatureCanvasKey1 = GlobalKey<SignatureState>();
  // final _signatureCanvasKey2 = GlobalKey<SignatureState>();

  final _signatureFormKey1 = GlobalKey<FormState>();
  final _signatureFormKey2 = GlobalKey<FormState>();

  var color = Colors.black;
  var strokeWidth = 2.0;

  // bool _signatureTouched1 = false;
  // bool _signatureTouched2 = false;

  Uint8List? _signatureData1;
  Uint8List? _signatureData2;

  bool isEditingUser = false;
  // List<User> userList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserListProvider>(context, listen: false)
          .setTitle('Registrierung');
    });

    _informationsbogenDate = DateTime.now();
    _einwilligungDate = DateTime.now();

    if (widget.user != null) {
      isEditingUser = true;
      _nameController.text = widget.user!.name;
      _dateOfBirth = widget.user!.dateOfBirth;
      birthDateController.text = DateFormat('dd.MM.yyyy').format(_dateOfBirth!);
      _plzOrtController.text = widget.user!.plzOrt;
      _strasseController.text = widget.user!.strasse;
      _telefonnummerController.text = widget.user!.telefonnummer;
      _emailController.text = widget.user!.email;
      _berufController.text = widget.user!.beruf;
      _besonderheitenController.text = widget.user!.besonderheiten;
      _erkrankungenController.text = widget.user!.erkrankungen;
      _uebertragbareErkrankungenController.text =
          widget.user!.uebertragbareErkrankungen;
      _einnahmeVonHormonenController.text = widget.user!.einnahmeVonHormonen;
      _einnahmeVonMedikamentenController.text =
          widget.user!.einnahmeVonMedikamenten;
      _allergienController.text = widget.user!.allergien;
      _erfahrungenGelAcrylmodellage = widget.user!.erfahrungenGelAcrylmodellage;
      _bluter = widget.user!.bluter;
      _diabetiker = widget.user!.diabetiker;
      _schwangerschaft = widget.user!.schwangerschaft;
      _informationsbogenCheck = widget.user!.informationsbogenCheck;
      _einwilligungCheck = widget.user!.einwilligungCheck;
      _informationsbogenDate = widget.user!.informationsbogenDate;
      informationsbogenDateController.text =
          DateFormat('dd.MM.yyyy').format(_informationsbogenDate!);
      _einwilligungDate = widget.user!.einwilligungDate;
      einwilligungDateController.text =
          DateFormat('dd.MM.yyyy').format(_einwilligungDate!);
      //selectBoxes
      _selectedHautZustandFussruecken =
          widget.user!.selectedHautZustandFussruecken;
      _selectedHautZustandFussohle = widget.user!.selectedHautZustandFussohle;
      _selectedNagelzustand = widget.user!.selectedNagelzustand;
      _selectedNagelerkrankungen = widget.user!.selectedNagelerkrankungen;
      _selectedNagelform = widget.user!.selectedNagelform;
      _selectedNagelspitzenform = widget.user!.selectedNagelspitzenform;
      userNotes = widget.user!.notes;
      // ...
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _plzOrtController.text = widget.user!.plzOrt;
      _strasseController.text = widget.user!.strasse;
      _telefonnummerController.text = widget.user!.telefonnummer;
      _emailController.text = widget.user!.email;
      _berufController.text = widget.user!.beruf;
      _besonderheitenController.text = widget.user!.besonderheiten;
      _erkrankungenController.text = widget.user!.erkrankungen;
      _uebertragbareErkrankungenController.text =
          widget.user!.uebertragbareErkrankungen;
      _einnahmeVonHormonenController.text = widget.user!.einnahmeVonHormonen;
      _einnahmeVonMedikamentenController.text =
          widget.user!.einnahmeVonMedikamenten;
      _allergienController.text = widget.user!.allergien;
      _erfahrungenGelAcrylmodellage = widget.user!.erfahrungenGelAcrylmodellage;
      _bluter = widget.user!.bluter;
      _diabetiker = widget.user!.diabetiker;
      _schwangerschaft = widget.user!.schwangerschaft;
      _informationsbogenCheck = widget.user!.informationsbogenCheck;
      _einwilligungCheck = widget.user!.einwilligungCheck;
      _dateOfBirth = widget.user!.dateOfBirth;
      _informationsbogenDate = widget.user!.informationsbogenDate;
      _einwilligungDate = widget.user!.einwilligungDate;
      //selectBoxes
      _selectedHautZustandFussruecken =
          widget.user!.selectedHautZustandFussruecken;
      _selectedHautZustandFussohle = widget.user!.selectedHautZustandFussohle;
      _selectedNagelzustand = widget.user!.selectedNagelzustand;
      _selectedNagelerkrankungen = widget.user!.selectedNagelerkrankungen;
      _selectedNagelform = widget.user!.selectedNagelform;
      _selectedNagelspitzenform = widget.user!.selectedNagelspitzenform;
      userNotes = widget.user!.notes;
    }
  }

  @override
  void dispose() {
    formValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a TextEditingController

    return Material(
        child: Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          addAutomaticKeepAlives: true,
          children: <Widget>[
            ListTile(
              title: const Text('Name'),
              subtitle: TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Namen angeben';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: const Text('Geburtsdatum'),
              subtitle: TextFormField(
                controller: birthDateController,
                readOnly: true, // Make the TextFormField read-only
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null && date != _dateOfBirth) {
                    setState(() {
                      _dateOfBirth = date;
                      // Update the TextFormField with the selected date
                      birthDateController.text =
                          DateFormat('dd.MM.yyyy').format(date);
                    });
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('PLZ / Ort'),
              subtitle: TextFormField(
                controller: _plzOrtController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Ort angeben';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: const Text('Straße'),
              subtitle: TextFormField(
                controller: _strasseController,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Straße angeben';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: const Text('Telefonnummer'),
              subtitle: TextFormField(
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: _telefonnummerController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Telefonnummer angeben';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: const Text('Email'),
              subtitle: TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Email angeben';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: const Text('Beruf'),
              subtitle: TextFormField(
                controller: _berufController,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte Beruf angeben';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              title: const Text('Besonderheiten'),
              subtitle: TextFormField(
                controller: _besonderheitenController,
                maxLines: 4,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter some text';
                //   }
                //   return null;
                // },
              ),
            ),
            ListTile(
              title: const Text('Erkrankungen/Einnahme von Hormonen/Allergien'),
              subtitle: TextFormField(
                controller: _erkrankungenController,
                maxLines: 4,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter some text';
                //   }
                //   return null;
                // },
              ),
            ),
            ListTile(
              title: const Text('Übertragbare/relevante Erkrankungen'),
              subtitle: TextFormField(
                controller: _uebertragbareErkrankungenController,
                maxLines: 4,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter some text';
                //   }
                //   return null;
                // },
              ),
            ),
            ListTile(
              title: const Text('Einnahme von Hormonen'),
              subtitle: TextFormField(
                controller: _einnahmeVonHormonenController,
                maxLines: 4,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter some text';
                //   }
                //   return null;
                // },
              ),
            ),
            ListTile(
              title: const Text('Einnahme von Medikamenten'),
              subtitle: TextFormField(
                controller: _einnahmeVonMedikamentenController,
                maxLines: 4,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter some text';
                //   }
                //   return null;
                // },
              ),
            ),
            ListTile(
              title: const Text('Allergien'),
              subtitle: TextFormField(
                controller: _allergienController,
                maxLines: 4,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter some text';
                //   }
                //   return null;
                // },
              ),
            ),
            ListTile(
              title: const Text('Erfahrungen Gel-/Acrylmodellage'),
              trailing: Checkbox(
                value: _erfahrungenGelAcrylmodellage,
                onChanged: (value) {
                  setState(() {
                    _erfahrungenGelAcrylmodellage = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Bluter'),
              trailing: Checkbox(
                value: _bluter,
                onChanged: (value) {
                  setState(() {
                    _bluter = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Diabetiker'),
              trailing: Checkbox(
                value: _diabetiker,
                onChanged: (value) {
                  setState(() {
                    _diabetiker = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Schwangerschaft'),
              trailing: Checkbox(
                value: _schwangerschaft,
                onChanged: (value) {
                  setState(() {
                    _schwangerschaft = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zustand der Haut der Füße: Fußrücken',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  DropdownButton<String>(
                    value: _selectedHautZustandFussruecken,
                    items:
                        <String>['rau/trocken', 'normal'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHautZustandFussruecken = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zustand der Haut der Füße: Fußsohle',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  DropdownButton<String>(
                    value: _selectedHautZustandFussohle,
                    items: <String>[
                      '',
                      'rau/trocken',
                      'feucht',
                      'Risse/Rhagaden',
                      'Druckstellen',
                      'HA'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHautZustandFussohle = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nagelzustand',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  DropdownButton<String>(
                    value: _selectedNagelzustand,
                    items: <String>[
                      '',
                      'glatt/fest',
                      'weich/feucht',
                      'splitternd/unregelmäßig/ausgefranst'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNagelzustand = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Erkrankungen des Nagels bzw. der Nagelumgebung',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  DropdownButton<String>(
                    value: _selectedNagelerkrankungen,
                    items: <String>[
                      '',
                      'Nagelpilz',
                      'Nagelwall- oder Nagelfalzentzündungen',
                      'Fußpilz',
                      'Warzen'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNagelerkrankungen = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nagelform',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  DropdownButton<String>(
                    value: _selectedNagelform,
                    items: <String>[
                      'oval',
                      'lang/schmal',
                      'eckig/breit',
                      'trapezförmig'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNagelform = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gewünschte Nagelspitzenform',
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  DropdownButton<String>(
                    value: _selectedNagelspitzenform,
                    items: <String>['rundlich', 'gerade'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNagelspitzenform = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                  'Ich habe den Informationsbogen über die Verarbeitung meiner Daten (Information nach Art. 12, 13 DSGVO ausgehändigt bekommen.',
                  softWrap: true,
                  overflow: TextOverflow.visible),
              trailing: Checkbox(
                value: _informationsbogenCheck,
                onChanged: (value) {
                  setState(() {
                    _informationsbogenCheck = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Datum'),
              subtitle: TextFormField(
                controller: informationsbogenDateController,
                readOnly: true, // Make the TextFormField read-only
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null && date != _informationsbogenDate) {
                    setState(() {
                      _informationsbogenDate = date;
                      // Update the TextFormField with the selected date
                      informationsbogenDateController.text =
                          DateFormat('dd.MM.yyyy').format(date);
                    });
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Unterschrift'),
              subtitle: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignatureScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _signatureData1 = result;
                    });
                  }
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  width: double
                      .infinity, // Ensure the container takes the full width
                  child: _signatureData1 != null
                      ? Image.memory(_signatureData1!)
                      : const Center(
                          child: Text('Zum unterschreiben anklicken')),
                ),
              ),
            ),
            // ListTile(
            //   title: const Text('Unterschrift'),
            //   subtitle: Container(
            //     height: 200,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //     ),
            //     child: Stack(
            //       children: [
            //         Form(
            //           key: _signatureFormKey1,
            //           child: IgnorePointer(
            //             ignoring: widget.user != null,
            //             child: ColorFiltered(
            //               colorFilter: widget.user != null
            //                   ? const ColorFilter.mode(
            //                       Colors.grey, BlendMode.saturation)
            //                   : const ColorFilter.mode(
            //                       Colors.transparent, BlendMode.saturation),
            //               child: SignatureTile(
            //                 color: color,
            //                 signatureKey: _signatureCanvasKey1,
            //                 strokeWidth: strokeWidth,
            //                 onSign: (touched) {
            //                   setState(() {
            //                     _signatureTouched1 = touched;
            //                   });
            //                 },
            //               ),
            //             ),
            //           ),
            //         ),
            //         Positioned(
            //           top: 0,
            //           right: 0,
            //           child: IconButton(
            //             icon: const Icon(Icons.close),
            //             onPressed: widget.user == null
            //                 ? () {
            //                     setState(() {
            //                       _signatureCanvasKey1.currentState!.clear();
            //                       _signatureTouched1 = false;
            //                     });
            //                   }
            //                 : null,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            ListTile(
              title: const Text(
                  'Hiermit willige ich ausdrücklich ein, dass meine zu Zwecken der Vertragserfüllung ( z.B. Identifikation, Abrechnung), zur Erfüllung von gesetzlichen Verpflichtungen und aus berechtigtem Interesse erhobenen Adressdaten, nämlich Name, Anschrift, Geburtsdatum, E-Mailadresse, Telefonnummer auch zum Zwecke der Übermittlung von Angeboten/Werbung verwendet werden dürfen. Diese Einwilligung ist freiwillig. Ich kann sie ohne Angaben von Gründen verweigern, ohne dass ich deswegen Nachteile zu befürchten hätte. Ich kann diese Einwilligung zudem jederzeit in Textform (z.B. Brief, E-Mail) mit Wirkung für die Zukunft widerrufen.',
                  softWrap: true,
                  overflow: TextOverflow.visible),
              trailing: Checkbox(
                  value: _einwilligungCheck,
                  onChanged: (value) {
                    setState(() {
                      _einwilligungCheck = value!;
                    });
                  }),
            ),
            ListTile(
              title: const Text('Datum'),
              subtitle: TextFormField(
                controller: einwilligungDateController,
                readOnly: true, // Make the TextFormField read-only
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null && date != _einwilligungDate) {
                    setState(() {
                      _einwilligungDate = date;
                      // Update the TextFormField with the selected date
                      einwilligungDateController.text =
                          DateFormat('dd.MM.yyyy').format(date);
                    });
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Unterschrift'),
              subtitle: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignatureScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _signatureData2 = result;
                    });
                  }
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  width: double
                      .infinity, // Ensure the container takes the full width
                  child: _signatureData2 != null
                      ? Image.memory(_signatureData2!)
                      : const Center(
                          child: Text('Zum unterschreiben anklicken')),
                ),
              ),
            ),
            // ListTile(
            //   title: const Text('Unterschrift'),
            //   subtitle: Container(
            //     height: 200,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //     ),
            //     child: Stack(
            //       children: [
            //         Form(
            //           key: _signatureFormKey2,
            //           child: IgnorePointer(
            //             ignoring: widget.user != null,
            //             child: ColorFiltered(
            //               colorFilter: widget.user != null
            //                   ? const ColorFilter.mode(
            //                       Colors.grey, BlendMode.saturation)
            //                   : const ColorFilter.mode(
            //                       Colors.transparent, BlendMode.saturation),
            //               child: SignatureTile(
            //                 color: color,
            //                 signatureKey: _signatureCanvasKey2,
            //                 strokeWidth: strokeWidth,
            //                 onSign: (touched) {
            //                   setState(() {
            //                     _signatureTouched2 = touched;
            //                   });
            //                 },
            //               ),
            //             ),
            //           ),
            //         ),
            //         Positioned(
            //           top: 0,
            //           right: 0,
            //           child: IconButton(
            //             icon: const Icon(Icons.close),
            //             onPressed: widget.user == null
            //                 ? () {
            //                     setState(() {
            //                       _signatureCanvasKey2.currentState!.clear();
            //                       _signatureTouched2 = false;
            //                     });
            //                   }
            //                 : null,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          List<String> errors = [];

          if (_nameController.text.isEmpty) {
            errors.add('Bitte Name angeben');
          }
          if (_plzOrtController.text.isEmpty) {
            errors.add('Bitte PLZ/Ort angeben');
          }
          if (_strasseController.text.isEmpty) {
            errors.add('Bitte Straße angeben');
          }
          if (_dateOfBirth == null) {
            errors.add('Bitte Geburtsdatum angeben');
          }

          if ((errors.isEmpty &&
                  _signatureData1 != null &&
                  _signatureData2 != null) ||
              (errors.isEmpty && isEditingUser)) {
            final Uint8List? pngBytes1 = _signatureData1;
            final Uint8List? pngBytes2 = _signatureData2;

            if ((pngBytes1 == null || pngBytes2 == null) && !isEditingUser) {
              Fluttertoast.showToast(
                msg:
                    'Fehler beim Speichern: Pflichtfelder ausfüllen & Bitmaps bereitstellen',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              return;
            }

            const uuid = Uuid();
            final user = User(
                userId: isEditingUser ? widget.user!.userId : const Uuid().v1(),
                name: _nameController.text,
                plzOrt: _plzOrtController.text,
                strasse: _strasseController.text,
                telefonnummer: _telefonnummerController.text,
                email: _emailController.text,
                beruf: _berufController.text,
                besonderheiten: _besonderheitenController.text,
                erkrankungen: _erkrankungenController.text,
                uebertragbareErkrankungen:
                    _uebertragbareErkrankungenController.text,
                einnahmeVonHormonen: _einnahmeVonHormonenController.text,
                einnahmeVonMedikamenten:
                    _einnahmeVonMedikamentenController.text,
                allergien: _allergienController.text,
                erfahrungenGelAcrylmodellage: _erfahrungenGelAcrylmodellage!,
                bluter: _bluter!,
                diabetiker: _diabetiker!,
                schwangerschaft: _schwangerschaft!,
                informationsbogenCheck: _informationsbogenCheck!,
                einwilligungCheck: _einwilligungCheck!,
                dateOfBirth: _dateOfBirth,
                informationsbogenDate: _informationsbogenDate,
                einwilligungDate: _einwilligungDate,
                signature1: isEditingUser ? widget.user!.signature1 : pngBytes1,
                signature2: isEditingUser ? widget.user!.signature2 : pngBytes2,
                // signature1: _signatureCanvasKey1.currentState?.points ?? [],
                // signature2: _signatureCanvasKey2.currentState?.points ?? [],
                //selectBoxes
                selectedHautZustandFussruecken: _selectedHautZustandFussruecken,
                selectedHautZustandFussohle: _selectedHautZustandFussohle,
                selectedNagelzustand: _selectedNagelzustand,
                selectedNagelerkrankungen: _selectedNagelerkrankungen,
                selectedNagelform: _selectedNagelform,
                selectedNagelspitzenform: _selectedNagelspitzenform,
                lastEdited: DateTime.now(),
                notes: userNotes,
                consent: widget.user?.consent,
                policies: widget.user?.policies);

            if (isEditingUser) {
              Provider.of<UserListProvider>(context, listen: false)
                  .updateUser(user.userId, user);
            } else {
              Provider.of<UserListProvider>(context, listen: false)
                  .addUser(user);
            }

            Fluttertoast.showToast(
                msg: "Gespeichert",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainView(),
              ),
            );
          } else {
            String errorMessage =
                'Fehler beim Speichern: Pflichtfelder ausfüllen';

            if (errors.isNotEmpty) {
              errorMessage += errors.join(', ');
            }
            if (errorMessage.isNotEmpty) {
              errorMessage += ' & Bitte unterschreiben';
            } else {
              errorMessage = 'Bitte unterschreiben';
            }

            Fluttertoast.showToast(
              msg: errorMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
        label: const Text('Speichern'),
        icon: const Icon(Icons.save),
      ),
    ));
  }
}

          // if (_signatureFormKey1.currentState != null &&
          //     !(_signatureFormKey1.currentState!.validate())) {
          //   errors.add('Bitte Datenschutzerklärung unterschreiben');
          // }

          // if (_signatureFormKey2.currentState != null &&
          //     !(_signatureFormKey2.currentState!.validate())) {
          //   errors.add('Bitte Einwilligungserklärung unterschreiben');
          // }

 // Add more fields here in the same manner
            // ElevatedButton(
            // onPressed: () {
            // if (_formKey.currentState!.validate() &&
            //     _signatureFormKey1.currentState!.validate() &&
            //     _signatureFormKey2.currentState!.validate()) {
            //   // Save the user
            //   final user = User(
            //       name: _nameController.text,
            //       plzOrt: _plzOrtController.text,
            //       strasse: _strasseController.text,
            //       telefonnummer: _telefonnummerController.text,
            //       besonderheiten: _besonderheitenController.text,
            //       erkrankungen: _erkrankungenController.text,
            //       uebertragbareErkrankungen:
            //           _uebertragbareErkrankungenController.text,
            //       einnahmeVonHormonen:
            //           _einnahmeVonHormonenController.text,
            //       einnahmeVonMedikamenten:
            //           _einnahmeVonMedikamentenController.text,
            //       allergien: _allergienController.text,
            //       erfahrungenGelAcrylmodellage:
            //           _erfahrungenGelAcrylmodellage!,
            //       bluter: _bluter!,
            //       diabetiker: _diabetiker!,
            //       schwangerschaft: _schwangerschaft!,
            //       informationsbogenCheck: _informationsbogenCheck!,
            //       einwilligungCheck: _einwilligungCheck!,
            //       dateOfBirth: _dateOfBirth,
            //       informationsbogenDate: _informationsbogenDate,
            //       einwilligungDate: _einwilligungDate,
            //       signature1:
            //           _signatureCanvasKey1.currentState?.points ?? [],
            //       signature2:
            //           _signatureCanvasKey2.currentState?.points ?? [],
            //       //selectBoxes
            //       selectedHautZustandFussruecken:
            //           _selectedHautZustandFussruecken,
            //       selectedHautZustandFussohle:
            //           _selectedHautZustandFussohle,
            //       selectedNagelzustand: _selectedNagelzustand,
            //       selectedNagelerkrankungen: _selectedNagelerkrankungen,
            //       selectedNagelform: _selectedNagelform,
            //       selectedNagelspitzenform: _selectedNagelspitzenform);

            // Add the user to the user list
            // userList.add(user);
            //       // Provider.of<UserListProvider>(context, listen: false)
            //       //     .addUser(user);

            //       // Fluttertoast.showToast(
            //       //     msg: "Gespeichert",
            //       //     toastLength: Toast.LENGTH_SHORT,
            //       //     gravity: ToastGravity.BOTTOM,
            //       //     timeInSecForIosWeb: 1,
            //       //     backgroundColor: Colors.green,
            //       //     textColor: Colors.white,
            //       //     fontSize: 16.0);

            //       // Navigator.pushReplacement(
            //       //   context,
            //       //   MaterialPageRoute(
            //       //     builder: (context) => const MainView(),
            //       //   ),
            //       // );
            //     } else if (!(_signatureFormKey1.currentState!.validate())
            //         // || !(_signatureFormKey2.currentState!.validate())
            //         ) {
            //       Fluttertoast.showToast(
            //           msg: "Bitte unterschreiben",
            //           toastLength: Toast.LENGTH_SHORT,
            //           gravity: ToastGravity.BOTTOM,
            //           timeInSecForIosWeb: 1,
            //           backgroundColor: Colors.red,
            //           textColor: Colors.white,
            //           fontSize: 16.0);
            //     }
            //   },
            //   child: const Text('Speichern'),
            // ),