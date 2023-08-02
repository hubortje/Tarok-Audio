class StihAnalysis {
  StihAnalysis({required this.cardPicks, required this.worth});

  Card cardPicks;
  int worth;
}

class SimpleUser {
  SimpleUser({
    required this.id,
    required this.name,
    //this.points,
  });

  final String id;
  final String name;
  int radlci = 0;
  int licitiral = -2;
  List<ResultsPoints> points = [];
  int total = 0;
  bool endGame = false;
  bool connected = true;
  //int rating;
}

class Stih {
  Stih();

  List<Card> stih = [];
  String? picksUp;
}

class Card {
  Card({required this.card, required this.user});

  final LocalCard card;
  String user;
}

class Move {
  Move({required this.card, required this.evaluation});

  final Card card;
  final int evaluation;
}

class Predictions {
  Predictions({
    SimpleUser? kraljUltimo,
    this.kraljUltimoKontra = 0,
    SimpleUser? kraljUltimoKontraDal,
    SimpleUser? trula,
    SimpleUser? kralji,
    SimpleUser? pagatUltimo,
    this.pagatUltimoKontra = 0,
    SimpleUser? pagatUltimoKontraDal,
    SimpleUser? igra,
    this.igraKontra = 0,
    SimpleUser? igraKontraDal,
    SimpleUser? valat,
    this.valatKontra = 0,
    SimpleUser? valatKontraDal,
    SimpleUser? barvniValat,
    this.barvniValatKontra = 0,
    SimpleUser? barvniValatKontraDal,
    this.gamemode = -1,
    this.changed = false,
  })  : kraljUltimo = kraljUltimo ?? SimpleUser(id: "", name: ""),
        kraljUltimoKontraDal =
            kraljUltimoKontraDal ?? SimpleUser(id: "", name: ""),
        trula = trula ?? SimpleUser(id: "", name: ""),
        kralji = kralji ?? SimpleUser(id: "", name: ""),
        pagatUltimo = pagatUltimo ?? SimpleUser(id: "", name: ""),
        pagatUltimoKontraDal =
            pagatUltimoKontraDal ?? SimpleUser(id: "", name: ""),
        igra = igra ?? SimpleUser(id: "", name: ""),
        igraKontraDal = igraKontraDal ?? SimpleUser(id: "", name: ""),
        valat = valat ?? SimpleUser(id: "", name: ""),
        valatKontraDal = valatKontraDal ?? SimpleUser(id: "", name: ""),
        barvniValat = barvniValat ?? SimpleUser(id: "", name: ""),
        barvniValatKontraDal =
            barvniValatKontraDal ?? SimpleUser(id: "", name: "");

  SimpleUser kraljUltimo;
  int kraljUltimoKontra;
  SimpleUser kraljUltimoKontraDal;

  SimpleUser trula;
  SimpleUser kralji;

  SimpleUser pagatUltimo;
  int pagatUltimoKontra;
  SimpleUser pagatUltimoKontraDal;

  SimpleUser igra;
  int igraKontra;
  SimpleUser igraKontraDal;

  SimpleUser valat;
  int valatKontra;
  SimpleUser valatKontraDal;

  SimpleUser barvniValat;
  int barvniValatKontra;
  SimpleUser barvniValatKontraDal;

  int gamemode;
  bool changed;
}

class User {
  User({
    required this.user,
    required this.cards,
    required this.playing,
    required this.secretlyPlaying,
    required this.botType,
    required this.licitiral,
  });

  final SimpleUser user;
  List<Card> cards;
  // uporabnik igra, ve se da on igra
  bool playing;
  // uporabnik igra, ampak se še ne ve, kajti kralj ni padel
  bool secretlyPlaying;
  // licitiral
  bool licitiral;
  // bot
  final String botType;
}

class LocalCard {
  LocalCard({
    required this.asset,
    required this.worth,
    required this.worthOver,
    required this.alt,
    this.showZoom = false,
    this.valid = false,
  });

  final String asset;
  final int worth;
  final int worthOver;
  final String alt;
  bool showZoom;
  bool valid;
}

class MessagesStih {
  MessagesStih({
    required this.card,
    required this.worth,
    required this.pickedUpByPlaying,
    required this.pickedUpBy,
  });

  List<Card> card;
  double worth;
  bool pickedUpByPlaying;
  String pickedUpBy;
}

class Results {
  Results({
    required this.user,
    required this.stih,
  });

  List<ResultsUser> user;
  List<MessagesStih> stih;
}

class ResultsUser {
  ResultsUser({
    required this.user,
    required this.playing,
    this.points = 0,
    this.trula = 0,
    this.pagat = 0,
    this.igra = 0,
    this.razlika = 0,
    this.kralj = 0,
    this.kralji = 0,
    this.kontraPagat = 0,
    this.kontraIgra = 0,
    this.kontraKralj = 0,
    this.mondfang = false,
    this.showGamemode = false,
    this.showDifference = false,
    this.showKralj = false,
    this.showPagat = false,
    this.showKralji = false,
    this.showTrula = false,
    this.radelc = false,
  });

  Iterable<SimpleUser> user;
  bool playing;
  int points;
  int trula;
  int pagat;
  int igra;
  int razlika;
  int kralj;
  int kralji;
  int kontraPagat;
  int kontraIgra;
  int kontraKralj;
  bool mondfang;
  bool showGamemode;
  bool showDifference;
  bool showKralj;
  bool showPagat;
  bool showKralji;
  bool showTrula;
  bool radelc;
}

class ResultsPoints {
  ResultsPoints({
    required this.points,
    required this.playing,
    required this.results,
    required this.radelc,
  });

  int points;
  bool playing;
  Results results;
  bool radelc;
}

class StartPredictions {
  bool kraljUltimoKontra = false;
  bool pagatUltimoKontra = false;
  bool igraKontra = false;
  bool valatKontra = false;
  bool barvniValatKontra = false;
  bool pagatUltimo = false;
  bool trula = false;
  bool kralji = false;
  bool kraljUltimo = false;
  bool valat = false;
  bool barvniValat = false;
}

class LocalGame {
  LocalGame({
    required this.id,
    required this.name,
    required this.playsThree,
    required this.worth,
  });

  final int id;
  final String name;
  final bool playsThree;
  final int worth;

  LocalGame.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        playsThree = json["playsThree"],
        worth = json["worth"];

  static Map toJson(LocalGame game) {
    return {
      "id": game.id,
      "name": game.name,
      "playsThree": game.playsThree,
      "worth": game.worth,
    };
  }
}
