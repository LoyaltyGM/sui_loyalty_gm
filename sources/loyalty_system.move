/**
    Loyalty System Module.
    This module contains the implementation of the Loyalty System.
    Module for creating and managing loyalty systems by the admin and verifying quests by the verifier.
*/
module loyalty_gm::loyalty_system {
    use std::option;
    use std::string::{Self, String, utf8};
    use std::vector::length;

    use sui::coin::Coin;
    use sui::dynamic_object_field as dof;
    use sui::event::emit;
    use sui::object::{Self, UID, ID};
    use sui::sui::SUI;
    use sui::table::Table;
    use sui::transfer::{public_transfer, transfer, share_object};
    use sui::tx_context::{sender, TxContext};
    use sui::url::{Self, Url};
    use sui::vec_map::{Self, VecMap};
    use sui::package;
    use sui::display;

    use loyalty_gm::quest_store::{Self, Quest};
    use loyalty_gm::reward_store::{Self, Reward};
    use loyalty_gm::system_store::{Self, SystemStore, SYSTEM_STORE};
    use loyalty_gm::user_store::{Self, User};

    friend loyalty_gm::loyalty_token;

    // ======== Constants =========
    const USER_STORE_KEY: vector<u8> = b"user_store";
    const MAX_NAME_LENGTH: u64 = 32;
    const MAX_DESCRIPTION_LENGTH: u64 = 255;
    const BASIC_MAX_LVL: u64 = 100;
    const ADMIN_CAP_URL: vector<u8> = b"ipfs://bafybeia7wcjeumzhyizqogeon7urjdgll5zpms3sckvfv6tut77i3kneru/Favicon.png";

    // ======== Error codes =========
    const EAdminOnly: u64 = 0;
    const ETextOverflow: u64 = 1;
    const EInvalidLevel: u64 = 2;
    const EMaxSupplyReached: u64 = 3;


    // ======== Structs =========

    /**
        Admin capability to manage the loyalty system.
        Created separately for each system.
    */
    struct LOYALTY_SYSTEM has drop {}

    struct AdminCap has key, store {
        id: UID,
        name: String,
        description: String,
        url: Url,
        loyalty_system: ID,
    }

    /**
        Verifier capability to finish quests.
        Created once per package.
    */
    struct VerifierCap has key, store {
        id: UID,
    }

    /**
        Loyalty system struct.
        Contains all the information about the loyalty system.
        Contains the user store in the dynamic field.
    */
    struct LoyaltySystem has key {
        id: UID,
        /// Loyalty system name
        name: String,
        /// Loyalty system description
        description: String,
        /// Total number of NFTs that have been issued. 
        total_minted: u64,
        /// Loyalty NFTs total max supply
        max_supply: u64,
        /// Loyalty system image url
        url: Url,
        creator: address,
        /// Max level of the loyalty NFTs
        max_lvl: u64,
        /// Quests of the loyalty system quest_ID -> Quest
        quests: VecMap<ID, Quest>,
        /// Rewards of the loyalty system reward_lvl -> Reward
        rewards: VecMap<u64, Reward>,

        /*
            --dynamic fields--
            /// User store of the loyalty system user_address -> User
            user_store: Table<address, User>,
        */
    }

    // ======== Events =========

    struct CreateLoyaltySystemEvent has copy, drop {
        /// The Object ID of the NFT
        object_id: ID,
        /// To control the access to the admin functions
        admin_cap: ID,
        /// The creator of LS
        creator: address,
        /// The name of the NFT
        name: string::String,
    }

    // ======== Init =========

