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
    use loyalty_gm::test_utils::{get_ADMIN, get_USER_1, get_USER_2, get_LS_NAME, get_LS_DESCRIPTION, get_LS_URL, get_LS_MAX_SUPPLY, get_LS_MAX_LVL, mint_sui, create_system_store, create_loyalty_system, get_TASK_REWARD, add_task, get_verifier, mint_token, start_task, finish_task, remove_task, get_REWARD_POOL_AMT, add_reward, add_fail_pool_reward, remove_reward, add_fail_lvl_reward};

    // ======== Errors =========

    const Error: u64 = 1;

    // ======== Tests =========

    // ======== System

    #[test]
    public fun create_loyalty_system_test(): Scenario {
        let scenario_val = test_scenario::begin(get_ADMIN());
        let scenario = &mut scenario_val;

        mint_sui(scenario);
        create_system_store(scenario);
        create_loyalty_system(scenario, get_ADMIN());

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

        scenario_val
    }

    #[test]
    fun update_loyalty_system_test() {
        let new_name = b"new name";
        let scenario_val = create_loyalty_system_test();
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
    fun check_admin_cap_test() {
        let scenario_val = create_loyalty_system_test();
        let scenario = &mut scenario_val;

        create_loyalty_system(scenario, get_USER_1());

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

    // ======== Tasks

    public fun add_task_test(task_lvl: u64, completed_supply: u64): (Scenario, object::ID) {
        let scenario_val = create_loyalty_system_test();
        let scenario = &mut scenario_val;
        let task_id: object::ID;

        add_task(scenario, task_lvl, completed_supply);

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(vec_map::size(loyalty_system::get_tasks(&ls)) == 1, Error);
            let (id, _) = vec_map::get_entry_by_idx(loyalty_system::get_tasks(&ls), 0);
            // print(loyalty_system::get_tasks(&ls));
            task_id = *id;
            print(id);

            test_scenario::return_shared(ls);
        };

        (scenario_val, task_id)
    }

    #[test]
    public fun finish_task_test(): Scenario {
        let (scenario_val, task_id) = add_task_test(0, 0);
        let scenario = &mut scenario_val;

        get_verifier(scenario);

        mint_token(scenario, get_USER_1());
        start_task(scenario, get_USER_1(), task_id);

        finish_task(scenario, get_USER_1(), task_id);

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(loyalty_system::get_claimable_xp_test(&ls, get_USER_1()) == get_TASK_REWARD(), Error);

            test_scenario::return_shared(ls);
        };

        scenario_val
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::task_store::ETaskCompletedSupplyReached)]
    public fun fail_finish_task_completed_supply_test() {
        let (scenario_val, task_id) = add_task_test(0, 1);
        let scenario = &mut scenario_val;

        get_verifier(scenario);

        mint_token(scenario, get_USER_1());
        start_task(scenario, get_USER_1(), task_id);
        finish_task(scenario, get_USER_1(), task_id);

        mint_token(scenario, get_USER_2());
        start_task(scenario, get_USER_2(), task_id);
        finish_task(scenario, get_USER_2(), task_id);

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::user_store::ETaskAlreadyDone)]
    public fun fail_start_task_twice_test() {
        let (scenario_val, task_id) = add_task_test(0, 0);
        let scenario = &mut scenario_val;

        get_verifier(scenario);

        mint_token(scenario, get_USER_1());
        start_task(scenario, get_USER_1(), task_id);

        finish_task(scenario, get_USER_1(), task_id);

        start_task(scenario, get_USER_1(), task_id);

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::user_store::ETaskAlreadyDone)]
    public fun fail_finish_task_twice_test() {
        let (scenario_val, task_id) = add_task_test(0, 0);
        let scenario = &mut scenario_val;

        get_verifier(scenario);

        mint_token(scenario, get_USER_1());
        start_task(scenario, get_USER_1(), task_id);

        finish_task(scenario, get_USER_1(), task_id);
        finish_task(scenario, get_USER_1(), task_id);

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::user_store::ETaskNotStarted)]
    public fun fail_finish_not_started_task_test() {
        let (scenario_val, task_id) = add_task_test(0, 0);
        let scenario = &mut scenario_val;

        get_verifier(scenario);
        mint_token(scenario, get_USER_1());

        finish_task(scenario, get_USER_1(), task_id);

        test_scenario::end(scenario_val);
    }

    #[test]
    fun remove_task_test() {
        let (scenario_val, task_id) = add_task_test(0, 0);
        let scenario = &mut scenario_val;

        remove_task(scenario, task_id);

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(vec_map::size(loyalty_system::get_tasks(&ls)) == 0, Error);

            test_scenario::return_shared(ls);
        };

        test_scenario::end(scenario_val);
    }

    // ======== Rewards

    #[test]
    fun add_reward_test(): (Scenario) {
        let scenario_val = create_loyalty_system_test();
        let scenario = &mut scenario_val;

        add_reward(scenario);

        test_scenario::next_tx(scenario, get_ADMIN());
        {
            let ls = test_scenario::take_shared<LoyaltySystem>(scenario);

            assert!(vec_map::size(loyalty_system::get_rewards(&ls)) == 1, Error);
            let (_, reward) = vec_map::get_entry_by_idx(loyalty_system::get_rewards(&ls), 0);
            print(reward);

            test_scenario::return_shared(ls);
        };

        scenario_val
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::reward_store::EInvalidSupply)]
    fun add_fail_pool_reward_test() {
        let scenario_val = create_loyalty_system_test();
        let scenario = &mut scenario_val;

        add_fail_pool_reward(scenario);

        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = loyalty_gm::loyalty_system::EInvalidLevel)]
    fun add_fail_lvl_reward_test() {
        let scenario_val = create_loyalty_system_test();
        let scenario = &mut scenario_val;

        add_fail_lvl_reward(scenario);

        test_scenario::end(scenario_val);
    }

    #[test]
    fun remove_reward_test() {
        let scenario_val = add_reward_test();
        let scenario = &mut scenario_val;

        remove_reward(scenario);

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