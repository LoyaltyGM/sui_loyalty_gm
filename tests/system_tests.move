#[test_only]
module loyalty_gm::system_tests {
    use std::debug::print;
    use std::string;

    use sui::coin::{Self, Coin};
    use sui::object;
    use sui::sui::SUI;
    use sui::test_scenario::{Self, Scenario};
    use sui::url;
    use sui::vec_map;

    use loyalty_gm::loyalty_system::{Self, LoyaltySystem, AdminCap};
    use loyalty_gm::system_store::{Self, SystemStore, SYSTEM_STORE};
    use loyalty_gm::test_utils::{Self, get_ADMIN, get_USER_1, get_USER_2, get_LS_NAME, get_LS_DESCRIPTION, get_LS_URL, get_LS_MAX_SUPPLY, get_LS_MAX_LVL, get_QUEST_REWARD, get_REWARD_POOL_AMT};

    // ======== Errors =========

    const Error: u64 = 1;

    // ======== Utils =========

    #[test_only]
    public fun init_create_loyalty_system(): Scenario {
        let scenario_val = test_scenario::begin(get_ADMIN());
        let scenario = &mut scenario_val;

        test_utils::mint_sui(scenario);
        test_utils::create_system_store(scenario);
        test_utils::create_loyalty_system(scenario, get_ADMIN());

        scenario_val
    }

    #[test_only]
    public fun init_add_quest(quest_lvl: u64, completed_supply: u64): (Scenario, object::ID) {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;
        let quest_id: object::ID;

        test_utils::add_quest(scenario, quest_lvl, completed_supply);

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let (id, _) = vec_map::get_entry_by_idx(loyalty_system::get_quests(&ls), 0);
            quest_id = *id;
            test_scenario::return_shared(ls);
        };

