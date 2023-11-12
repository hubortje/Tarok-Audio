// Tarok Palčka - a simple tarock program.
// Copyright (C) 2023 Mitja Ševerkar
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockskis/stockskis.dart';
import 'package:tarok/constants.dart';
import 'package:tarok/sounds.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("settings".tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text("appearance".tr),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString("theme", value ? "dark" : "light");
                  THEME = prefs.getString("theme") ?? "dark";
                  if (THEME == "light") {
                    Get.changeThemeMode(ThemeMode.light);
                  } else {
                    Get.changeThemeMode(ThemeMode.dark);
                  }
                },
                initialValue: THEME == "dark",
                leading: const Icon(Icons.dark_mode),
                title: Text("dark_mode".tr),
                description: Text("use_dark_mode".tr),
              ),
            ],
          ),
          SettingsSection(
            title: Text("language".tr),
            tiles: [
              SettingsTile(
                leading: Radio<Locale>(
                  value: const Locale("en", "US"),
                  groupValue: LOCALE,
                  onChanged: (Locale? value) async {
                    if (value == null) return;
                    LOCALE = value;
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString(
                        "locale", "${value.languageCode}_${value.countryCode}");
                    Get.updateLocale(LOCALE);
                    setState(() {});
                  },
                ),
                title: const Text("English (United States)"),
              ),
              SettingsTile(
                leading: Radio<Locale>(
                  value: const Locale("sl", "SI"),
                  groupValue: LOCALE,
                  onChanged: (Locale? value) async {
                    if (value == null) return;
                    LOCALE = value;
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setString(
                        "locale", "${value.languageCode}_${value.countryCode}");
                    Get.updateLocale(LOCALE);
                    setState(() {});
                  },
                ),
                title: const Text("slovenščina (Slovenija)"),
              ),
            ],
          ),
          SettingsSection(
            title: Text("sound".tr),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("sounds", value);
                  SOUNDS_ENABLED = prefs.getBool("sounds") ?? true;
                  setState(() {});
                },
                initialValue: SOUNDS_ENABLED,
                leading: const Icon(Icons.music_note),
                title: Text("sound_effects".tr),
                description: Text("sound_effects_desc".tr),
              ),
            ],
          ),
          SettingsSection(
            title: Text("modifications".tr),
            tiles: [
              CustomSettingsTile(child: Text("modifications_desc".tr)),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("stockskis_predlogi", value);
                  OMOGOCI_STOCKSKIS_PREDLOGE =
                      prefs.getBool("stockskis_predlogi") ?? true;
                  setState(() {});
                },
                initialValue: OMOGOCI_STOCKSKIS_PREDLOGE,
                leading: const Icon(Icons.smart_toy),
                title: Text("stockskis_recommendations".tr),
                description: Text("stockskis_recommendations_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("napovedan_mondfang", value);
                  NAPOVEDAN_MONDFANG =
                      prefs.getBool("napovedan_mondfang") ?? false;
                  setState(() {});
                },
                initialValue: NAPOVEDAN_MONDFANG,
                leading: const Icon(Icons.timeline),
                title: Text("predicted_mondfang".tr),
                description: Text("predicted_mondfang_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("slepi_tarok", value);
                  SLEPI_TAROK = prefs.getBool("slepi_tarok") ?? false;
                  setState(() {});
                },
                initialValue: SLEPI_TAROK,
                leading: const Icon(Icons.blind),
                title: Text("blind_tarock".tr),
                description: Text("blind_tarock_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("skisfang", value);
                  SKISFANG = prefs.getBool("skisfang") ?? false;
                  setState(() {});
                },
                initialValue: SKISFANG,
                leading: const Icon(Icons.timeline),
                title: Text("skisfang".tr),
                description: Text("skisfang_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("avtopotrdi_zalozitev", value);
                  AVTOPOTRDI_ZALOZITEV =
                      prefs.getBool("avtopotrdi_zalozitev") ?? false;
                  setState(() {});
                },
                initialValue: AVTOPOTRDI_ZALOZITEV,
                leading: const Icon(Icons.precision_manufacturing),
                title: Text("autoconfirm_stash".tr),
                description: Text("autoconfirm_stash_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("avtolp", value);
                  AVTOLP = prefs.getBool("avtolp") ?? false;
                  setState(() {});
                },
                initialValue: AVTOLP,
                leading: const Icon(Icons.waving_hand),
                title: Text("autogreet".tr),
                description: Text("autogreet_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("premove", value);
                  PREMOVE = prefs.getBool("premove") ?? false;
                  setState(() {});
                },
                initialValue: PREMOVE,
                leading: const Icon(Icons.history),
                title: Text("premove".tr),
                description: Text("premove_desc".tr),
              ),
            ],
          ),
          SettingsSection(
            title: Text("developer_options".tr),
            tiles: [
              CustomSettingsTile(child: Text("developer_options_desc".tr)),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("developer_mode", value);
                  DEVELOPER_MODE = prefs.getBool("developer_mode") ?? false;
                  setState(() {});
                },
                initialValue: DEVELOPER_MODE,
                leading: const Icon(Icons.code),
                title: Text("developer_mode".tr),
                description: Text("developer_mode_desc".tr),
              ),
              if (!BARVIC && !BERAC)
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool("priredi_igro", value);
                    PRIREDI_IGRO = prefs.getBool("priredi_igro") ?? false;
                    setState(() {});
                  },
                  initialValue: PRIREDI_IGRO,
                  leading: const Text(
                    "🤫",
                    style: TextStyle(fontSize: 28),
                  ),
                  title: Text("falsify_game".tr),
                  description: Text("falsify_game_desc".tr),
                ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("garantiran_zaruf", value);
                  GARANTIRAN_ZARUF = prefs.getBool("garantiran_zaruf") ?? false;
                  setState(() {});
                },
                initialValue: GARANTIRAN_ZARUF,
                leading: const Icon(Icons.casino),
                title: Text("guaranteed_zaruf".tr),
                description: Text("guaranteed_zaruf_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("mond_v_talonu", value);
                  MOND_V_TALONU = prefs.getBool("mond_v_talonu") ?? false;
                  setState(() {});
                },
                initialValue: MOND_V_TALONU,
                leading: const Icon(Icons.casino),
                title: Text("mond_in_talon".tr),
                description: Text("mond_in_talon_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("skis_v_talonu", value);
                  SKIS_V_TALONU = prefs.getBool("skis_v_talonu") ?? false;
                  setState(() {});
                },
                initialValue: SKIS_V_TALONU,
                leading: const Icon(Icons.trending_down),
                title: Text("skis_in_talon".tr),
                description: Text("skis_in_talon_desc".tr),
              ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("odprte_igre", value);
                  ODPRTE_IGRE = prefs.getBool("odprte_igre") ?? false;
                  setState(() {});
                },
                initialValue: ODPRTE_IGRE,
                leading: const Icon(Icons.visibility),
                title: Text("open_games".tr),
                description: Text("open_games_desc".tr),
              ),
              if (!PRIREDI_IGRO && !BERAC)
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool("barvic", value);
                    BARVIC = prefs.getBool("barvic") ?? false;
                    setState(() {});
                  },
                  initialValue: BARVIC,
                  leading: const Icon(Icons.palette),
                  title: Text("color_valat".tr),
                  description: Text("color_valat_desc".tr),
                ),
              if (!PRIREDI_IGRO && !BARVIC)
                SettingsTile.switchTile(
                  onToggle: (value) async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool("berac", value);
                    BERAC = prefs.getBool("berac") ?? false;
                    setState(() {});
                  },
                  initialValue: BERAC,
                  leading: const Icon(Icons.money_off),
                  title: Text("beggar".tr),
                  description: Text("beggar_desc".tr),
                ),
              SettingsTile.switchTile(
                onToggle: (value) async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool("autostart_game", value);
                  AUTOSTART_GAME = prefs.getBool("autostart_game") ?? true;
                  setState(() {});
                },
                initialValue: AUTOSTART_GAME,
                leading: const Icon(Icons.pan_tool),
                title: Text("autostart_next_game".tr),
                description: Text("autostart_next_game_desc".tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
