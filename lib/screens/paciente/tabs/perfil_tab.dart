import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/app_state.dart';
import '../../../models/models.dart';

class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});
  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  int _aba = 0; // 0 Informações · 1 Histórico · 2 Documentos

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppState>().paciente;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            Center(
              child: Text('Perfil',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppTheme.primary),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 26),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: AppTheme.accent),
                          child: const Icon(Icons.add,
                              size: 13, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nome,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      Text('ID: ${p.id}',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _abaItem('Informações', 0),
                _abaItem('Histórico', 1),
                _abaItem('Documentos', 2),
              ],
            ),
            const SizedBox(height: 16),
            if (_aba == 0)
              _informacoes(p)
            else
              _placeholder(_aba == 1
                  ? 'Nenhum registro no histórico ainda.'
                  : 'Nenhum documento anexado ainda.'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _abaItem(String label, int i) {
    final on = _aba == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _aba = i),
        child: Column(
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                    color: on ? AppTheme.primary : AppTheme.textLight)),
            const SizedBox(height: 6),
            Container(
                height: 2,
                color: on ? AppTheme.primary : Colors.transparent),
          ],
        ),
      ),
    );
  }

  Widget _informacoes(Paciente p) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              _linha('Data de nascimento', p.dataNascimento),
              _linha('Sexo', p.sexo),
              _linha('Estado civil', p.estadoCivil),
              _linha('Endereço', p.endereco),
              _linha('Telefone', p.telefone),
              Divider(color: AppTheme.divider, height: 18),
              _linha('Tipo sanguíneo', p.tipoSanguineo),
              _linha('Condições de saúde', p.condicaoSaude),
              _linha('Alergias', p.alergias),
              _linha('Uso de dispositivos', p.dispositivos),
              _linha('Observações', p.observacoes),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Cuidador Principal',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppTheme.primary),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p.cuidadorNome,
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFBFE3CE),
                                  borderRadius: BorderRadius.circular(999)),
                              child: Text('Familiar',
                                  style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F6E5A))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Turno : ${p.cuidadorTurno}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        Text('Carga horária : ${p.cuidadorCarga}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: AppTheme.textLight),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Trocar perfil para cuidador',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      backgroundColor: AppTheme.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.divider),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Trocar perfil para cuidador',
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linha(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(k,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTheme.primary)),
            ),
            Expanded(
              flex: 5,
              child: Text(v,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ),
          ],
        ),
      );

  Widget _placeholder(String txt) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            const Icon(Icons.folder_open_outlined,
                size: 40, color: AppTheme.textLight),
            const SizedBox(height: 10),
            Text(txt,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );
}
