import 'package:flutter/material.dart';
import 'package:imperio_tribal_app/data/models/user_model.dart';
import 'package:imperio_tribal_app/data/models/village_model.dart';

class VillageMarker extends StatelessWidget {
  final VillageModel village;
  final UserModel user;
  final VoidCallback? onTap;
  final bool isSelected;

  const VillageMarker({
    super.key,
    required this.village,
    required this.user,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = user.id == village.userId && !user.isNpc;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCurrentUser ? Colors.green[800] : Colors.red[800],
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.yellow.withAlpha(102),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          children: [
            // Ícone do castelo
            const Center(
              child: Icon(Icons.castle, color: Colors.white, size: 24),
            ),
            // Bandeira (apenas para sua aldeia)
            if (isCurrentUser)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            // Nível do castelo
            Positioned(
              left: 2,
              bottom: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
