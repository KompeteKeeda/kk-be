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

actor Main {
  // containers
  private stable var _news : Trie.Trie<Types.newsId, Types.News> = Trie.empty();
  private stable var _banners : Trie.Trie<Types.bannerId, Types.Banner> = Trie.empty();
  private stable var _users : Trie.Trie<Types.userId, Types.User> = Trie.empty();
  private stable var _events : Trie.Trie<Types.eventId, Types.Event> = Trie.empty();
  private stable var _admins : [Types.userId] = [];
  private stable var _tags : Trie.Trie<Types.tagId, Types.Tag> = Trie.empty();

  // CRUD News
  public shared({caller}) func createNews(id : Types.newsId, news : Types.News) : async (Types.News) {
    _news := Trie.put(_news, Helper.keyT(id), Text.equal, news).0;
    return news;
  };
  public shared({caller}) func updateNews(id : Types.newsId, news : Types.News) : async (Result.Result<Types.News, Text>) {
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

  // CRUD Banners
  public  shared ({caller}) func createBanner(id : Types.bannerId, banner : Types.Banner) : async (Types.Banner) {
    _banners := Trie.put(_banners, Helper.keyT(id), Text.equal, banner).0;
    return banner;
  };
  public shared ({caller}) func updateBanner(id : Types.bannerId, banner : Types.Banner) : async (Result.Result<Types.Banner, Text>) {
    switch (Trie.find(_news, Helper.keyT(id), Text.equal)) {
      case (?n) {
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

  // CRUD Users
  public shared ({caller}) func createUser(user : Types.User) : async (Types.User) {
    _users := Trie.put(_users, Helper.keyT(Principal.toText(caller)), Text.equal, user).0;
    return user;
  };
  public shared ({caller}) func updateUser(user : Types.User) : async (Result.Result<Types.User, Text>) {
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

  // HTTP request handler
  public query func http_request(req : Types.HttpRequest) : async (Types.HttpResponse) {
    let path = Iter.toArray(Text.tokens(req.url, #text("/")));
    switch (req.method) {
      case ("GET") {
        if (Text.contains(req.url, #text "/news/")) {
          switch (Trie.find(_news, Helper.keyT(path[1]), Text.equal)) {
            case (?news) {
              return {
                body = Text.encodeUtf8("news exist");
                headers = [("content-type", "text/html")];
                status_code = 200;
              };
            };
            case _ {
              return {
                body = Text.encodeUtf8("news not found");
                headers = [("content-type", "text/html")];
                status_code = 404;
              };
            };
          };
        } else {
          return {
            body = Text.encodeUtf8("need to handle other routed here");
            headers = [];
            status_code = 404;
          };
        } //From here we will define different endpoints and handle them accord under else-conditions
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

  // Admin eps
  
};
