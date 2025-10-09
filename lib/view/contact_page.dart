import 'dart:io';

import 'package:agendadecontato/database/helper/contact_helper.dart';
import 'package:agendadecontato/database/model/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({super.key, this.contact});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact? _editedContact;
  late bool _userEdited = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imgController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final ContactHelper _helper = ContactHelper();
  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );

  @override
  initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact(name: "",email:  "",phone:  "",img:  "");
    } else {
      _editedContact = widget.contact;
      _nameController.text = _editedContact?.name ?? "";
      _emailController.text = _editedContact?.email ?? "";
      _phoneController.text = _editedContact?.phone ?? "";
      _imgController.text = _editedContact?.img ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(_editedContact?.name ?? "Novo Contato"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _saveContact();
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => _selectImage(),
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _editedContact?.img != null && _editedContact!.img!.isNotEmpty
                    ? FileImage(File(_editedContact!.img!))
                    : AssetImage("assets/images/perfil.png") as ImageProvider,
                    fit: BoxFit.cover
                  ),
                ),
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nome"),
              onChanged: (text){
                _userEdited = true;
                setState(() {
                  _editedContact?.name = text;
                });
              },
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              onChanged: (text){
                _userEdited = true;
                setState(() {
                  _editedContact?.email = text;
                });
              },
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Telefone"),
              onChanged: (text){
                _userEdited = true;
                setState(() {
                  _editedContact?.phone = text;
                });
              },
              keyboardType: TextInputType.phone,
              inputFormatters: [phoneMask],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery
    );
    if (image != null){
      setState(() {
        _editedContact?.img = image.path;
      });
    }
  }

  void _saveContact() async{
    if(_editedContact?.name != null && _editedContact!.name.isNotEmpty){
      if(_editedContact?.id != null){
        await _helper.updateContact(_editedContact!);
      } else {
        await _helper.saveContact(_editedContact!);
      }
      Navigator.pop(context, _editedContact);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O nome é obrigatório!"))
      );
    }
  }
}