import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection.dart' as di;
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProfileBloc>(),
      child: const _EditProfileScreenView(),
    );
  }
}

class _EditProfileScreenView extends StatefulWidget {
  const _EditProfileScreenView();

  @override
  State<_EditProfileScreenView> createState() => _EditProfileScreenViewState();
}

class _EditProfileScreenViewState extends State<_EditProfileScreenView> {
  final AuthStorage _authStorage = AuthStorage();
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

 Future<void> _loadInitialData() async {
    final session = await _authStorage.getSession();
    if (session != null) {
      setState(() {
        _userId = session.userId; // Sửa lỗi: Model của bạn dùng userId
        
        final names = session.fullName.split(' ');
        _firstNameCtrl.text = names.isNotEmpty ? names.first : '';
        _lastNameCtrl.text = names.length > 1 ? names.sublist(1).join(' ') : '';
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate() && _userId != null) {
      context.read<ProfileBloc>().add(UpdateProfileEvent(
        userId: _userId!,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        dateOfBirth: _dobCtrl.text.isNotEmpty ? _dobCtrl.text : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: Text('Chỉnh sửa Profile', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green));
            Navigator.pop(context);
          } else if (state is ProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Thông tin cá nhân'),
                const SizedBox(height: 16),
                _buildField('Họ', _firstNameCtrl, Icons.person_outline),
                const SizedBox(height: 16),
                _buildField('Tên', _lastNameCtrl, Icons.person_outline),
                const SizedBox(height: 16),
                _buildField('Số điện thoại', _phoneCtrl, Icons.phone_android, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildField('Ngày sinh', _dobCtrl, Icons.cake_outlined, hint: 'YYYY-MM-DD'),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A2B24)));
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF6B8070))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.dmSans(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.greenPrimary),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(18),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final isLoading = state is ProfileUpdating;
        return SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 0,
            ),
            onPressed: isLoading ? null : _save,
            child: isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Lưu thay đổi', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        );
      },
    );
  }
}