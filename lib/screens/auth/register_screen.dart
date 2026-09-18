import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warda/models/usuario_model.dart';
import 'package:warda/providers/auth_provider.dart';
import 'package:warda/routes/app_routes.dart';
import 'package:warda/widgets/custom_button.dart';
import 'package:warda/widgets/custom_textfield.dart';
import 'package:warda/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // ✅ Sin color hardcodeado
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // ✅ Usa el color del tema
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOGO DE WARDA
                Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.health_and_safety,
                          size: 80,
                          color: theme.colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // TÍTULO
                Center(
                  child: Text(
                    'Regístrate en WARDA',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Completa tus datos para comenzar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // CAMPOS DEL FORMULARIO
                CustomTextField(
                  label: 'Nombre completo',
                  hint: 'Tu nombre',
                  controller: _nombreController,
                  validator: Validators.validateName,
                  prefixIcon: Icons.person_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email',
                  hint: 'tu@email.com',
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Teléfono',
                  hint: '999 999 999',
                  controller: _telefonoController,
                  validator: Validators.validatePhone,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Contraseña',
                  hint: '********',
                  obscureText: true,
                  controller: _passwordController,
                  validator: Validators.validatePassword,
                  prefixIcon: Icons.lock_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirmar contraseña',
                  hint: '********',
                  obscureText: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  prefixIcon: Icons.lock_outlined,
                ),
                const SizedBox(height: 20),

                // TÉRMINOS Y CONDICIONES
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Acepto los términos y condiciones de WARDA',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // BOTÓN CREAR CUENTA
                CustomButton(
                  text: 'Crear cuenta',
                  onPressed: (_isLoading || authProvider.isLoading || !_acceptTerms)
                      ? null
                      : () => _register(context, authProvider),
                  isLoading: _isLoading || authProvider.isLoading,
                ),

                // MENSAJE DE ERROR
                if (authProvider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // LINK A LOGIN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta?',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text(
                        'Inicia sesión',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final usuario = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      notificacionesActivas: true,
      ubicacionCompartida: true,
    );

    final success = await authProvider.register(
      usuario,
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Cuenta creada exitosamente!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}