    fun init(otw: LOYALTY_SYSTEM, ctx: &mut TxContext) {
        let ls_keys = vector[
            utf8(b"name"),
            utf8(b"description"),
            utf8(b"image_url"),
            utf8(b"creator"),
            utf8(b"project_url"),
        ];

        let ls_values = vector[
            utf8(b"{name}"),
            utf8(b"{description}"),
            utf8(b"{url}"),
            utf8(b"{creator}"),
            utf8(b"https://www.loyaltygm.com"),
        ];

        let ac_keys = vector[
            utf8(b"name"),
            utf8(b"description"),
            utf8(b"image_url"),
            utf8(b"project_url"),
        ];

        let ac_values = vector[
            utf8(b"{name}"),
            utf8(b"{description}"),
            utf8(b"{url}"),
            utf8(b"https://www.loyaltygm.com"),
        ];

        let publisher = package::claim(otw, ctx);
        let ls_display = display::new_with_fields<LoyaltySystem>(
            &publisher, ls_keys, ls_values, ctx
        );
        let ac_display = display::new_with_fields<AdminCap>(
            &publisher, ac_keys, ac_values, ctx
        );

        display::update_version(&mut ls_display);
        display::update_version(&mut ac_display);

        public_transfer(ls_display, sender(ctx));
        public_transfer(ac_display, sender(ctx));
        public_transfer(publisher, sender(ctx));
        transfer(VerifierCap {
            id: object::new(ctx)
        }, sender(ctx));
    }

    // ======== Admin Functions =========

    /**
        Create a new loyalty system.
        Transfer to the creator AdminCap.
        The creator of the system will be the admin of the system.
    */
    public entry fun create_loyalty_system(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        max_supply: u64,
        max_lvl: u64,
        system_store: &mut SystemStore<SYSTEM_STORE>,
        ctx: &mut TxContext,
    ) {
        assert!(length(&name) <= MAX_NAME_LENGTH, ETextOverflow);
        assert!(length(&description) <= MAX_DESCRIPTION_LENGTH, ETextOverflow);
        assert!(max_lvl <= BASIC_MAX_LVL, EInvalidLevel);

        let creator = sender(ctx);

        let loyalty_system = LoyaltySystem {
            id: object::new(ctx),
            name: utf8(name),
            description: utf8(description),
            url: url::new_unsafe_from_bytes(url),
            total_minted: 0,
            max_supply,
            creator,
            max_lvl,
            quests: quest_store::empty(),
            rewards: reward_store::empty(),
        };
        dof::add(&mut loyalty_system.id, USER_STORE_KEY, user_store::new(ctx));

        let admin_cap = AdminCap {
            id: object::new(ctx),
            name: utf8(b"Admin Cap"),
            description: utf8(b"Allows to manage the loyalty system"),
            url: url::new_unsafe_from_bytes(ADMIN_CAP_URL),
            loyalty_system: object::uid_to_inner(&loyalty_system.id),
        };

        emit(CreateLoyaltySystemEvent {
            object_id: object::uid_to_inner(&loyalty_system.id),
            creator,
            name: loyalty_system.name,
            admin_cap: object::uid_to_inner(&admin_cap.id),
        });

        system_store::add_system(system_store, object::uid_to_inner(&loyalty_system.id), ctx);
        share_object(loyalty_system);
        transfer(admin_cap, creator);
    }

    // ======== Admin Functions: Update

    public entry fun update_name(admin_cap: &AdminCap, loyalty_system: &mut LoyaltySystem, new_name: vector<u8>) {
        assert!(length(&new_name) <= MAX_NAME_LENGTH, ETextOverflow);
        check_admin(admin_cap, loyalty_system);
        loyalty_system.name = utf8(new_name);
    }

    public entry fun update_description(
        admin_cap: &AdminCap,
        loyalty_system: &mut LoyaltySystem,
        new_description: vector<u8>
    ) {
        assert!(length(&new_description) <= MAX_DESCRIPTION_LENGTH, ETextOverflow);
        check_admin(admin_cap, loyalty_system);
        loyalty_system.description = utf8(new_description);
    }

    public entry fun update_url(admin_cap: &AdminCap, loyalty_system: &mut LoyaltySystem, new_url: vector<u8>) {
        check_admin(admin_cap, loyalty_system);
        loyalty_system.url = url::new_unsafe_from_bytes(new_url);
    }

