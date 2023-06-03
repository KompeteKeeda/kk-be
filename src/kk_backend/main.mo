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
  private stable var _news : Trie.Trie<Types.newsId, Types.News> = Trie.empty();

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

  public query func http_request(req : Types.HttpRequest) : async (Types.HttpResponse) {
    let path = Iter.toArray(Text.tokens(req.url, #text("/")));
    switch (req.method) {
      case ("GET") {
        if (Text.contains(req.url, #text "/news/")) {
          switch (Trie.find(_news, Helper.keyT(path[1]), Text.equal)) {
            case (?news) {
              return {
                body = Text.encodeUtf8("found");
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
};
