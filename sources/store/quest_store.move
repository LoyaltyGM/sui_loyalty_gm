/**
    Quest Store module.
    This module is responsible for storing all the quests in the system.
    Its functions are only accessible by the friend modules.
*/
module loyalty_gm::quest_store {
    use std::option::{Self, Option};
    use std::string::{Self, String};
    use std::vector;

    use sui::event::emit;
    use sui::object::{Self, ID};
    use sui::tx_context::TxContext;
    use sui::vec_map::{Self, VecMap};

    friend loyalty_gm::loyalty_system;
    friend loyalty_gm::loyalty_token;

    // ======== Constants =========

    const INITIAL_XP: u64 = 0;
    const BASIC_REWARD_XP: u64 = 5;
    const MAX_QUESTS: u64 = 100;

    // ======== Error codes =========

    const EMaxQuestsReached: u64 = 0;
    const EQuestCompletedSupplyReached: u64 = 1;

    // ======== Structs =========

    /**
        Quest struct.
        This struct represents a quest that the user can complete.
        The quest is represented by a function that needs to be executed.
        Quest can be completed only once by the user.
    */
    struct Quest has store, drop {
        id: ID,
        /// The name of the quest
        name: String,
        /// The description of the quest
        description: String,
        /// The level required to start the quest
        lvl: Option<u64>,
        /// The amount of XP that the user will receive upon completing the quest
        reward_exp: u64,
        /// The counter of the number of times the quest has been started
        started_count: u64,
        /// The counter of the number of times the quest has been completed
        completed_count: u64,
        /// The maximum number of times the quest can be completed
        completed_supply: Option<u64>,
        /// The ID of the package that contains the function that needs to be executed
        package_id: ID,
        /// The name of the module that contains the function that needs to be executed
        module_name: String,
        /// The name of the function that needs to be executed
        function_name: String,
        /// The arguments that need to be passed to the function
        arguments: vector<String>,
    }

    // ======== Events =========

    struct CreateQuestEvent has copy, drop {
        /// Object ID of the Quest
        quest_id: ID,
        /// Name of the Quest
        name: string::String,
    }

    // ======== Public functions =========

    // ======== Friend functions =========

    /**
        Creates a new empty quest store.
        Store represents a map of quest IDs to quests.
    */
    public(friend) fun empty(): VecMap<ID, Quest> {
        vec_map::empty<ID, Quest>()
    }

    /**
        Creates a new quest and adds it to the store.
        The quest is represented by a function that needs to be executed.
        The function is identified by the package ID, module name and function name.
        The arguments are the arguments that need to be passed to the function.
    */
    public(friend) fun add_quest(
        store: &mut VecMap<ID, Quest>,
        lvl: u64,
        name: vector<u8>,
        description: vector<u8>,
        reward_exp: u64,
        completed_supply: Option<u64>,
        package_id: ID,
        module_name: vector<u8>,
        function_name: vector<u8>,
        arguments: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        assert!(vec_map::size(store) <= MAX_QUESTS, EMaxQuestsReached);

        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);
        object::delete(uid);

        let quest = Quest {
            id,
            name: string::utf8(name),
            description: string::utf8(description),
            lvl: if (lvl == 0)  option::none<u64>() else option::some(lvl),
            reward_exp,
            completed_supply,
            started_count: 0,
            completed_count: 0,
            package_id,
            module_name: string::utf8(module_name),
            function_name: string::utf8(function_name),
            arguments: to_string_vec(arguments),
        };

        emit(CreateQuestEvent {
            quest_id: id,
            name: quest.name,
        });

        vec_map::insert(store, id, quest);
    }

    /**
        Removes a quest from the store.
    */
    public(friend) fun remove_quest(store: &mut VecMap<ID, Quest>, quest_id: &ID) {
        vec_map::remove(store, quest_id);
    }

    public(friend) fun increment_quest_started_count(store: &mut VecMap<ID, Quest>, quest_id: &ID) {
        let quest = get_mut_quest(store, quest_id);
        quest.started_count = quest.started_count + 1;
    }

    /**
        Increments the number of times the quest has been completed.
    */
    public(friend) fun increment_quest_completed_count(store: &mut VecMap<ID, Quest>, quest_id: &ID) {
        let quest = get_mut_quest(store, quest_id);
        let new_count = quest.completed_count + 1;
        assert!(
            option::is_none(&quest.completed_supply) || new_count <= *option::borrow(&quest.completed_supply),
            EQuestCompletedSupplyReached
        );
        quest.completed_count = new_count;
    }

    /**
        Returns the quest for the given quest ID.
    */
    public fun get_quest(store: &VecMap<ID, Quest>, quest_id: &ID): &Quest {
        vec_map::get(store, quest_id)
    }

    /**
        Returns the quest ID for the given quest name.
    */
    public fun get_quest_lvl(store: &VecMap<ID, Quest>, quest_id: &ID): u64 {
        let quest = vec_map::get(store, quest_id);
        if (option::is_some(&quest.lvl)) *option::borrow(&quest.lvl)
        else 0
    }

    /**
        Returns the quest reward amount for the given quest ID.
    */
    public fun get_quest_reward(store: &VecMap<ID, Quest>, quest_id: &ID): u64 {
        get_quest(store, quest_id).reward_exp
    }

    // ======= Private and Utility functions =======

    /**
        Returns the mutable quest for the given quest ID.
    */
    public fun get_mut_quest(store: &mut VecMap<ID, Quest>, quest_id: &ID): &mut Quest {
        vec_map::get_mut(store, quest_id)
    }

    /// Converts a vector of vectors of u8 to a vector of strings
    fun to_string_vec(args: vector<vector<u8>>): vector<String> {
        let string_args = vector::empty<String>();
        vector::reverse(&mut args);

        while (!vector::is_empty(&args)) {
            vector::push_back(&mut string_args, string::utf8(vector::pop_back(&mut args)))
        };

        string_args
    }
}