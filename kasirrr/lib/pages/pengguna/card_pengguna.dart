import 'package:apotek/models/pengguna.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardPengguna extends StatelessWidget {
  const CardPengguna({super.key, required this.pengguna, this.onEdit, this.onDelete, this.onResetPassword, this.onUpdateStatus});
  final Pengguna pengguna;
  final VoidCallback? onEdit, onDelete, onResetPassword;
  final Function(bool)? onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pengguna.username ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Switch(
                  value: pengguna.isAktif,
                  onChanged: onUpdateStatus,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(pengguna.nama ?? '-'),
            Text(
              (pengguna.role ?? '').toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF009d3c),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('email: ${pengguna.email ?? '-'}'),
            Text('telepon: ${pengguna.telepon ?? '-'}'),
            if (pengguna.createdAt != null)
              Text(
                'Dibuat: ${DateFormat('dd/MM/yyyy').format(pengguna.createdAt!)}',
                style: const TextStyle(color: Colors.grey),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF009d3c)),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: const Icon(Icons.lock_reset, color: Colors.orange),
                  onPressed: onResetPassword,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
