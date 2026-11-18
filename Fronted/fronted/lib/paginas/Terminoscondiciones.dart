import 'package:flutter/material.dart';
import 'package:fronted/colores/stilocolores.dart';
import 'package:google_fonts/google_fonts.dart';

class Terminoscondiciones extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTapTerminos;
  final VoidCallback onTapPrivacidad;

  const Terminoscondiciones({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onTapTerminos,
    required this.onTapPrivacidad,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: AppColors.azulClaro,
          checkColor: Colors.black,
          side: const BorderSide(color: AppColors.cian),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              children: [
                Text(
                  'Acepto los ',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
                ),
                GestureDetector(
                  onTap: onTapTerminos,
                  child: Text(
                    'términos y condiciones',
                    style: GoogleFonts.poppins(
                      color: AppColors.cian,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  ' y la ',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
                ),
                GestureDetector(
                  onTap: onTapPrivacidad,
                  child: Text(
                    'política de privacidad',
                    style: GoogleFonts.poppins(
                      color: AppColors.cian,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