        (scenario_val, quest_id)
    }

    #[test_only]
    public fun init_finish_quest(): Scenario {
        let (scenario_val, quest_id) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;

        test_utils::get_verifier(scenario);

        test_utils::mint_token(scenario, get_USER_1());
        test_utils::start_quest(scenario, get_USER_1(), quest_id);

        test_utils::finish_quest(scenario, get_USER_1(), quest_id);

        scenario_val
    }

    // ======== Tests =========

    // ======== System

    #[test]
    public fun create_loyalty_system() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(*loyalty_system::get_name(&ls) == string::utf8(get_LS_NAME()), Error);
            assert!(*loyalty_system::get_description(&ls) == string::utf8(get_LS_DESCRIPTION()), Error);
            assert!(*loyalty_system::get_url(&ls) == url::new_unsafe_from_bytes(get_LS_URL()), Error);
            assert!(loyalty_system::get_max_supply(&ls) == get_LS_MAX_SUPPLY(), Error);
            assert!(loyalty_system::get_max_lvl(&ls) == get_LS_MAX_LVL(), Error);

            let store = test_scenario::take_shared<SystemStore<SYSTEM_STORE>>(scenario);

            assert!(system_store::contains(&store, object::id(&ls)), Error);
            assert!(system_store::borrow(&store, 0) == object::id(&ls), Error);
            assert!(system_store::length(&store) == 1, Error);

            test_scenario::return_shared(ls);
            test_scenario::return_shared(store);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun update_loyalty_system_name() {
        let new_name = b"new name";
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);

            loyalty_system::update_name(
                &admin_cap,
                &mut ls,
                new_name,
            );
            assert!(*loyalty_system::get_name(&ls) == string::utf8(new_name), Error);

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::loyalty_system::EAdminOnly)]
    fun check_admin_cap() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_utils::create_loyalty_system(scenario, get_USER_1());

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let admin_cap = test_scenario::take_from_sender<AdminCap>(scenario);

            loyalty_system::check_admin_test(
                &admin_cap,
                &mut ls,
            );

            test_scenario::return_shared(ls);
            test_scenario::return_to_sender(scenario, admin_cap);
        };

        test_scenario::end(scenario_val);
    }

    // ======== Quests

    #[test]
    public fun add_quest() {
        let (scenario_val, _) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(vec_map::size(loyalty_system::get_quests(&ls)) == 1, Error);

            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    public fun finish_quest() {
        let scenario_val = init_finish_quest();
        let scenario = &mut scenario_val;

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(loyalty_system::get_claimable_xp_test(&ls, get_USER_1()) == get_QUEST_REWARD(), Error);

            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::quest_store::EQuestCompletedSupplyReached)]
    public fun finish_quest_completed_supply() {
        let (scenario_val, quest_id) = init_add_quest(0, 1);
        let scenario = &mut scenario_val;

        test_utils::get_verifier(scenario);

        test_utils::mint_token(scenario, get_USER_1());
        test_utils::start_quest(scenario, get_USER_1(), quest_id);
        test_utils::finish_quest(scenario, get_USER_1(), quest_id);

        test_utils::mint_token(scenario, get_USER_2());
        test_utils::start_quest(scenario, get_USER_2(), quest_id);
        test_utils::finish_quest(scenario, get_USER_2(), quest_id);

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::user_store::EQuestAlreadyDone)]
    public fun start_quest_twice() {
        let (scenario_val, quest_id) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;

        test_utils::get_verifier(scenario);

        test_utils::mint_token(scenario, get_USER_1());
        test_utils::start_quest(scenario, get_USER_1(), quest_id);

        test_utils::finish_quest(scenario, get_USER_1(), quest_id);

        test_utils::start_quest(scenario, get_USER_1(), quest_id);

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::user_store::EQuestAlreadyDone)]
    public fun finish_quest_twice() {
        let (scenario_val, quest_id) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;

        test_utils::get_verifier(scenario);

        test_utils::mint_token(scenario, get_USER_1());
        test_utils::start_quest(scenario, get_USER_1(), quest_id);

        test_utils::finish_quest(scenario, get_USER_1(), quest_id);
        test_utils::finish_quest(scenario, get_USER_1(), quest_id);

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::user_store::EQuestNotStarted)]
    public fun finish_not_started_quest() {
        let (scenario_val, quest_id) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;

        test_utils::get_verifier(scenario);
        test_utils::mint_token(scenario, get_USER_1());

        test_utils::finish_quest(scenario, get_USER_1(), quest_id);

        test_scenario::end(scenario_val);
    }

    #[test]
    fun remove_quest() {
        let (scenario_val, quest_id) = init_add_quest(0, 0);
        let scenario = &mut scenario_val;

        test_utils::remove_quest(scenario, quest_id);

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(vec_map::size(loyalty_system::get_quests(&ls)) == 0, Error);

            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }

    // ======== Rewards

    #[test]
    fun add_reward() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_utils::add_reward(scenario);

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(vec_map::size(loyalty_system::get_rewards(&ls)) == 1, Error);
            let (_, reward) = vec_map::get_entry_by_idx(loyalty_system::get_rewards(&ls), 0);
            print(reward);

            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::reward_store::EInvalidSupply)]
    fun add_invalid_supply_reward() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_utils::add_fail_pool_reward(scenario);

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::loyalty_system::EInvalidLevel)]
    fun add_invalid_lvl_reward() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_utils::add_fail_lvl_reward(scenario);

        test_scenario::end(scenario_val);
    }

    #[test]
    fun remove_reward() {
        let scenario_val = init_create_loyalty_system();
        let scenario = &mut scenario_val;

        test_utils::add_reward(scenario);
        test_utils::remove_reward(scenario);

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);
            let coin = test_scenario::take_from_sender<Coin<SUI>>(scenario);

            assert!(vec_map::size(loyalty_system::get_rewards(&ls)) == 0, Error);
            assert!(coin::value(&coin) == get_REWARD_POOL_AMT(), Error);

            test_scenario::return_to_sender(scenario, coin);
            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }
}