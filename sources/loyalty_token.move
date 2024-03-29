/**
    Loyalty Token module.
    This module contains the Loyalty NFT struct and its functions.
    Module for minting and managing Loyalty NFT by users.
*/
module loyalty_gm::loyalty_token {
    use std::string::{String, utf8};

    use sui::event::emit;
    use sui::math;
    use sui::object::{Self, UID, ID};
    use sui::transfer::{public_transfer, transfer};
    use sui::tx_context::{TxContext, sender};
    use sui::url::Url;
    use sui::package;
    use sui::display;

    use loyalty_gm::loyalty_system::{Self, LoyaltySystem};
    use loyalty_gm::quest_store;
    use loyalty_gm::reward_store;
    use loyalty_gm::user_store;

    // ======== Constants =========

    const INITIAL_LVL: u64 = 0;
    const INITIAL_XP: u64 = 0;
    const LVL_DIVIDER: u64 = 50;

    // ======== Error codes =========

    const ENoClaimableXp: u64 = 0;
    const EInvalidLvl: u64 = 1;

    // ======== Structs =========

    struct LOYALTY_TOKEN has drop {}

    /**
        LoyaltyToken struct.
        This struct represents a LoyaltyToken.
        It contains the ID of the LoyaltySystem it belongs to, its name, description, url, level and XP.
    */
    struct LoyaltyToken has key {
        id: UID,
        /// ID of the LoyaltySystem which this token belongs to.
        loyalty_system: ID,
        name: String,
        description: String,
        url: Url,
        /// Current level of the token.
        level: u64,
        /// Current XP of the token.
        xp: u64,
        /// XP needed to reach the next level.
        xp_to_next_lvl: u64,
    }

    // ======== Events =========

    struct MintTokenEvent has copy, drop {
        object_id: ID,
        loyalty_system: ID,
        minter: address,
        name: String,
    }

    struct ClaimXpEvent has copy, drop {
        token_id: ID,
        claimer: address,
        claimed_xp: u64,
    }

    // ======= Functions =======

    fun init(otw: LOYALTY_TOKEN, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"description"),
            utf8(b"image_url"),
            utf8(b"project_url"),
        ];

        let values = vector[
            utf8(b"{name}"),
            utf8(b"{description}"),
            utf8(b"{url}"),
            utf8(b"https://www.loyaltygm.com"),
        ];

        let publisher = package::claim(otw, ctx);
        let display = display::new_with_fields<LoyaltyToken>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);

        public_transfer(display, sender(ctx));
        public_transfer(publisher, sender(ctx));
    }


    // ======= Public functions =======

    /**
        Mint a new LoyaltyToken for the given LoyaltySystem.
        The token is minted with the same name, description and url as the LoyaltySystem.
    */
    public entry fun mint(
        ls: &mut LoyaltySystem,
        ctx: &mut TxContext
    ) {
        loyalty_system::increment_total_minted(ls);

        let nft = LoyaltyToken {
            id: object::new(ctx),
            loyalty_system: object::id(ls),
            name: *loyalty_system::get_name(ls),
            description: *loyalty_system::get_description(ls),
            url: *loyalty_system::get_url(ls),
            level: INITIAL_LVL,
            xp: INITIAL_XP,
            xp_to_next_lvl: get_xp_to_next_lvl(INITIAL_LVL, INITIAL_XP),
        };
        let sender = sender(ctx);

        emit(MintTokenEvent {
            object_id: object::id(&nft),
            loyalty_system: object::id(ls),
            minter: sender,
            name: nft.name,
        });

        user_store::add_user(loyalty_system::get_mut_user_store(ls), &object::id(&nft), ctx);
        transfer(nft, sender);
    }

    /**
        Claim the XP earned by the given token.
        The token's level and XP to next level are updated accordingly.
        Aborts if the token has no XP to claim.
    */
    public entry fun claim_xp(
        ls: &mut LoyaltySystem,
        token: &mut LoyaltyToken,
        ctx: &mut TxContext
    ) {
        let sender = sender(ctx);
        let claimable_xp = user_store::get_user_xp(loyalty_system::get_user_store(ls), sender);
        assert!(claimable_xp > 0, ENoClaimableXp);

        emit(ClaimXpEvent {
            token_id: object::id(token),
            claimer: sender,
            claimed_xp: claimable_xp,
        });

        user_store::reset_user_xp(loyalty_system::get_mut_user_store(ls), sender);

        update_token_stats(sender, claimable_xp, ls, token);
    }

    /**
        Claim the reward for the given token for the given level.
        Aborts if the token's level is lower than the reward's level.
    */
    public entry fun claim_reward(
        ls: &mut LoyaltySystem,
        token: &LoyaltyToken,
        reward_lvl: u64,
        ctx: &mut TxContext
    ) {
        assert!(token.level >= reward_lvl, EInvalidLvl);
        reward_store::claim_reward(
            object::id(ls),
            loyalty_system::get_mut_reward(ls, reward_lvl),
            ctx
        );
    }

    /**
        This function is called by the user.
        User function to start quest.
        Verifier cant finish quest if user didnt start it.
    */
    public entry fun start_quest(
        loyalty_system: &mut LoyaltySystem,
        token: &LoyaltyToken,
        quest_id: ID,
        ctx: &mut TxContext
    ) {
        assert!(
            token.level >= quest_store::get_quest_lvl(loyalty_system::get_quests(loyalty_system), &quest_id),
            EInvalidLvl
        );
        quest_store::increment_quest_started_count(loyalty_system::get_mut_quests(loyalty_system), &quest_id);
        user_store::start_quest(loyalty_system::get_mut_user_store(loyalty_system), &quest_id, sender(ctx))
    }

    // ======= Private and Utility functions =======

    /**
        Update the token's level and XP based on the given XP to add.
    */
    fun update_token_stats(
        owner: address,
        xp_to_add: u64,
        ls: &mut LoyaltySystem,
        token: &mut LoyaltyToken,
    ) {
        let new_xp = token.xp + xp_to_add;
        let new_lvl = get_lvl_by_xp(new_xp);

        token.xp = new_xp;
        token.xp_to_next_lvl = get_xp_to_next_lvl(new_lvl, new_xp);

        let max_lvl = loyalty_system::get_max_lvl(ls);
        token.level = if (new_lvl <= max_lvl) new_lvl else max_lvl;

        user_store::update_user_total_xp(loyalty_system::get_mut_user_store(ls), owner, new_xp);
        user_store::update_user_lvl(loyalty_system::get_mut_user_store(ls), owner, new_lvl);
    }

    /**
        Get the level of the token based on its XP.
    */
    fun get_lvl_by_xp(xp: u64): u64 {
        math::sqrt(xp / LVL_DIVIDER)
    }

    /**
        Get the XP needed to reach the given level.
    */
    fun get_xp_by_lvl(lvl: u64): u64 {
        lvl * lvl * LVL_DIVIDER
    }

    /**
        Get the XP needed to reach the next level by current level and XP.
    */
    fun get_xp_to_next_lvl(lvl: u64, xp: u64): u64 {
        get_xp_by_lvl(lvl + 1) - xp
    }

    #[test_only]
    public fun get_xp(token: &LoyaltyToken): u64 {
        token.xp
    }

    #[test_only]
    public fun get_lvl(token: &LoyaltyToken): u64 {
        token.level
    }
}