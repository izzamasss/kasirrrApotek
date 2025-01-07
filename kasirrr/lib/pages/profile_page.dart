import 'package:apotek/constants/app_color.dart';
import 'package:apotek/constants/variable.dart';
import 'package:apotek/models/pengguna.dart';
import 'package:apotek/widgets/button.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final defIcon = const Icon(Icons.person, size: 80, color: Colors.white);
  bool _isEditing = false;
  bool _isLoading = false;
  String? imageUrl;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final _apiService = ApiService();

  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _telpController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaController.text = Variable.pengguna?.nama ?? '';
    _telpController.text = Variable.pengguna?.telepon ?? '';
    _emailController.text = Variable.pengguna?.email ?? '';
    setState(() {
      _imageFile = null;
      imageUrl = Variable.pengguna?.fotoProfile;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memilih gambar: $e')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Ambil Foto'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih dari Galeri'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    // try {
    // Implementasi logika penyimpanan profil
    // final res = await _apiService.updateProfile(
    //   id: Variable.pengguna?.id ?? '',
    //   nama: _namaController.text,
    //   email: _emailController.text,
    //   telepon: _telpController.text,
    //   fotoProfile: _imageFile?.path,
    // );
    final user = Variable.pengguna;
    // final pengguna = Pengguna(
    //   id: user?.id,
    //   username: user?.username,
    //   nama: _namaController.text,
    //   email: _emailController.text,
    //   telepon: _telpController.text,
    //   role: user?.role,
    // );

    final pengguna = Pengguna(
      id: '',
      username: user?.username,
      nama: _namaController.text,
      email: _emailController.text,
      telepon: _telpController.text,
      role: user?.role,
      password: null,
      createdAt: DateTime.now(),
    );
    final res = await _apiService.updatePengguna(user?.id ?? '', pengguna);
    setState(() => _isLoading = false);
    debugPrint('-----res $res');
    if (!mounted) return;
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Profil berhasil diperbarui')),
    // );
    // } catch (e) {
    //   setState(() => _isLoading = false);
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Gagal memperbarui profil: ${e.toString()}')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: AppColor.primary.withOpacity(0.2),
                      // backgroundImage: _imageFile != null ? FileImage(_imageFile!) as ImageProvider : null,
                      child: _imageFile != null
                          ? Image.file(_imageFile!, fit: BoxFit.fill)
                          : (imageUrl != null && imageUrl != '')
                              ? Image.network(imageUrl!, fit: BoxFit.fill, errorBuilder: (_, __, ___) => defIcon)
                              : defIcon,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: AppColor.primary,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: _showImagePickerOptions,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                // Nama
                TextFormField(
                  controller: _namaController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Telepon
                TextFormField(
                  controller: _telpController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email
                TextFormField(
                  controller: _emailController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email harus diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      onPressed: _isEditing ? _saveProfile : null,
                      isLoading: _isLoading,
                      label: 'Simpan',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _telpController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
