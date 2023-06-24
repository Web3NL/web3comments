// Tokenized Comments Example
// For demonstration purposes only.
// Tokens are not transferable.
// Tokenomics model is not realistic.

import Array "mo:base/Array";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";

import Types "Types";
import Constants "Constants";
import Utils "Utils";
import Comments "Comments";

actor {
    type User = Types.User;

    type Comment = Types.Comment;
    type CommentHash = Types.CommentHash;

    type State = Types.State;

    type Users = Types.Users;
    type CommentStore = Types.CommentStore;
    type CommentHistory = Types.CommentHistory;
    type Treasury = Types.Treasury;

    type PostResult = Types.PostResult;
    type LikeResult = Types.LikeResult;

    type QueryComment = Types.QueryComment;
    type QueryUser = Types.QueryUser;

    // STABLE DATA STORES
    stable var stableUsers : [(Principal, User)] = [];
    stable var stableCommentStore : [(CommentHash, Comment)] = [];
    stable var stableCommentHistory : [CommentHash] = [];
    stable var stableTreasury : Treasury = Constants.TOTAL_SUPPLY;

    // INIT DATA STORES FROM STABLE VARS
    let state : State = object {

        // Users HashMap with initial capacity of 1000 users
        public let users : Users = HashMap.fromIter<Principal, User>(
            Array.vals(stableUsers),
            1000,
            Principal.equal,
            Principal.hash,
        );

        // Comments HashMap with initial capacity of 10,000 comments and custom hashing function
        public let commentStore : CommentStore = HashMap.fromIter<CommentHash, Comment>(
            Array.vals(stableCommentStore),
            10_000,
            Hash.equal,
            Utils.hash,
        );

        // Comment history List
        public var commentHistory : CommentHistory = List.fromArray<CommentHash>(stableCommentHistory);

        // Treasury
        public var treasury = stableTreasury;
    };

    // PUBLIC METHODS

    public shared (msg) func register() : async QueryUser {
        // Anonymous users cannot register
        if (Principal.isAnonymous(msg.caller)) throw Error.reject("Anonymous users cannot register");

        Comments.register(state.users, msg.caller);
    };

    public shared (msg) func postComment(comment : Text) : async PostResult {
        // Anonymous users cannot post comments
        if (Principal.isAnonymous(msg.caller)) return #err(#AnonNotAllowed);

        Comments.postComment(state, msg.caller, comment);
    };

    public shared (msg) func likeComment(hash : CommentHash) : async LikeResult {
        // Anonymous users cannot like comments
        if (Principal.isAnonymous(msg.caller)) return #err(#AnonNotAllowed);

        await* Comments.likeComment(state, hash, msg.caller);
    };

    public shared (msg) func deleteComment(hash : CommentHash) : async () {
        await* Comments.deleteComment(state, msg.caller, hash);
    };

    public query func latestComments() : async [QueryComment] {
        // Anonymous users can query comments
        Comments.latestComments(state);
    };

    public query func tokenTreasury() : async Nat {
        // Anon users can query treasury
        state.treasury;
    };

    // UPGRADING

    // Save state to stable arrays
    system func preupgrade() {
        stableUsers := Iter.toArray<(Principal, User)>(
            state.users.entries()
        );

        stableCommentStore := Iter.toArray<(CommentHash, Comment)>(
            state.commentStore.entries()
        );

        stableCommentHistory := List.toArray<CommentHash>(
            state.commentHistory
        );

        stableTreasury := state.treasury;
    };

    // Empty stable arrays to save memory
    system func postupgrade() {
        stableUsers := [];
        stableCommentStore := [];
        stableCommentHistory := [];
    };
};
