/**
    User Store Module.
    This module is responsible for storing user data.
    Its functions are only accessible by the friend modules.
*/
module loyalty_gm::user_store {
    use sui::object::ID;
    use sui::table::{Self, Table};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    friend loyalty_gm::loyalty_system;
    friend loyalty_gm::loyalty_token;

    // ======== Constants =========

    const INITIAL_XP: u64 = 0;

    // ======== Errors =========

    const EQuestAlreadyDone: u64 = 0;
    const EQuestNotStarted: u64 = 1;

    // ======== Structs =========

    /**
        User data.
    */
    struct User has store, drop {
        token_id: ID,
        /// Address of the user that data belongs to.
        owner: address,
        /// Current level of the user.
        level: u64,
        /// Quests that are currently active.
        active_quests: VecSet<ID>,
        /// Quests that are already done.
        done_quests: VecSet<ID>,
        total_xp: u64,
        /// XP that can be claimed by the user. It is reset to INITIAL_XP after claiming.
        claimable_xp: u64,
    }

    // ======== Public functions =========

    /**
        Create a new user store.
        It represents a table that maps user addresses to user data.
    */
    public(friend) fun new(ctx: &mut TxContext): Table<address, User> {
        table::new<address, User>(ctx)
    }

    /**
        Add a new user to the store.
    */
    public(friend) fun add_user(
        store: &mut Table<address, User>,
        token_id: &ID,
        ctx: &mut TxContext
    ) {
        let owner = tx_context::sender(ctx);
        let data = User {
            token_id: *token_id,
            level: 0,
            active_quests: vec_set::empty(),
            done_quests: vec_set::empty(),
            owner,
            total_xp: 0,
            claimable_xp: INITIAL_XP,
        };

        table::add(store, owner, data)
    }

    /**
        Update the user's XP.
    */
    public(friend) fun update_user_xp(
        store: &mut Table<address, User>,
        owner: address,
        reward_xp: u64
    ) {
        let user_data = table::borrow_mut<address, User>(store, owner);
        user_data.claimable_xp = user_data.claimable_xp + reward_xp;
    }

    /**
        Reset the user's XP to INITIAL_XP.
    */
    public(friend) fun reset_user_xp(store: &mut Table<address, User>, owner: address) {
        let user_data = table::borrow_mut<address, User>(store, owner);
        user_data.claimable_xp = INITIAL_XP;
    }

    /**
        Start a quest with the given ID for the user.
    */
    public(friend) fun start_quest(store: &mut Table<address, User>, quest_id: &ID, owner: address) {
        let user_data = table::borrow_mut<address, User>(store, owner);
        assert!(!vec_set::contains(&user_data.done_quests, quest_id), EQuestAlreadyDone);
        vec_set::insert(&mut user_data.active_quests, *quest_id)
    }

    /**
        Finish a quest with the given ID for the user.
    */
    public(friend) fun finish_quest(
        store: &mut Table<address, User>,
        quest_id: &ID,
        owner: address,
        reward_xp: u64
    ) {
        let user_data = table::borrow_mut<address, User>(store, owner);

        assert!(!vec_set::contains(&user_data.done_quests, quest_id), EQuestAlreadyDone);
        assert!(vec_set::contains(&user_data.active_quests, quest_id), EQuestNotStarted);

        vec_set::remove(&mut user_data.active_quests, quest_id);
        vec_set::insert(&mut user_data.done_quests, *quest_id);

        update_user_xp(store, owner, reward_xp)
    }

    public(friend) fun update_user_lvl(store: &mut Table<address, User>, owner: address, new_lvl: u64) {
        let user_data = table::borrow_mut<address, User>(store, owner);
        user_data.level = new_lvl;
    }

    public(friend) fun update_user_total_xp(store: &mut Table<address, User>, owner: address, new_total_xp: u64) {
        let user_data = table::borrow_mut<address, User>(store, owner);
        user_data.total_xp = new_total_xp;
    }

    /**
        Get the size of the user store.
    */
    public fun size(store: &Table<address, User>): u64 {
        table::length(store)
    }

    /**
        Get the user data for the given address.
    */
    public fun get_user(store: &Table<address, User>, owner: address): &User {
        table::borrow(store, owner)
    }

    /**
        Check if the user exists in the store.
    */
    public fun user_exists(table: &Table<address, User>, owner: address): bool {
        table::contains(table, owner)
    }

    /**
        Get the user's claimable XP.
    */
    public fun get_user_xp(table: &Table<address, User>, owner: address): u64 {
        let user_data = table::borrow<address, User>(table, owner);
        user_data.claimable_xp
    }
}