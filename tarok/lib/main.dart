import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FormData;
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockskis/stockskis.dart' hide debugPrint, Card;
import 'package:tarok/about.dart';
import 'package:tarok/constants.dart';
import 'package:tarok/friends.dart';
import 'package:tarok/game.dart';
import 'package:tarok/game/variables.dart';
import 'package:tarok/login.dart';
import 'package:tarok/register.dart';
import 'package:tarok/settings.dart';
import 'package:tarok/sounds.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> preloadCards(BuildContext context) async {
  for (int i = 0; i < CARDS.length; i++) {
    LocalCard card = CARDS[i];
    await precacheImage(
      AssetImage("assets/tarok${card.asset}.webp"),
      context,
    );
  }
}

Future<String?> replayFetch(String url) async {
  final r = RegExp(r"(https:\/\/.*\/replay\/)(.*)(\?password=)(.*)");
  final match = r.firstMatch(url);
  if (match == null) {
    return null;
  }
  String? uid = match.group(2);
  if (uid == null) {
    return null;
  }
  String? password = match.group(4);
  if (password == null) {
    return null;
  }
  password = Uri.encodeFull(password);
  uid = Uri.encodeFull(uid);

  debugPrint("$uid $password");

  final token = await storage.read(key: "token");
  if (token == null) return null;
  final response = await dio.get(
    '$BACKEND_URL/replay/$uid?password=$password',
    options: Options(
      headers: {"X-Login-Token": await storage.read(key: "token")},
    ),
  );
  return response.data;
}

