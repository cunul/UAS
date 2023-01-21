import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final nimController = TextEditingController();
    final deptController = TextEditingController();
    final classController = TextEditingController();

    nameController.text = 'Khusnul Khotimah';
    nimController.text = '43A87006190390';
    deptController.text = 'Teknik Informatika';
    classController.text = 'TI7BP';

    return Scaffold(
      appBar: AppBar(title: Text('Mahasiswa')),
      body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                foregroundImage: AssetImage('assets/profile.jpg'),
              ),
              const SizedBox(height: 18),
              TextField(
                readOnly: true,
                controller: nimController,
                decoration: InputDecoration(labelText: 'NIM'),
              ),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama Mahasiswa'),
              ),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                controller: deptController,
                decoration: InputDecoration(labelText: 'Jurusan'),
              ),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                controller: classController,
                decoration: InputDecoration(labelText: 'Kelas'),
              ),
              const SizedBox(height: 8),
            ],
          )),
    );
  }
}
