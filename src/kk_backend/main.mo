import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Char "mo:base/Char";
import Error "mo:base/Error";
import Float "mo:base/Float";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Map "mo:base/HashMap";
import Int "mo:base/Int";
import Int16 "mo:base/Int16";
import Int8 "mo:base/Int8";
import Iter "mo:base/Iter";
import L "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Trie2D "mo:base/Trie";

import Types "main.types";
import Helper "utils/Helper";
import Constants "utils/Constants";
import Internals "utils/Internals";

actor Main {
  // containers
  private stable var _news : Trie.Trie<Types.newsId, Types.News> = Trie.empty();
  private stable var _banners : Trie.Trie<Types.bannerId, Types.Banner> = Trie.empty();
  private stable var _users : Trie.Trie<Types.userId, Types.User> = Trie.empty();
  private stable var _events : Trie.Trie<Types.eventId, Types.Event> = Trie.empty();
  private stable var _tags : Trie.Trie<Types.tagId, Types.Tag> = Trie.empty();

  private stable var newsId : Nat = 0;
  private stable var eventId : Nat = 0;
  private stable var bannerId : Nat = 0;

  private var _subEmails : Buffer.Buffer<Text> = Buffer.Buffer<Text>(0);
  private stable var _stableSubEmails : [Text] = [];

  // pre/post upgrade
  system func preupgrade() {
    _stableSubEmails := Buffer.toArray(_subEmails);
  };
  system func postupgrade() {
    _subEmails := Buffer.fromArray(_stableSubEmails);
    _stableSubEmails := [];
  };

  // CRUD News
  public shared ({ caller }) func createNews(news : Types.News) : async (Result.Result<Types.News, Text>) {
    if (Helper.isAdmin(caller) == false) {
      return #err("Only admin can create news");
    };
    //check for tags
    for (tagId in (news.tags).vals()) {
      if (Internals.isTagAvailable_(_tags, tagId) == false) {
        return #err(tagId # " tag id not found");
      };
    };
    let id = Nat.toText(newsId);
    _news := Trie.put(_news, Helper.keyT(id), Text.equal, news).0;
    _tags := Internals.addNewsIdToTags_(_tags, news.tags, id);
    newsId := newsId + 1;
    return #ok(news);
  };
  public shared ({ caller }) func updateNews(id : Types.newsId, news : Types.News) : async (Result.Result<Types.News, Text>) {
    if (Helper.isAdmin(caller) == false) {
      return #err("Only admin can update news");
    };
    switch (Trie.find(_news, Helper.keyT(id), Text.equal)) {
      case (?n) {
        _news := Trie.put(_news, Helper.keyT(id), Text.equal, news).0;
        return #ok(news);
      };
      case _ {
        return #err("news not exist");
      };
    };
  };
  public query func readNews(id : Types.newsId) : async (Result.Result<Types.News, Text>) {
    switch (Trie.find(_news, Helper.keyT(id), Text.equal)) {
      case (?n) {
        return #ok(n);
      };
      case _ {
        #err("news not found");
      };
    };
  };
  public query func readAllNews(offset : Nat, limit : Nat) : async ([Types.News]) {
    var b : Buffer.Buffer<Types.News> = Buffer.Buffer<Types.News>(0);
    for ((ind, news) in Trie.iter(_news)) {
      b.add(news);
    };
    var start : Nat = offset;
    var end : Nat = offset + limit;
    let size : Nat = Trie.size(_news);
    if (size < end) {
      end := size;
    };
    let news_arr : [Types.News] = Buffer.toArray(b);
    b := Buffer.Buffer<Types.News>(0);
    while (start < end) {
      b.add(news_arr[start]);
      start := start + 1;
    };
    return Buffer.toArray(b);
  };

  // CRUD Banners
  public shared ({ caller }) func createBanner(banner : Types.Banner) : async (Result.Result<Types.Banner, Text>) {
    if (Helper.isAdmin(caller) == false) {
      return #err("Only admin can create banner");
    };
    let id : Text = Nat.toText(bannerId);
    _banners := Trie.put(_banners, Helper.keyT(id), Text.equal, banner).0;
    bannerId := bannerId + 1;
    return #ok(banner);
  };
  public shared ({ caller }) func updateBanner(id : Types.bannerId, banner : Types.Banner) : async (Result.Result<Types.Banner, Text>) {
    if (Helper.isAdmin(caller) == false) {
      return #err("Only admin can update banner");
    };
    switch (Trie.find(_banners, Helper.keyT(id), Text.equal)) {
      case (?b) {
        _banners := Trie.put(_banners, Helper.keyT(id), Text.equal, banner).0;
        return #ok(banner);
      };
      case _ {
        return #err("banner not exist");
      };
    };
  };
  public query func readBanner(id : Types.bannerId) : async (Result.Result<Types.Banner, Text>) {
    switch (Trie.find(_banners, Helper.keyT(id), Text.equal)) {
      case (?b) {
        return #ok(b);
      };
      case _ {
        #err("banner not found");
      };
    };
  };
  public query func readAllBanners(offset : Nat, limit : Nat) : async ([Types.Banner]) {
    var b : Buffer.Buffer<Types.Banner> = Buffer.Buffer<Types.Banner>(0);
    for ((ind, banner) in Trie.iter(_banners)) {
      b.add(banner);
    };
    var start : Nat = offset;
    var end : Nat = offset + limit;
    let size : Nat = Trie.size(_banners);
    if (size < end) {
      end := size;
    };
    let banners_arr : [Types.Banner] = Buffer.toArray(b);
    b := Buffer.Buffer<Types.Banner>(0);
    while (start < end) {
      b.add(banners_arr[start]);
      start := start + 1;
    };
    return Buffer.toArray(b);
  };

  // CRUD Events
  public shared ({ caller }) func createEvent(event : Types.Event) : async (Result.Result<Types.Event, Text>) {
    if (Helper.isAdmin(caller) == false) {
      return #err("Only admin can create event");
    };
    let id : Text = Nat.toText(eventId);
    _events := Trie.put(_events, Helper.keyT(id), Text.equal, event).0;
    eventId := eventId + 1;
    return #ok(event);
  };
  public shared ({ caller }) func updateEvent(id : Types.eventId, event : Types.Event) : async (Result.Result<Types.Event, Text>) {
    if (Helper.isAdmin(caller) == false) {
      return #err("Only admin can update event");
    };
    switch (Trie.find(_events, Helper.keyT(id), Text.equal)) {
      case (?e) {
        _events := Trie.put(_events, Helper.keyT(id), Text.equal, event).0;
        return #ok(event);
      };
      case _ {
        return #err("event not exist");
      };
    };
  };
  public query func readAllEvents(offset : Nat, limit : Nat) : async ([Types.Event]) {
    var bufferEvents : Buffer.Buffer<Types.Event> = Buffer.Buffer<Types.Event>(0);
    for((ind, event) in Trie.iter(_events)) {
        bufferEvents.add(event);
    };
    var start : Nat = offset;
    var end : Nat = offset + limit;
    let size : Nat = Trie.size(_events);
    if(size < end){
        end := size;
    };
    let events_arr : [Types.Event] = Buffer.toArray(bufferEvents);
    bufferEvents := Buffer.Buffer<Types.Event>(0);
    while(start < end) {
        bufferEvents.add(events_arr[start]);
        start := start + 1;
    };
    return Buffer.toArray(bufferEvents);
  };
  public query func readEvent(id : Types.eventId) : async (Result.Result<Types.Event, Text>) { 
    switch (Trie.find(_events, Helper.keyT(id), Text.equal)) {
      case (?e) {
        return #ok(e);
      };
      case _ {
        #err("event not found");
      };
    };
  };

  // CRUD Users
  public shared ({ caller }) func createUser(user : Types.User) : async (Result.Result<Types.User, Text>) {
    if (Helper.isAdmin(caller) == false) {
      return #err("Only admin can create user");
    };
    _users := Trie.put(_users, Helper.keyT(Principal.toText(caller)), Text.equal, user).0;
    return #ok(user);
  };
  public shared ({ caller }) func updateUser(user : Types.User) : async (Result.Result<Types.User, Text>) {
    if (Helper.isAdmin(caller) == false) {
      return #err("Only admin can update user");
    };
    switch (Trie.find(_users, Helper.keyT(Principal.toText(caller)), Text.equal)) {
      case (?u) {
        _users := Trie.put(_users, Helper.keyT(Principal.toText(caller)), Text.equal, user).0;
        return #ok(user);
      };
      case _ {
        return #err("user not found");
      };
    };
  };
  public query func readUser(id : Types.userId) : async (Result.Result<Types.User, Text>) {
    switch (Trie.find(_users, Helper.keyT(id), Text.equal)) {
      case (?u) {
        return #ok(u);
      };
      case _ {
        return #err("user not found");
      };
    };
  };

  //read all tags
  public query func readAllTagNews(tagId : Types.tagId, offset : Nat, limit : Nat) : async ([Types.News]) {
    var b : Buffer.Buffer<Types.News> = Buffer.Buffer<Types.News>(0);
    switch (Trie.find(_tags, Helper.keyT(tagId), Text.equal)) {
      case (?n) {
        var all_news_ids : [Types.newsId] = n.news;
        for (i in all_news_ids.vals()) {
          switch (Trie.find(_news, Helper.keyT(i), Text.equal)) {
            case (?news) {
              b.add(news);
            };
            case _ {};
          };
        };
      };
      case _ {
        return [];
      };
    };
    var start : Nat = offset;
    var end : Nat = offset + limit;
    let size : Nat = b.size();
    if (size < end) {
      end := size;
    };
    let news_arr : [Types.News] = Buffer.toArray(b);
    b := Buffer.Buffer<Types.News>(0);
    while (start < end) {
      b.add(news_arr[start]);
      start := start + 1;
    };
    return Buffer.toArray(b);
  };

  public query func readAllTags() : async ([Types.tagId]) {
    var b : Buffer.Buffer<Types.tagId> = Buffer.Buffer<Types.tagId>(0);
    for ((i, v) in Trie.iter(_tags)) {
      b.add(i);
    };
    return Buffer.toArray(b);
  };

  public shared ({ caller }) func createSubEmail(_email : Text) : async () {
    _subEmails.add(_email);
  };

  // HTTP request handler
  public query func http_request(req : Types.HttpRequest) : async (Types.HttpResponse) {
    let path = Iter.toArray(Text.tokens(req.url, #text("/")));
    var headers : [(Text, Text)] = req.headers;
    switch (req.method) {
      case ("GET") {
        if (Text.contains(req.url, #text "/subscribed-emails/")) {
          for ((i, v) in headers.vals()) {
            if (i == "password" and v == Constants.auth_header) {
              var emails : Text = "";
              for (i in _subEmails.vals()) {
                emails := emails #i # ", ";
              };
              return {
                body = Text.encodeUtf8(emails);
                headers = [("content-type", "text/html")];
                status_code = 200;
              };
            };
          };
          return {
            body = Text.encodeUtf8("caller not authorized!");
            headers = [];
            status_code = 404;
          };
        } else {
          return {
            body = Text.encodeUtf8("Yay KompeteKeeda!");
            headers = [];
            status_code = 200;
          };
        };
      };
      case _ {
        return {
          body = Text.encodeUtf8("invalid");
          headers = [];
          status_code = 404;
        };
      };
    };
  };
};