    public entry fun update_max_supply(admin_cap: &AdminCap, loyalty_system: &mut LoyaltySystem, new_max_supply: u64) {
        check_admin(admin_cap, loyalty_system);
        loyalty_system.max_supply = new_max_supply;
    }

    // ======== Admin Functions: Rewards

    /**
        Add a new reward to the loyalty system.
        Users can claim rewards by reaching a certain level.
    */
    public entry fun add_coin_reward(
        admin_cap: &AdminCap,
        loyalty_system: &mut LoyaltySystem,
        level: u64,
        description: vector<u8>,
        reward_pool: Coin<SUI>,
        reward_supply: u64,
        ctx: &mut TxContext
    ) {
        check_admin(admin_cap, loyalty_system);
        assert!(level <= loyalty_system.max_lvl, EInvalidLevel);

        reward_store::add_coin_reward(
            &mut loyalty_system.rewards,
            level,
            description,
            reward_pool,
            reward_supply,
            ctx
        );
    }

    public entry fun add_nft_reward(
        admin_cap: &AdminCap,
        loyalty_system: &mut LoyaltySystem,
        level: u64,
        url: vector<u8>,
        description: vector<u8>,
        reward_supply: u64,
        ctx: &mut TxContext
    ) {
        check_admin(admin_cap, loyalty_system);
        assert!(level <= loyalty_system.max_lvl, EInvalidLevel);

        reward_store::add_nft_reward(
            &mut loyalty_system.rewards,
            level,
            url,
            description,
            reward_supply,
            ctx
        );
    }

    public entry fun add_soulbond_reward(
        admin_cap: &AdminCap,
        loyalty_system: &mut LoyaltySystem,
        level: u64,
        url: vector<u8>,
        description: vector<u8>,
        reward_supply: u64,
        ctx: &mut TxContext
    ) {
        check_admin(admin_cap, loyalty_system);
        assert!(level <= loyalty_system.max_lvl, EInvalidLevel);

        reward_store::add_soulbond_reward(
            &mut loyalty_system.rewards,
            level,
            url,
            description,
            reward_supply,
            ctx
        );
    }

    /**
        Remove a reward from the loyalty system.
    */
    public entry fun remove_reward(
        admin_cap: &AdminCap,
        loyalty_system: &mut LoyaltySystem,
        level: u64,
        ctx: &mut TxContext
    ) {
        check_admin(admin_cap, loyalty_system);

        reward_store::remove_reward(&mut loyalty_system.rewards, level, ctx);
    }

    // ======== Admin Functions: Quests

    /**
        Add a new quest to the loyalty system.
        Users can complete quests to earn XP.
    */
    public entry fun add_quest(
        admin_cap: &AdminCap,
        loyalty_system: &mut LoyaltySystem,
        lvl: u64,
        name: vector<u8>,
        description: vector<u8>,
        reward_xp: u64,
        completed_supply: u64,
        package_id: ID,
        module_name: vector<u8>,
        function_name: vector<u8>,
        arguments: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        check_admin(admin_cap, loyalty_system);

        quest_store::add_quest(
            &mut loyalty_system.quests,
            lvl,
            name,
            description,
            reward_xp,
            if (completed_supply == 0) option::none<u64>() else option::some(completed_supply),
            package_id,
            module_name,
            function_name,
            arguments,
            ctx,
        );
    }

    /**
        Remove a quest from the loyalty system.
    */
    public entry fun remove_quest(
        admin_cap: &AdminCap,
        loyalty_system: &mut LoyaltySystem,
        quest_id: ID,
        _: &mut TxContext
    ) {
        check_admin(admin_cap, loyalty_system);

        quest_store::remove_quest(&mut loyalty_system.quests, &quest_id);
    }

    // ======= Verifier functions =======

