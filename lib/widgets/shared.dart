import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ── Logo circular com elefante ───────────────────────────────────────────────
class HCLogo extends StatelessWidget {
  final double size;
  const HCLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary),
      child: Center(child: Text('🐘', style: TextStyle(fontSize: size * 0.44))),
    );
  }
}

// ── Cabeçalho padrão das telas de auth ──────────────────────────────────────
class AuthHeader extends StatelessWidget {
  final String? subtitulo;
  const AuthHeader({super.key, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HCLogo(size: 80),
        const SizedBox(height: 10),
        Text('HumanaCare',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        Text(subtitulo ?? 'Cuidado que conecta',
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}

// ── Campo de texto padrão ────────────────────────────────────────────────────
class HCField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboard;
  final int maxLines;
  final Widget? suffix;

  const HCField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboard,
    this.maxLines = 1,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.inputFill,
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ── Campo com borda (usado no cadastro) ─────────────────────────────────────
class HCFieldBorda extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const HCFieldBorda({
    super.key,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.divider)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.divider)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ── Botão primário ───────────────────────────────────────────────────────────
class HCButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const HCButton({super.key, required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          disabledBackgroundColor: AppTheme.divider,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

// ── Botão outline ────────────────────────────────────────────────────────────
class HCOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? textColor;

  const HCOutlineButton({super.key, required this.label, this.onTap, this.borderColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor ?? AppTheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600,
            color: textColor ?? AppTheme.primary)),
      ),
    );
  }
}