Future<void> joinReplay(String url) async {
  String? r = await replayFetch(url);
  if (r == null) {
    return;
  }
  Map s = jsonDecode(r);
  String gameId = s["replayId"].toString();
  String players = s["playerCount"].toString();
  Get.toNamed("/game", parameters: {
    "playing": players,
    "gameId": gameId,
    "bots": "false",
    "replay": "true",
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();

  //binding.addPostFrameCallback((_) async {
  //  BuildContext? context = binding.rootElement;
  //  if (context != null) {
  //    await preloadCards(context);
  //  }
  //});
  MediaKit.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  PRIREDI_IGRO = prefs.getBool("priredi_igro") ?? false;
  GARANTIRAN_ZARUF = prefs.getBool("garantiran_zaruf") ?? false;
  ODPRTE_IGRE = prefs.getBool("odprte_igre") ?? false;
  AUTOSTART_GAME = prefs.getBool("autostart_game") ?? true;
  BARVIC = prefs.getBool("barvic") ?? false;
  OMOGOCI_STOCKSKIS_PREDLOGE = prefs.getBool("stockskis_predlogi") ?? true;
  SLEPI_TAROK = prefs.getBool("slepi_tarok") ?? false;
  BERAC = prefs.getBool("berac") ?? false;
  AVTOPOTRDI_ZALOZITEV = prefs.getBool("avtopotrdi_zalozitev") ?? false;
  AVTOLP = prefs.getBool("avtolp") ?? false;
  PREMOVE = prefs.getBool("premove") ?? false;
  MOND_V_TALONU = prefs.getBool("mond_v_talonu") ?? false;
  SKISFANG = prefs.getBool("skisfang") ?? false;
  SKIS_V_TALONU = prefs.getBool("skis_v_talonu") ?? false;
  NAPOVEDAN_MONDFANG = prefs.getBool("napovedan_mondfang") ?? false;
  THEME = prefs.getString("theme") ?? "dark";
  SOUNDS_ENABLED = prefs.getBool("sounds") ?? true;

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    GetMaterialApp(
      title: 'Tarok palcka.si',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MyHomePage()),
        GetPage(name: '/game', page: () => const Game()),
        GetPage(name: '/settings', page: () => const Settings()),
        GetPage(name: '/login', page: () => const Login()),
        GetPage(name: '/registration', page: () => const Register()),
        GetPage(name: '/friends', page: () => const Friends()),
        GetPage(name: '/about', page: () => const About()),
        GetPage(
          name: '/replay/:id',
          page: () => FutureBuilder(
            future: joinReplay(
                "https://palcka.si/replay/${Get.parameters['id']}?password=${Get.parameters['password']}"),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return const SizedBox();
            },
          ),
        ),
      ],
      darkTheme: ThemeData(
        primaryColor: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: THEME == "light" ? ThemeMode.light : ThemeMode.dark,
      home: const MyHomePage(),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isAdmin = false;
  List codes = [];
  List botNames = [];
  late TextEditingController _controller;
  late TextEditingController _playerNameController;
  late TextEditingController _replayController;
  bool renderLogin = false;
  bool guest = false;
  bool mondfang = false;
  bool skisfang = false;
  bool napovedanMondfang = false;
  double pribitek = 2;
  double zacetniCas = 20;
  bool party = false;
  List priorityQueue = [];
  List queue = [];
  late Timer t;

  void dialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Izberite igro'),
            content: Column(
              children: guest
                  ? []
                  : [
                      const Text('Sekund na potezo (pribitek)'),
                      Slider(
                        value: pribitek,
                        max: 5,
                        divisions: 10,
                        label: pribitek.toString(),
                        onChanged: (double value) {
                          setState(() {
                            pribitek = value;
                          });
                        },
                      ),
                      const Text('Začetni čas (sekund)'),
                      Slider(
                        value: zacetniCas,
                        min: 15,
                        max: 45,
                        divisions: 6,
                        label: zacetniCas.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            zacetniCas = value;
                          });
                        },
                      ),
                      const Text('Zasebna partija'),
                      Switch(
                        value: party,
                        onChanged: (bool value) {
                          setState(() {
                            party = value;
                          });
                        },
                      ),
                      const Text('Vsi igralci dobijo radelce na mondfang'),
                      Switch(
                        value: mondfang,
                        onChanged: (bool value) {
                          setState(() {
                            mondfang = value;
                          });
                        },
                      ),
                      const Text('-100 dol za igralca, ki izgubi škisa'),
                      Switch(
                        value: skisfang,
                        onChanged: (bool value) {
                          setState(() {
                            skisfang = value;
                          });
                        },
                      ),
                      const Text('Napovedan mondfang'),
                      Switch(
                        value: napovedanMondfang,
                        onChanged: (bool value) {
                          setState(() {
                            napovedanMondfang = value;
                          });
                        },
                      ),
                    ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (guest) {
                    botGame(3);
                    return;
                  }
                  await newGame(3);
                },
                child: const Text('V tri'),
              ),
              TextButton(
                onPressed: () async {
                  if (guest) {
                    botGame(4);
                    return;
                  }
                  await newGame(4);
                },
                child: const Text('V štiri'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> newGame(int players) async {
    final token = await storage.read(key: "token");
    if (token == null) return;
    final response = await dio.post(
      '$BACKEND_URL/game/new/$players/normal',
      data: FormData.fromMap({
        "private": party,
        "zacetniCas": zacetniCas.round(),
        "pribitek": pribitek,
        "skisfang": skisfang,
        "mondfang": mondfang,
        "napovedanMondfang": napovedanMondfang,
      }),
      options: Options(
        headers: {"X-Login-Token": await storage.read(key: "token")},
      ),
    );
    String gameId = response.data.toString();
    debugPrint(response.statusCode.toString());
    debugPrint(gameId);
    // ignore: use_build_context_synchronously
    //Navigator.pop(context);
    // ignore: use_build_context_synchronously
    Get.toNamed("/game", parameters: {
      "playing": players.toString(),
      "gameId": gameId,
      "bots": "false",
    });
  }

  Future<void> quickGameFind(int players, String tip) async {
    final token = await storage.read(key: "token");
    if (token == null) return;
    final response = await dio.post(
      '$BACKEND_URL/quick',
      data: FormData.fromMap({"players": players, "tip": tip}),
      options: Options(
        headers: {"X-Login-Token": await storage.read(key: "token")},
      ),
    );
    String gameId = response.data.toString();
    Get.toNamed("/game", parameters: {
      "playing": players.toString(),
      "gameId": gameId,
      "bots": "false",
    });
  }

  void botGame(int players) {
    Get.toNamed("/game", parameters: {
      "playing": players.toString(),
      "gameId": "",
      "bots": "true",
    });
  }

  void rerenderLogin() {
    storage.read(key: "token").then((value) {
      renderLogin = value == null;
      guest = value == "a";
      setState(() {});
    });
  }

  Future<void> fetchGames() async {
    try {
      final response = await dio.get(
        "$BACKEND_URL/games",
        options: Options(
          headers: {"X-Login-Token": await storage.read(key: "token")},
        ),
      );
      if (response.statusCode != 200) return;
      print(response.data);
      final data = jsonDecode(response.data);
      print(data);
      priorityQueue = data["priorityGames"];
      queue = data["games"];
      setState(() {});
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    storage.read(key: "role").then((value) {
      debugPrint(value);
      isAdmin = value == "admin";
      if (!isAdmin) return;
      setState(() {});
    });
    fetchGames();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      t = timer;
      try {
        fetchGames();
      } catch (e) {}
    });
    _controller = TextEditingController();
    _playerNameController = TextEditingController();
    _replayController = TextEditingController();
    rerenderLogin();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _playerNameController.dispose();
    _replayController.dispose();
    t.cancel();
  }

  Future<List> getRegistrationCodes() async {
    final response = await dio.get(
      "$BACKEND_URL/admin/reg_code",
      options: Options(
        headers: {"X-Login-Token": await storage.read(key: "token")},
      ),
    );
    if (response.statusCode != 200) return codes;
    debugPrint(response.data);
    try {
      codes = jsonDecode(response.data);
    } catch (e) {
      codes = [];
    }
    return codes;
  }

  Future getBots() async {
    String? response = await storage.read(key: "bots");
    if (response == null) {
      await storage.write(key: "bots", value: "[]");
      response = "[]";
    }
    botNames = jsonDecode(response);
  }

  Future<void> newBot(String name, String type) async {
    botNames.add({"name": name, "type": type});
    await storage.write(key: "bots", value: jsonEncode(botNames));
    await getBots();
  }

  String randomBotName() {
    for (int i = 0; i < BOTS.length; i++) {
      Map bot = BOTS[i];
      if (bot["type"] != dropdownValue["type"]) continue;
      int preferred = Random().nextInt(bot["preferred_names"].length);
      return bot["preferred_names"][preferred];
    }
    int preferred = Random().nextInt(BOT_NAMES.length);
    return BOT_NAMES[preferred];
  }

  Future<void> deleteBot(String name, String type) async {
    for (int i = 0; i < botNames.length; i++) {
      Map bot = botNames[i];
      if (bot["type"] != type || bot["name"] != name) continue;
      debugPrint("Here I am");
      botNames.removeAt(i);
      await storage.write(key: "bots", value: jsonEncode(botNames));
      return;
    }
  }

  Map dropdownValue = BOTS.first;

  @override
  Widget build(BuildContext context) {
    if (renderLogin) {
      return const Login();
    }
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Palčka.si tarok program',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Domov'),
              onTap: () {
                Get.toNamed("/");
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Prijatelji'),
              onTap: () {
                Get.toNamed("/friends");
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Palčka"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              Get.toNamed("/settings");
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () async {
              Get.toNamed("/about");
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await storage.deleteAll();
              Get.toNamed("/login");
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            const Center(
              child: Text(
                'Dobrodošli v Palčka tarok programu.',
                style: TextStyle(fontSize: 40),
              ),
            ),
            if (guest)
              const Center(
                child: Text(
                  "Uporabljate gostujoči dostop",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            const Center(
              child: Text(
                "Igre na voljo",
                style: TextStyle(fontSize: 30),
              ),
            ),
            if (!guest)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("S pravimi igralci"),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  onPressed: () => quickGameFind(3, "normal"),
                  label: const Text(
                    "V tri",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  icon: const Icon(Icons.face),
                ),
                ElevatedButton.icon(
                  onPressed: () => quickGameFind(4, "normal"),
                  label: const Text(
                    "V štiri",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  icon: const Icon(Icons.face),
                ),
              ]),
            if (!guest)
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text("Klepetalnica"),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton.icon(
                  onPressed: () => quickGameFind(3, "klepetalnica"),
                  label: const Text(
                    "V tri",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  icon: const Icon(Icons.face),
                ),
                ElevatedButton.icon(
                  onPressed: () => quickGameFind(4, "klepetalnica"),
                  label: const Text(
                    "V štiri",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  icon: const Icon(Icons.face),
                ),
              ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Z računalniškimi igralci"),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () => botGame(3),
                label: const Text(
                  "V tri",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                icon: const Icon(Icons.smart_toy),
              ),
              ElevatedButton.icon(
                onPressed: () => botGame(4),
                label: const Text(
                  "V štiri",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                icon: const Icon(Icons.smart_toy),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            if (isAdmin)
              Center(
                child: ElevatedButton(
                  onPressed: () => showDialog<String>(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('Administratorska plošča'),
                            content: SingleChildScrollView(
                              child: Column(children: [
                                const Text(
                                  'Na tej plošči lahko kot administrator urejate razne nastavitve tarok programa Palčka',
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                FutureBuilder(
                                  future: getRegistrationCodes(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData) {
                                      return DataTable(
                                        columns: const <DataColumn>[
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Registracijska koda',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Izbriši',
                                                style: TextStyle(
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: [
                                          ...codes.map(
                                            (code) => DataRow(
                                              cells: <DataCell>[
                                                DataCell(Text(code["Code"])),
                                                DataCell(
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () async {
                                                      await dio.delete(
                                                        "$BACKEND_URL/admin/reg_code",
                                                        data: FormData.fromMap(
                                                          {
                                                            "code":
                                                                code["Code"],
                                                          },
                                                        ),
                                                        options: Options(
                                                          headers: {
                                                            "X-Login-Token":
                                                                await storage.read(
                                                                    key:
                                                                        "token")
                                                          },
                                                        ),
                                                      );
                                                      getRegistrationCodes();
                                                      setState(() {});
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                                Row(children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        labelText: 'Nova registracijska koda',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.save),
                                    onPressed: () async {
                                      await dio.post(
                                        "$BACKEND_URL/admin/reg_code",
                                        data: FormData.fromMap(
                                          {
                                            "code": _controller.text,
                                          },
                                        ),
                                        options: Options(
                                          headers: {
                                            "X-Login-Token":
                                                await storage.read(key: "token")
                                          },
                                        ),
                                      );
                                      getRegistrationCodes();
                                      setState(() {});
                                    },
                                  ),
                                ]),
                              ]),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        });
                      }),
                  child: const Text("Administratorska plošča"),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => showDialog<String>(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Posnetek igre'),
                          content: SingleChildScrollView(
                            child: Column(children: [
                              const Text(
                                'Tukaj lahko vpišete URL do posnetka igre',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(children: [
                                Expanded(
                                  child: TextField(
                                    controller: _replayController,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Povezava do posnetka igre',
                                    ),
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Prekliči'),
                            ),
                            TextButton(
                              onPressed: () {
                                joinReplay(_replayController.text);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      });
                    }),
                child: const Text("Posnetek igre"),
              ),
            ),

            const SizedBox(
              height: 10,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => showDialog<String>(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Prilagodi računalniške igralce'),
                          content: SingleChildScrollView(
                            child: Column(children: [
                              const Text(
                                'Tukaj lahko urejate, kakšne bote želite videti v svojih igrah. Program bo ob vstopu v igro avtomatično izbral naključne igralce iz tega seznama, če jih je vsaj toliko, kot zahteva ta igra.',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              FutureBuilder(
                                future: getBots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (botNames.isNotEmpty) {
                                    return DataTable(
                                      columns: const <DataColumn>[
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Bot',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Ime',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Expanded(
                                            child: Text(
                                              'Izbriši',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: [
                                        ...botNames.map(
                                          (e) => DataRow(
                                            cells: <DataCell>[
                                              DataCell(Text(e["type"])),
                                              DataCell(Text(e["name"])),
                                              DataCell(
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () async {
                                                    await deleteBot(
                                                      e["name"],
                                                      e["type"],
                                                    );
                                                    await getBots();
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                              Row(children: [
                                Expanded(
                                  child: TextField(
                                    controller: _playerNameController,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'Ime igralca',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.replay_outlined),
                                  onPressed: () async {
                                    String botName = randomBotName();
                                    _playerNameController.text = botName;
                                    setState(() {});
                                  },
                                ),
                              ]),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: SegmentedButton<Map>(
                                  segments: <ButtonSegment<Map>>[
                                    ...BOTS.map(
                                      (e) => ButtonSegment<Map>(
                                        value: e,
                                        label: Text(e["name"].toString()),
                                      ),
                                    )
                                  ],
                                  selected: <Map>{dropdownValue},
                                  onSelectionChanged: (Set<Map> newSelection) {
                                    setState(() {
                                      dropdownValue = newSelection.first;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await newBot(
                                    _playerNameController.text,
                                    dropdownValue["type"],
                                  );
                                  setState(() {});
                                },
                                label: const Text(
                                  "Dodaj bota na seznam",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ]),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Končaj z urejanjem'),
                            ),
                          ],
                        );
                      });
                    }),
                child: const Text("Prilagodi računalniške igralce"),
              ),
            ),

            // PRIORITY QUEUE
            GridView.count(
              crossAxisCount: 4,
              physics:
                  const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
              shrinkWrap: true,
              children: [
                ...priorityQueue.map(
                  (e) => GestureDetector(
                    onTap: () {
                      Get.toNamed("/game", parameters: {
                        "playing": e["RequiredPlayers"],
                        "gameId": e["ID"],
                        "bots": "false",
                      });
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                                'Igra ${e["StartTime"]}+${e["AdditionalTime"]} ${e["MondfangRadelci"] || e["Skisfang"] || e["NapovedanMondfang"] ? "+ modifikacije" : ""} ${e["Type"] == "klepetalnica" ? "(klepetalnica)" : ""}'),
                          ),
                          if (e["MondfangRadelci"])
                            const Center(
                              child: Text('Mondfang radelci'),
                            ),
                          if (e["Skisfang"])
                            const Center(
                              child: Text('Škisfang'),
                            ),
                          if (e["NapovedanMondfang"])
                            const Center(
                              child: Text('Napovedan mondfang'),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          ...(e["Users"] as List).map(
                            (k) => SizedBox(
                              height: 40,
                              child: Text(
                                k["Name"],
                                style: const TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(
                            e["RequiredPlayers"] - e["Users"].length,
                            (index) => const SizedBox(
                              height: 40,
                              child: Text(
                                "Pridružite se igri",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // QUEUE
            GridView.count(
              crossAxisCount: 4,
              physics:
                  const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
              shrinkWrap: true,
              children: [
                ...queue.map(
                  (e) => GestureDetector(
                    onTap: () {
                      Get.toNamed("/game", parameters: {
                        "playing": e["RequiredPlayers"],
                        "gameId": e["ID"],
                        "bots": "false",
                      });
                    },
                    child: Card(
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                                'Igra ${e["StartTime"]}+${e["AdditionalTime"]} ${e["MondfangRadelci"] || e["Skisfang"] || e["NapovedanMondfang"] ? "+ modifikacije" : ""} ${e["Type"] == "klepetalnica" ? "(klepetalnica)" : ""}'),
                          ),
                          if (e["MondfangRadelci"])
                            const Center(
                              child: Text('Mondfang radelci'),
                            ),
                          if (e["Skisfang"])
                            const Center(
                              child: Text('Škisfang'),
                            ),
                          if (e["NapovedanMondfang"])
                            const Center(
                              child: Text('Napovedan mondfang'),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          ...(e["Users"] as List).map(
                            (k) => SizedBox(
                              height: 40,
                              child: Text(
                                k["Name"],
                                style: const TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(
                            e["RequiredPlayers"] - e["Users"].length,
                            (index) => const SizedBox(
                              height: 40,
                              child: Text(
                                "Pridružite se igri",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: dialog,
        tooltip: 'Ustvari novo igro',
        child: const Icon(Icons.add),
      ),
    );
  }
}
