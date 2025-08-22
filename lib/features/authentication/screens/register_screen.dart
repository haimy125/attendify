import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/config/route_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();

  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _role = "student";
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Unfocus để ẩn keyboard
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
        role: _role,
        studentId: _role == "student" ? _studentIdController.text.trim() : null,
      );

      if (mounted) {
        // Hiển thị thông báo thành công
        _showSuccessDialog();
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("Có lỗi không xác định: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          title: const Text('Đăng ký thành công!', textAlign: TextAlign.center),
          content: const Text(
            'Tài khoản của bạn đã được tạo thành công. Bạn có thể đăng nhập ngay bây giờ.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                  Navigator.pushReplacementNamed(context, RouteConfig.login);
                },
                child: const Text('Đăng nhập ngay'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký tài khoản"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Tạo tài khoản mới',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Điền thông tin để tạo tài khoản Attendify',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Form fields
                _buildFullNameField(),
                const SizedBox(height: 16),

                _buildEmailField(),
                const SizedBox(height: 16),

                _buildPasswordField(),
                const SizedBox(height: 16),

                _buildConfirmPasswordField(),
                const SizedBox(height: 16),

                _buildRoleField(),
                const SizedBox(height: 16),

                // Student ID field (conditional)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _role == "student" ? null : 0,
                  child: _role == "student"
                      ? Column(
                          children: [
                            _buildStudentIdField(),
                            const SizedBox(height: 16),
                          ],
                        )
                      : null,
                ),

                // Register button
                const SizedBox(height: 8),
                _buildRegisterButton(),

                // Login link
                const SizedBox(height: 16),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      decoration: InputDecoration(
        labelText: "Họ và tên",
        hintText: "Nhập họ và tên đầy đủ",
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Vui lòng nhập họ và tên";
        }
        if (value.trim().length < 2) {
          return "Họ tên phải có ít nhất 2 ký tự";
        }
        if (!RegExp(
          r'^[a-zA-ZàáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđĐ\s]+$',
        ).hasMatch(value.trim())) {
          return "Họ tên chỉ được chứa chữ cái";
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "example@email.com",
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Vui lòng nhập email";
        }
        if (!RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
        ).hasMatch(value.trim())) {
          return "Email không hợp lệ";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: "Mật khẩu",
        hintText: "Tối thiểu 6 ký tự",
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Vui lòng nhập mật khẩu";
        }
        if (value.length < 6) {
          return "Mật khẩu phải có ít nhất 6 ký tự";
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: "Xác nhận mật khẩu",
        hintText: "Nhập lại mật khẩu",
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      obscureText: _obscureConfirmPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Vui lòng xác nhận mật khẩu";
        }
        if (value != _passwordController.text) {
          return "Mật khẩu xác nhận không khớp";
        }
        return null;
      },
    );
  }

  Widget _buildRoleField() {
    return DropdownButtonFormField<String>(
      value: _role,
      decoration: InputDecoration(
        labelText: "Vai trò",
        prefixIcon: const Icon(Icons.work),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: const [
        DropdownMenuItem(
          value: "student",
          child: Row(
            children: [
              Icon(Icons.school, size: 20),
              SizedBox(width: 8),
              Text("Sinh viên"),
            ],
          ),
        ),
        DropdownMenuItem(
          value: "lecturer",
          child: Row(
            children: [
              Icon(Icons.person, size: 20),
              SizedBox(width: 8),
              Text("Giảng viên"),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _role = value ?? "student";
          // Clear student ID when switching to lecturer
          if (_role == "lecturer") {
            _studentIdController.clear();
          }
        });
      },
    );
  }

  Widget _buildStudentIdField() {
    return TextFormField(
      controller: _studentIdController,
      decoration: InputDecoration(
        labelText: "Mã sinh viên",
        hintText: "Nhập mã sinh viên",
        prefixIcon: const Icon(Icons.badge),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
      validator: _role == "student"
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return "Vui lòng nhập mã sinh viên";
              }
              if (value.trim().length < 3) {
                return "Mã sinh viên phải có ít nhất 3 ký tự";
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _register,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _loading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text("Đang đăng ký..."),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.app_registration),
                  SizedBox(width: 8),
                  Text("Đăng ký", style: TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Đã có tài khoản? ",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, RouteConfig.login);
          },
          child: const Text("Đăng nhập ngay"),
        ),
      ],
    );
  }
}
