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
import Constants "Constants";
import Array "mo:base/Array";


module {
    public func key(x : Nat32) : Trie.Key<Nat32> {
        return { hash = x; key = x };
    };

    public func keyT(x : Text) : Trie.Key<Text> {
        return { hash = Text.hash(x); key = x };
    };

    public func textToNat(txt : Text) : Nat {
        assert (txt.size() > 0);
        let chars = txt.chars();

        var num : Nat = 0;
        for (v in chars) {
            let charToNum = Nat32.toNat(Char.toNat32(v) -48);
            assert (charToNum >= 0 and charToNum <= 9);
            num := num * 10 + charToNum;
        };

        return num;
    };

    public func isAdmin(principalId: Principal): Bool {
        let adminId = Array.find<Text>(Constants.admins, func adminId = (adminId == Principal.toText(principalId)));
        if (adminId != null) {
            return true;
        };
        return false;
    }
}