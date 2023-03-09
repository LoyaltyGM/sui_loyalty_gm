#[test_only]
module loyalty_gm::token_tests {
    use std::debug::print;

    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::test_scenario::{Self};

    use loyalty_gm::loyalty_system::{Self, LoyaltySystem};
    use loyalty_gm::loyalty_token::{Self, LoyaltyToken};
    use loyalty_gm::system_tests::{init_add_quest, init_create_loyalty_system, init_finish_quest};
    use loyalty_gm::test_utils::{Self, get_USER_1, get_QUEST_REWARD, get_REWARD_LVL, get_REWARD_POOL_AMT, get_REWARD_SUPPLY, get_USER_2};
    use loyalty_gm::user_store;

    // ======== Errors =========

    const Error: u64 = 1;

    // ======== Tests =========

    // ======== Mint

    #[test]
    fun mint() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_utils::mint_token(scenario, get_USER_1());

        test_scenario::next_tx(scenario, get_USER_1());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let token = test_scenario::take_from_sender<LoyaltyToken>(scenario);
            let user_store = loyalty_system::get_user_store(&ls);
            let user_info = user_store::get_user(user_store, get_USER_1());

            assert!(user_store::user_exists(user_store, get_USER_1()), Error);
            assert!(user_store::size(user_store) == 1, Error);

            print(&token);
            print(user_info);

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = sui::dynamic_field::EFieldAlreadyExists)]
    fun mint_twice() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_utils::mint_token(scenario, get_USER_1());
        test_utils::mint_token(scenario, get_USER_1());

        test_scenario::end(scenario_val);
    }

    // ======== Quests

    #[test]
    public fun start_quest() {
        let (scenario_val, quest_id) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;

        test_utils::mint_token(scenario, get_USER_1());
        test_utils::start_quest(scenario, get_USER_1(), quest_id);

        test_scenario::next_tx(scenario, get_USER_1());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let user = loyalty_system::get_user(&ls, get_USER_1());
            print(user);
            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::loyalty_token::EInvalidLvl)]
    public fun start_quest_invalid_lvl() {
        let (scenario_val, quest_id) = init_add_quest(1, 0);
        let scenario = &mut scenario_val;

        test_utils::mint_token(scenario, get_USER_1());
        test_utils::start_quest(scenario, get_USER_1(), quest_id);

        test_scenario::end(scenario_val);
    }

    // ======== Claim XP

    #[test]
    public fun claim_xp() {
        let scenario_val = init_finish_quest();
        let scenario = &mut scenario_val;

        test_utils::claim_xp(scenario, get_USER_1());

        test_scenario::next_tx(scenario, get_USER_1());
        {
            let token = test_scenario::take_from_sender<LoyaltyToken>(scenario);
            assert!(loyalty_token::get_xp(&token) == get_QUEST_REWARD(), Error);
            test_scenario::return_to_sender(scenario, token);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::loyalty_token::ENoClaimableXp)]
    fun claim_no_xp() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_utils::mint_token(scenario, get_USER_1());
        test_scenario::next_tx(scenario, get_USER_1());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let token = test_scenario::take_from_sender<LoyaltyToken>(scenario);

            loyalty_token::claim_xp(&mut ls, &mut token, test_scenario::ctx(scenario));

            test_scenario::return_to_sender(scenario, token);
            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }

    // ======== Claim Reward

    #[test]
    fun claim_reward() {
        let scenario_val = init_finish_quest();
        let scenario = &mut scenario_val;

        test_utils::claim_xp(scenario, get_USER_1());

        test_utils::add_reward(scenario);
        test_utils::claim_reward(scenario, get_USER_1(), get_REWARD_LVL());

        test_scenario::next_tx(scenario, get_USER_1());
        {
            let coin = test_scenario::take_from_sender<Coin<SUI>>(scenario);

            assert!(coin::value(&coin) == get_REWARD_POOL_AMT() / get_REWARD_SUPPLY(), Error);

            test_scenario::return_to_sender(scenario, coin);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::reward_store::EAlreadyClaimed)]
    fun claim_reward_twice() {
        let scenario_val = init_finish_quest();
        let scenario = &mut scenario_val;

        test_utils::claim_xp(scenario, get_USER_1());

        test_utils::add_reward(scenario);
        test_utils::claim_reward(scenario, get_USER_1(), get_REWARD_LVL());
        test_utils::claim_reward(scenario, get_USER_1(), get_REWARD_LVL());

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::reward_store::ERewardPoolExceeded)]
    fun claim_exceeded_reward() {
        let (scenario_val, quest_id) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;
        test_utils::get_verifier(scenario);


        test_utils::mint_token(scenario, get_USER_1());
        test_utils::start_quest(scenario, get_USER_1(), quest_id);
        test_utils::finish_quest(scenario, get_USER_1(), quest_id);
        test_utils::claim_xp(scenario, get_USER_1());

        test_utils::mint_token(scenario, get_USER_2());
        test_utils::start_quest(scenario, get_USER_2(), quest_id);
        test_utils::finish_quest(scenario, get_USER_2(), quest_id);
        test_utils::claim_xp(scenario, get_USER_2());

        test_utils::add_single_reward(scenario);
        test_utils::claim_reward(scenario, get_USER_1(), get_REWARD_LVL());
        test_utils::claim_reward(scenario, get_USER_2(), get_REWARD_LVL());

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::loyalty_token::EInvalidLvl)]
    fun claim_reward_invalid_lvl() {
        let (scenario_val, quest_id) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;
        test_utils::get_verifier(scenario);


        test_utils::mint_token(scenario, get_USER_1());
        test_utils::start_quest(scenario, get_USER_1(), quest_id);
        test_utils::finish_quest(scenario, get_USER_1(), quest_id);

        test_utils::add_single_reward(scenario);
        test_utils::claim_reward(scenario, get_USER_1(), get_REWARD_LVL());

        test_scenario::end(scenario_val);
    }
}