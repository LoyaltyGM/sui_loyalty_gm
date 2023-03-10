#[test_only]
module loyalty_gm::test_utils {
    use std::vector;

    use sui::coin::{Self, Coin};
    use sui::object;
    use sui::sui::SUI;
    use sui::test_scenario::{Self, Scenario};
    use sui::transfer;

    use loyalty_gm::loyalty_system::{Self, LoyaltySystem, AdminCap, VerifierCap};
    use loyalty_gm::loyalty_token::{Self, LoyaltyToken};
    use loyalty_gm::system_store::{Self, SystemStore, SYSTEM_STORE};

    // ======== Constants =========

    const ADMIN: address = @0xFACE;
    const VERIFIER: address = @0xCACA;
    const USER_1: address = @0xAA;
    const USER_2: address = @0xBB;

    const LS_NAME: vector<u8> = b"Loyalty System Name";
    const LS_DESCRIPTION: vector<u8> = b"Loyalty System Description";
    const LS_URL: vector<u8> = b"https://www.loyalty.com";
    const LS_MAX_SUPPLY: u64 = 100;
    const LS_MAX_LVL: u64 = 10;

    //quest
    const QUEST_REWARD: u64 = 100;

    //reward
    const REWARD_LVL: u64 = 1;
    const REWARD_POOL_AMT: u64 = 1000;
    const REWARD_SUPPLY: u64 = 100;

    // ======== Utility functions =========

    // ======== Utility functions: Constants

    public fun get_ADMIN(): address {
        ADMIN
    }

    public fun get_VERIFIER(): address {
        VERIFIER
    }

    public fun get_USER_1(): address {
        USER_1
    }

    public fun get_USER_2(): address {
        USER_2
    }

    public fun get_LS_NAME(): vector<u8> {
        LS_NAME
    }

    public fun get_LS_DESCRIPTION(): vector<u8> {
        LS_DESCRIPTION
    }

    public fun get_LS_URL(): vector<u8> {
        LS_URL
    }

    public fun get_LS_MAX_SUPPLY(): u64 {
        LS_MAX_SUPPLY
    }

    public fun get_LS_MAX_LVL(): u64 {
        LS_MAX_LVL
    }

    public fun get_QUEST_REWARD(): u64 {
        QUEST_REWARD
    }

    public fun get_REWARD_LVL(): u64 {
        REWARD_LVL
    }

    public fun get_REWARD_POOL_AMT(): u64 {
        REWARD_POOL_AMT
    }

    public fun get_REWARD_SUPPLY(): u64 {
        REWARD_SUPPLY
    }

    // ======== Utility functions: System

    public fun mint_sui(scenario: &mut Scenario) {
        let coin = coin::mint_for_testing<SUI>(REWARD_POOL_AMT, test_scenario::ctx(scenario));
        transfer::transfer(coin, ADMIN);
    }

