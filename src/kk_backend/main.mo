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

actor {
  // containers
  private stable var _news : Trie.Trie<Types.newsId, Types.News> = Trie.empty();
  private stable var _banners : Trie.Trie<Types.bannerId, Types.Banner> = Trie.empty();
  private stable var _events : Trie.Trie<Types.eventId, Types.Event> = Trie.empty();
  private stable var _tags : Trie.Trie<Types.tagId, Types.Tag> = Trie.empty();

  //read all news
  public query func readAllNews() : async ([Types.News]) {
    let buffer = Buffer.Buffer<Types.News>(0);
    for ((x, y) in Trie.iter(_news)) {
      buffer.add(y);
    };
    return Buffer.toArray(buffer);
  };

  //read all banners
  public query func readAllBanners() : async ([Types.Banner]) {
    let buffer = Buffer.Buffer<Types.Banner>(0);
    for ((x, y) in Trie.iter(_banners)) {
      buffer.add(y);
    };
    return Buffer.toArray(buffer);
  };

  //read all events
  public query func readAllEvents() : async ([Types.Event]) {
    let buffer = Buffer.Buffer<Types.Event>(0);
    for ((x, y) in Trie.iter(_events)) {
      buffer.add(y);
    };
    return Buffer.toArray(buffer);
  };

  //read all tags
  public query func readAllTags() : async ([Types.Tag]) {
    let buffer = Buffer.Buffer<Types.Tag>(0);
    for ((x, y) in Trie.iter(_tags)) {
      buffer.add(y);
    };
    return Buffer.toArray(buffer);
  };
};
