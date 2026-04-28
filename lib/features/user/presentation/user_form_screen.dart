import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../data/user_admin_api_service.dart';
import '../domain/entities/user_entity.dart';

class UserFormScreen extends StatefulWidget {
  final UserEntity? user;

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = UserAdminApiService();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController();

  bool _isLoading = false;
  bool _active = true;

  bool get _isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    if (user != null) {
      _firstNameCtrl.text = user.firstName;
      _lastNameCtrl.text = user.lastName;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phone;
      _avatarCtrl.text = user.avatarUrl ?? '';
      _active = user.status == 1;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isEdit) {
        await _apiService.updateUser(
          id: widget.user!.id,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          status: _active ? 1 : 0,
          avatarUrl: _avatarCtrl.text.trim().isEmpty
              ? null
              : _avatarCtrl.text.trim(),
        );
      } else {
        await _apiService.createUser(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          avatarUrl: _avatarCtrl.text.trim().isEmpty
              ? null
              : _avatarCtrl.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.greenPrimary, AppColors.greenMedium],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          _isEdit ? 'Cập nhật người dùng' : 'Thêm người dùng',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
            children: [
              _buildTextField(
                label: 'Tên',
                controller: _firstNameCtrl,
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Họ',
                controller: _lastNameCtrl,
                icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Email',
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                enabled: !_isEdit,
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Số điện thoại',
                controller: _phoneCtrl,
                icon: Icons.phone_outlined,
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Mật khẩu',
                  controller: _passwordCtrl,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Ít nhất 6 ký tự' : null,
                ),
              ],
              const SizedBox(height: 16),
              _buildTextField(label: 'Link ảnh đại diện (URL)', controller: _avatarCtrl, icon: Icons.image_outlined),
              if (_isEdit) ...[
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  title: Text('Hoạt động', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  value: _active,
                  activeTrackColor: AppColors.greenLight,
                  onChanged: (v) => setState(() => _active = v),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Lưu cập nhật' : 'Thêm mới',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool obscureText = false,
    bool enabled = true,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          enabled: enabled,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.brownAccent) : null,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.greenPrimary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
