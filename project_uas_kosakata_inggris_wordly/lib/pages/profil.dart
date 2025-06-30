import 'package:flutter/material.dart';
import '../main.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({Key? key}) : super(key: key);

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: colorScheme.surfaceVariant,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: const AssetImage('assets/images/img.png'),
                    backgroundColor: colorScheme.primary.withOpacity(0.2),
                    radius: 50,
                  ),
                ),
                const SizedBox(width: 24), // Jarak diperbesar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kucheng',
                          style: TextStyle(
                            fontSize: 20, // Perbesar font
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          )),
                      const SizedBox(height: 8), // Tambah spacing
                      Text(
                        'Lorem\nLorem ipsum',
                        style: TextStyle(
                          fontSize: 16, // Perbesar font
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20), // Tambah spacing antar card
        Card(
          color: colorScheme.surfaceVariant,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12), // Tambah padding
            child: SwitchListTile(
              title: Text('Dark Mode',
                  style: TextStyle(
                    fontSize: 18, // Perbesar font
                    color: colorScheme.onSurface,
                  )),
              activeColor: colorScheme.primary,
              value: isDark,
              onChanged: (val) {
                setState(() => isDark = val);
                MyApp.of(context)!.setTheme(isDark);
              },
            ),
          ),
        ),
      ],
    );
  }
}