    /**
        Verifier function to finish a quest.
        This function is called by publisher.
    */
    public entry fun finish_quest(
        _: &VerifierCap,
        loyalty_system: &mut LoyaltySystem,
        quest_id: ID,
        user: address
    ) {
        let reward_xp = quest_store::get_quest_reward(&loyalty_system.quests, &quest_id);
        let user_store = get_mut_user_store(loyalty_system);
        user_store::finish_quest(
            user_store,
            &quest_id,
            user,
            reward_xp
        );
        quest_store::increment_quest_completed_count(&mut loyalty_system.quests, &quest_id);
    }

    // ======= Public functions =======

    // ======= Public functions: Friends

    /**
        Get the mutable user store.
    */
    public(friend) fun get_mut_user_store(loyalty_system: &mut LoyaltySystem): &mut Table<address, User> {
        dof::borrow_mut(&mut loyalty_system.id, USER_STORE_KEY)
    }

    public(friend) fun get_mut_quests(loyalty_system: &mut LoyaltySystem): &mut VecMap<ID, Quest> {
        &mut loyalty_system.quests
    }

    /**
        Get the mutable reward.
    */
    public(friend) fun get_mut_reward(loyalty_system: &mut LoyaltySystem, lvl: u64): &mut Reward {
        vec_map::get_mut(&mut loyalty_system.rewards, &lvl)
    }

    /**
        Increment the total minted count.
    */
    public(friend) fun increment_total_minted(loyalty_system: &mut LoyaltySystem) {
        assert!(get_total_minted(loyalty_system) <= get_max_supply(loyalty_system), EMaxSupplyReached);
        loyalty_system.total_minted = loyalty_system.total_minted + 1;
    }

    // ======= Public functions: View
    /**
        Get the name of the loyalty system.     
    */
    public fun get_name(loyalty_system: &LoyaltySystem): &string::String {
        &loyalty_system.name
    }

    public fun get_max_supply(loyalty_system: &LoyaltySystem): u64 {
        loyalty_system.max_supply
    }

    public fun get_total_minted(loyalty_system: &LoyaltySystem): u64 {
        loyalty_system.total_minted
    }

    public fun get_description(loyalty_system: &LoyaltySystem): &string::String {
        &loyalty_system.description
    }

    public fun get_url(loyalty_system: &LoyaltySystem): &Url {
        &loyalty_system.url
    }

    public fun get_user_store(loyalty_system: &LoyaltySystem): &Table<address, User> {
        dof::borrow(&loyalty_system.id, USER_STORE_KEY)
    }

    public fun get_user(loyalty_system: &LoyaltySystem, user: address): &User {
        user_store::get_user(get_user_store(loyalty_system), user)
    }

    public fun get_max_lvl(loyalty_system: &LoyaltySystem): u64 {
        loyalty_system.max_lvl
    }

    public fun get_quests(loyalty_system: &LoyaltySystem): &VecMap<ID, Quest> {
        &loyalty_system.quests
    }

    public fun get_rewards(loyalty_system: &LoyaltySystem): &VecMap<u64, Reward> {
        &loyalty_system.rewards
    }

    // ======= Private/Utility functions =======

    fun check_admin(admin_cap: &AdminCap, system: &LoyaltySystem) {
        assert!(object::borrow_id(system) == &admin_cap.loyalty_system, EAdminOnly);
    }

    #[test_only]
    public fun check_admin_test(admin_cap: &AdminCap, system: &LoyaltySystem) {
        check_admin(admin_cap, system)
    }

    #[test_only]
    fun init_test(ctx: &mut TxContext) {
        transfer(VerifierCap {
            id: object::new(ctx)
        }, sender(ctx))
    }

    #[test_only]
    public fun get_verifier(ctx: &mut TxContext) {
        init_test(ctx)
    }

    #[test_only]
    public fun get_claimable_xp_test(ls: &LoyaltySystem, user: address): u64 {
        user_store::get_user_xp(get_user_store(ls), user)
    }
}