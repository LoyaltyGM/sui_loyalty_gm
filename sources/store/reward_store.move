/**
    Reward Store Module.
    This module is responsible for managing the rewards for the loyalty system.
    Its functions are only accessible by the friend modules.
*/
module loyalty_gm::reward_store {
    use std::string::{Self, String};
    use std::vector;
    use std::option::{Self, Option};

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::dynamic_object_field as dof;
    use sui::event::emit;
    use sui::object::{Self, UID, ID};
    use sui::pay;
    use sui::sui::SUI;
    use sui::table;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::url::{Self, Url};

    friend loyalty_gm::loyalty_system;
    friend loyalty_gm::loyalty_token;

    // ======== Constants =========

    const INITIAL_XP: u64 = 0;
    const BASIC_REWARD_XP: u64 = 5;
    const REWARD_RECIPIENTS_KEY: vector<u8> = b"reward_recipients";

    // Reward Types

    const COIN_REWARD_TYPE: u64 = 0;
    const TOKEN_REWARD_TYPE: u64 = 1;
    const SOULBOND_REWARD_TYPE: u64 = 2;

    const TOKEN_REWARD_NAME: vector<u8> = b"Token Reward";
    const SOULBOND_REWARD_NAME: vector<u8> = b"Soulbond Reward";

    // ======== Errors =========

    const EInvalidSupply: u64 = 0;
    const ERewardPoolExceeded: u64 = 1;
    const EAlreadyClaimed: u64 = 2;
    const EInvalidRewardType: u64 = 3;

    // ======== Structs =========

    /**
        Reward struct.
        This struct represents a reward for the loyalty system.
    */
    struct Reward has key, store {
        id: UID,
        type: u64,
        level: u64,
        description: String,
        reward_supply: u64,

        // Coin Reward fields
        /// Balance can not be used as a Option<Balance<SUI>>, so we use a balance with value 0 as a None
        reward_pool: Balance<SUI>,
        /// Reward per user is an Option, so we can use it as a None if the reward is a NFT
        reward_per_user: Option<u64>,

        // NFT Reward fields
        url: Option<Url>,
        reward_count: Option<u64>

        /*
           --dynamic fields--
           /// Table of reward recipients.
           reward_recipients: table<address, bool>
        */
    }

    /**
        Reward Token struct.
        This struct represents a reward token sent to the user after completing a task.
        This token can be sent by the user to another user
    */
    struct RewardToken has key, store {
        id: UID,
        level: u64,
        loyalty_system: ID,
        reward_id: ID,
        name: String,
        description: String,
        claimer: address,
        url: Url,
    }

    /**
        Soulbond Reward struct.
        This struct represents a reward token sent to the user after completing a task.
        This token can NOT be sent by the user to another user
    */
    struct SoulbondReward has key {
        id: UID,
        level: u64,
        loyalty_system: ID,
        reward_id: ID,
        name: String,
        description: String,
        url: Url,
    }

    // ======== Events =========

    struct CreateRewardEvent has copy, drop {
        /// Object ID of the Reward
        reward_id: ID,
        /// Lvl of the Reward
        lvl: u64,
        /// Type of the Reward
        type: u64,
        /// Description of the Reward
        description: string::String,
    }


    // ======== Public functions =========

    /**
        Creates a new Reward Store.
        It represents a map of rewards, where the key is the level of the reward.
    */
    public(friend) fun empty(): VecMap<u64, Reward> {
        vec_map::empty<u64, Reward>()
    }

    /**
        Adds a new reward to the store.
        It creates a new Reward struct and adds it to the store.
        It also creates a new table for the current reward recipients.
    */
    public(friend) fun add_coin_reward(
        store: &mut VecMap<u64, Reward>,
        level: u64,
        description: vector<u8>,
        coins: vector<Coin<SUI>>,
        reward_pool: u64,
        reward_supply: u64,
        ctx: &mut TxContext
    ) {
        let coin = vector::pop_back(&mut coins);
        pay::join_vec(&mut coin, coins);
        let received_coin = coin::split(&mut coin, reward_pool, ctx);

        if (coin::value(&coin) == 0) {
            coin::destroy_zero(coin);
        } else {
            pay::keep(coin, ctx);
        };

        let balance = coin::into_balance(received_coin);
        let balance_val = balance::value(&balance);
        assert!(balance_val % reward_supply == 0, EInvalidSupply);

        let reward = Reward {
            id: object::new(ctx),
            type: COIN_REWARD_TYPE,
            level,
            description: string::utf8(description),
            reward_pool: balance,
            reward_supply,
            reward_per_user: option::some(balance_val / reward_supply),
            url: option::none(),
            reward_count: option::none(),
        };

        emit_create_reward_event(&reward);

        dof::add(&mut reward.id, REWARD_RECIPIENTS_KEY, table::new<address, bool>(ctx));
        vec_map::insert(store, level, reward);
    }

