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

module {
    public type userId = Text;
    public type eventId = Text;
    public type newsId = Text;
    public type tagId = Text;
    public type bannerId = Text;

    public type Tag = Text;
    public type Admins = [Text];

    public type User = {
        name : Text;
        userName : Text;
        email : Text;
        verified : Bool;
        contact : Text;
    };

    public type Event = {
        title : Text;
        description : Text;
        host : Text;
        venue : Text;
        prizePool : Int;
        timestamp : Int;
        coverUrl : Text;
        endDate : Int;
    };

    public type News = {
        title : Text;
        content : Text;
        tags : [tagId];
        coverUrl : Text;
        userId : userId;
        viewCount : Int;
        endDate : Int;
    };

    public type Banner = {
        url : Text;
        redirectUrl : Text;
        endDate : Text;
    };
}