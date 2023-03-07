/**
    Reward Store Module.
    This module is responsible for managing the rewards for the loyalty system.
    Its functions are only accessible by the friend modules.
*/
module loyalty_gm::reward_store {
    use std::string::{Self, String};
    use std::vector;

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

    friend loyalty_gm::loyalty_system;
    friend loyalty_gm::loyalty_token;

    // ======== Constants =========

    const INITIAL_XP: u64 = 0;
    const BASIC_REWARD_XP: u64 = 5;
    const REWARD_RECIPIENTS_KEY: vector<u8> = b"reward_recipients";

    // Reward Types

    const COIN_REWARD: u64 = 0;
    const TOKEN_REWARD: u64 = 1;
    const SOULBOND_REWARD: u64 = 2;

    // ======== Errors =========

    const EInvalidSupply: u64 = 0;
    const ERewardPoolExceeded: u64 = 1;
    const EAlreadyClaimed: u64 = 2;

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
        reward_pool: Balance<SUI>,
        reward_supply: u64,
        reward_per_user: u64,

        /*
           --dynamic fields--
           /// Table of reward recipients.
           reward_recipients: table<address, bool>
        */
    }

    // ======== Events =========

    struct CreateRewardEvent has copy, drop {
        /// Object ID of the Reward
        reward_id: ID,
        /// Lvl of the Reward
        lvl: u64,
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
    public(friend) fun add_reward(
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
            type: COIN_REWARD,
            level,
            description: string::utf8(description),
            reward_pool: balance,
            reward_supply,
            reward_per_user: balance_val / reward_supply,
        };

        emit(CreateRewardEvent {
            reward_id: object::id(&reward),
            lvl: reward.level,
            description: reward.description,
        });

        dof::add(&mut reward.id, REWARD_RECIPIENTS_KEY, table::new<address, bool>(ctx));
        vec_map::insert(store, level, reward);
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

        let pool_amt = balance::value(&reward.reward_pool);
        assert!(pool_amt >= reward.reward_per_user, ERewardPoolExceeded);

        set_reward_claimed(reward, ctx);

        transfer::transfer(
            coin::take(&mut reward.reward_pool, reward.reward_per_user, ctx),
            tx_context::sender(ctx)
        );
    }

    // ======== Private functions =========

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
        } = reward;
        balance::destroy_zero(reward_pool);
        object::delete(id);
    }
}