    public fun create_system_store(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            system_store::init_test(test_scenario::ctx(scenario));
        };
    }

    public fun create_loyalty_system(scenario: &mut Scenario, creator: address) {
        test_scenario::next_tx(scenario, creator);
        {
            let system_store = test_scenario::take_shared<SystemStore<SYSTEM_STORE>>(scenario);

            loyalty_system::create_loyalty_system(
                LS_NAME,
                LS_DESCRIPTION,
                LS_URL,
                LS_MAX_SUPPLY,
                LS_MAX_LVL,
                &mut system_store,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(system_store);
        };
    }

    // ======== Utility functions: Quests

    public fun add_quest(scenario: &mut Scenario, quest_lvl: u64, completed_supply: u64) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);

            let args = vector::empty();
            vector::push_back(&mut args, b"arg1");
            vector::push_back(&mut args, b"arg2");

            loyalty_system::add_quest(
                &admin_cap,
                &mut ls,
                quest_lvl,
                b"name",
                b"description",
                QUEST_REWARD,
                completed_supply,
                object::id(&admin_cap),
                b"module",
                b"function_name",
                args,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    public fun remove_quest(scenario: &mut Scenario, quest_id: object::ID) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);

            loyalty_system::remove_quest(
                &admin_cap,
                &mut ls,
                quest_id,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    // ======== Utility functions: Rewards

    public fun add_coin_reward(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);

            let coin1 = test_scenario::take_from_sender<Coin<SUI>>(scenario);
            let coins = vector::empty();
            vector::push_back(&mut coins, coin1);

            loyalty_system::add_coin_reward(
                &admin_cap,
                &mut ls,
                REWARD_LVL,
                b"reward description",
                coins,
                REWARD_POOL_AMT,
                REWARD_SUPPLY,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    public fun add_nft_reward(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);

            loyalty_system::add_nft_reward(
                &admin_cap,
                &mut ls,
                REWARD_LVL,
                b"https://example.com",
                b"nft reward",
                REWARD_SUPPLY,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    public fun add_soulbond_reward(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);

            loyalty_system::add_soulbond_reward(
                &admin_cap,
                &mut ls,
                REWARD_LVL,
                b"https://example.com",
                b"soulbond reward",
                REWARD_SUPPLY,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    public fun add_fail_pool_reward(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);
            let coin1 = test_scenario::take_from_sender<Coin<SUI>>(scenario);
            let coins = vector::empty();
            vector::push_back(&mut coins, coin1);

            loyalty_system::add_coin_reward(
                &admin_cap,
                &mut ls,
                REWARD_LVL,
                b"reward description",
                coins,
                REWARD_POOL_AMT,
                99,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    public fun add_fail_lvl_reward(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);
            let coin1 = test_scenario::take_from_sender<Coin<SUI>>(scenario);
            let coins = vector::empty();
            vector::push_back(&mut coins, coin1);

            loyalty_system::add_coin_reward(
                &admin_cap,
                &mut ls,
                LS_MAX_LVL + 1,
                b"reward description",
                coins,
                REWARD_POOL_AMT,
                REWARD_SUPPLY,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    public fun add_single_reward(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);
            let coin1 = test_scenario::take_from_sender<Coin<SUI>>(scenario);
            let coins = vector::empty();
            vector::push_back(&mut coins, coin1);

            loyalty_system::add_coin_reward(
                &admin_cap,
                &mut ls,
                REWARD_LVL,
                b"reward description",
                coins,
                REWARD_POOL_AMT,
                1,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    public fun remove_reward(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, ADMIN);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);

            loyalty_system::remove_reward(
                &admin_cap,
                &mut ls,
                REWARD_LVL,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };
    }

    public fun claim_reward(scenario: &mut Scenario, user: address, reward_lvl: u64) {
        test_scenario::next_tx(scenario, user);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let token = test_scenario::take_from_sender<LoyaltyToken>(scenario);

            loyalty_token::claim_reward(
                &mut ls,
                &token,
                reward_lvl,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, token);
        };
    }

    // ======== Utility functions: Verifier

    public fun get_verifier(scenario: &mut Scenario) {
        test_scenario::next_tx(scenario, VERIFIER);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            loyalty_system::get_verifier(test_scenario::ctx(scenario));

            test_scenario::return_shared(ls);
        };
    }

    public fun finish_quest(scenario: &mut Scenario, user: address, quest_id: object::ID) {
        test_scenario::next_tx(scenario, VERIFIER);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let verify_cap = test_scenario::take_from_sender<VerifierCap>(scenario);

            loyalty_system::finish_quest(
                &verify_cap,
                &mut ls,
                quest_id,
                user
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, verify_cap);
        };
    }

    // ======== Utility functions: User

    public fun mint_token(scenario: &mut Scenario, user: address) {
        test_scenario::next_tx(scenario, user);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            loyalty_token::mint(
                &mut ls,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_shared(ls);
        };
    }

    public fun claim_xp(scenario: &mut Scenario, user: address) {
        test_scenario::next_tx(scenario, user);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let token = test_scenario::take_from_sender<LoyaltyToken>(scenario);

            loyalty_token::claim_xp(&mut ls, &mut token, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(ls);
        };
    }

    public fun start_quest(scenario: &mut Scenario, user: address, quest_id: object::ID) {
        test_scenario::next_tx(scenario, user);
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let token = test_scenario::take_from_sender<LoyaltyToken>(scenario);


            loyalty_token::start_quest(
                &mut ls,
                &mut token,
                quest_id,
                test_scenario::ctx(scenario)
            );

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(ls);
        };
    }
}