    public(friend) fun add_token_reward(
        store: &mut VecMap<u64, Reward>,
        level: u64,
        url: vector<u8>,
        description: vector<u8>,
        reward_supply: u64,
        ctx: &mut TxContext
    ) {
        add_nft_reward(
            store,
            TOKEN_REWARD_TYPE,
            level,
            url,
            description,
            reward_supply,
            ctx
        );
    }

    public(friend) fun add_soulbond_reward(
        store: &mut VecMap<u64, Reward>,
        level: u64,
        url: vector<u8>,
        description: vector<u8>,
        reward_supply: u64,
        ctx: &mut TxContext
    ) {
        add_nft_reward(
            store,
            SOULBOND_REWARD_TYPE,
            level,
            url,
            description,
            reward_supply,
            ctx
        );
    }

    /**
        Removes a reward from the store.
        It removes the reward from the store and transfers the reward pool to the sender.
    */
    public(friend) fun remove_reward(store: &mut VecMap<u64, Reward>, level: u64, ctx: &mut TxContext) {
        let (_, reward) = vec_map::remove(store, &level);

        let sui_amt = balance::value(&reward.reward_pool);
        transfer::transfer(
            coin::take(&mut reward.reward_pool, sui_amt, ctx),
            tx_context::sender(ctx)
        );

        delete_reward(reward);
    }

    /**
        Claims a reward.
        It checks if the reward has already been claimed by the sender.
        It checks if the reward pool has enough funds.
        It transfers the reward to the sender and sets the reward as claimed.
    */
    public(friend) fun claim_reward(
        reward: &mut Reward,
        ctx: &mut TxContext
    ) {
        check_claimed(reward, ctx);

        if (reward.type == COIN_REWARD_TYPE && option::is_some(&reward.reward_per_user)) {
            let pool_amt = balance::value(&reward.reward_pool);
            let reward_per_user = option::borrow(&reward.reward_per_user);
            assert!(pool_amt >= *reward_per_user, ERewardPoolExceeded);

            transfer::transfer(
                coin::take(&mut reward.reward_pool, *reward_per_user, ctx),
                tx_context::sender(ctx)
            );
        };

        set_reward_claimed(reward, ctx);
    }

    // ======== Private functions =========

    fun add_nft_reward(
        store: &mut VecMap<u64, Reward>,
        type: u64,
        level: u64,
        url: vector<u8>,
        description: vector<u8>,
        reward_supply: u64,
        ctx: &mut TxContext
    ) {
        assert!(type == TOKEN_REWARD_TYPE || type == SOULBOND_REWARD_TYPE, EInvalidRewardType);

        let reward = Reward {
            id: object::new(ctx),
            type,
            level,
            description: string::utf8(description),
            reward_pool: balance::zero(),
            reward_supply,
            reward_per_user: option::none(),
            url: option::some(url::new_unsafe_from_bytes(url)),
            reward_count: option::some(0),
        };

        emit_create_reward_event(&reward);

        dof::add(&mut reward.id, REWARD_RECIPIENTS_KEY, table::new<address, bool>(ctx));
        vec_map::insert(store, level, reward);
    }

    fun emit_create_reward_event(reward: &Reward) {
        emit(CreateRewardEvent {
            reward_id: object::id(reward),
            type: reward.type,
            lvl: reward.level,
            description: reward.description,
        });
    }

    /**
        Sets the reward as claimed by the sender.
        It adds the sender to the reward recipients table.
    */
    fun set_reward_claimed(reward: &mut Reward, ctx: &mut TxContext) {
        table::add<address, bool>(
            dof::borrow_mut(&mut reward.id, REWARD_RECIPIENTS_KEY),
            tx_context::sender(ctx),
            true
        );
    }

    /**
        Checks if the reward has already been claimed by the sender.
    */
    fun check_claimed(reward: &Reward, ctx: &mut TxContext) {
        assert!(
            !table::contains<address, bool>(
                dof::borrow(&reward.id, REWARD_RECIPIENTS_KEY),
                tx_context::sender(ctx)
            ),
            EAlreadyClaimed
        );
    }

    /**
        Deletes a reward.
        It destroys the reward pool and deletes the reward.
    */
    fun delete_reward(reward: Reward) {
        let Reward {
            id,
            type: _,
            description: _,
            level: _,
            reward_pool,
            reward_supply: _,
            reward_per_user: _,
            url: _,
            reward_count: _,
        } = reward;
        balance::destroy_zero(reward_pool);
        object::delete(id);
    }
}