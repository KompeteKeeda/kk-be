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
import Text "mo:base/Text";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Trie2D "mo:base/Trie";
import Result "mo:base/Result";

import Types "../main.types";
import Helper "Helper";
import Constants "Constants";

module {
    public func isTagAvailable_(_tags : Trie.Trie<Types.tagId, [Types.newsId]>, tag : Types.tagId) : Bool {
        switch (Trie.find(_tags, Helper.keyT(tag), Text.equal)) {
            case (?is) {
                return true;
            };
            case _ {
                return false;
            };
        };
    };

    public func addNewsIdToTags_(_tags : Trie.Trie<Types.tagId, [Types.newsId]>, tagIds : [Types.tagId], newsId : Types.newsId) : (Trie.Trie<Types.tagId, [Types.newsId]>) {
        var tags = _tags;
        for (tagId in tagIds.vals()) {
            switch (Trie.find(_tags, Helper.keyT(tagId), Text.equal)) {
                case (?t) {
                    var b : Buffer.Buffer<Types.newsId> = Buffer.fromArray(t);
                    b.add(newsId);
                    tags := Trie.put(tags, Helper.keyT(tagId), Text.equal, Buffer.toArray(b)).0;
                };
                case _ {
                    return _tags;
                };
            };
        };
        return tags;
    };
};
