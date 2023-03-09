
<a name="0x0_loyalty_token"></a>

# Module `0x0::loyalty_token`


Loyalty Token module.
This module contains the Loyalty NFT struct and its functions.
Module for minting and managing Loyalty NFT by users.


-  [Resource `LoyaltyToken`](#0x0_loyalty_token_LoyaltyToken)
-  [Struct `MintTokenEvent`](#0x0_loyalty_token_MintTokenEvent)
-  [Struct `ClaimXpEvent`](#0x0_loyalty_token_ClaimXpEvent)
-  [Constants](#@Constants_0)
-  [Function `mint`](#0x0_loyalty_token_mint)
-  [Function `claim_xp`](#0x0_loyalty_token_claim_xp)
-  [Function `claim_reward`](#0x0_loyalty_token_claim_reward)
-  [Function `start_quest`](#0x0_loyalty_token_start_quest)
-  [Function `update_token_stats`](#0x0_loyalty_token_update_token_stats)
-  [Function `get_lvl_by_xp`](#0x0_loyalty_token_get_lvl_by_xp)
-  [Function `get_xp_by_lvl`](#0x0_loyalty_token_get_xp_by_lvl)
-  [Function `get_xp_to_next_lvl`](#0x0_loyalty_token_get_xp_to_next_lvl)


<pre><code><b>use</b> <a href="loyalty_system.md#0x0_loyalty_system">0x0::loyalty_system</a>;
<b>use</b> <a href="quest_store.md#0x0_quest_store">0x0::quest_store</a>;
<b>use</b> <a href="reward_store.md#0x0_reward_store">0x0::reward_store</a>;
<b>use</b> <a href="user_store.md#0x0_user_store">0x0::user_store</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x2::event</a>;
<b>use</b> <a href="">0x2::math</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::table</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x2::url</a>;
<b>use</b> <a href="">0x2::vec_map</a>;
</code></pre>



<a name="0x0_loyalty_token_LoyaltyToken"></a>

## Resource `LoyaltyToken`


LoyaltyToken struct.
This struct represents a LoyaltyToken.
It contains the ID of the LoyaltySystem it belongs to, its name, description, url, level and XP.



<pre><code><b>struct</b> <a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">LoyaltyToken</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_UID">object::UID</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 ID of the LoyaltySystem which this token belongs to.
</dd>
<dt>
<code>name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>description: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">url</a>: <a href="_Url">url::Url</a></code>
</dt>
<dd>

</dd>
<dt>
<code>level: u64</code>
</dt>
<dd>
 Current level of the token.
</dd>
<dt>
<code>xp: u64</code>
</dt>
<dd>
 Current XP of the token.
</dd>
<dt>
<code>xp_to_next_lvl: u64</code>
</dt>
<dd>
 XP needed to reach the next level.
</dd>
</dl>


</details>

<a name="0x0_loyalty_token_MintTokenEvent"></a>

## Struct `MintTokenEvent`



<pre><code><b>struct</b> <a href="loyalty_token.md#0x0_loyalty_token_MintTokenEvent">MintTokenEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>object_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>minter: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>name: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_loyalty_token_ClaimXpEvent"></a>

## Struct `ClaimXpEvent`



<pre><code><b>struct</b> <a href="loyalty_token.md#0x0_loyalty_token_ClaimXpEvent">ClaimXpEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>token_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>claimer: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>claimed_xp: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x0_loyalty_token_INITIAL_XP"></a>



<pre><code><b>const</b> <a href="loyalty_token.md#0x0_loyalty_token_INITIAL_XP">INITIAL_XP</a>: u64 = 0;
</code></pre>



<a name="0x0_loyalty_token_EInvalidLvl"></a>



<pre><code><b>const</b> <a href="loyalty_token.md#0x0_loyalty_token_EInvalidLvl">EInvalidLvl</a>: u64 = 1;
</code></pre>



<a name="0x0_loyalty_token_ENoClaimableXp"></a>



<pre><code><b>const</b> <a href="loyalty_token.md#0x0_loyalty_token_ENoClaimableXp">ENoClaimableXp</a>: u64 = 0;
</code></pre>



<a name="0x0_loyalty_token_INITIAL_LVL"></a>



<pre><code><b>const</b> <a href="loyalty_token.md#0x0_loyalty_token_INITIAL_LVL">INITIAL_LVL</a>: u64 = 0;
</code></pre>



<a name="0x0_loyalty_token_LVL_DIVIDER"></a>



<pre><code><b>const</b> <a href="loyalty_token.md#0x0_loyalty_token_LVL_DIVIDER">LVL_DIVIDER</a>: u64 = 50;
</code></pre>



<a name="0x0_loyalty_token_mint"></a>

## Function `mint`


Mint a new LoyaltyToken for the given LoyaltySystem.
The token is minted with the same name, description and url as the LoyaltySystem.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_mint">mint</a>(ls: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_mint">mint</a>(
    ls: &<b>mut</b> LoyaltySystem,
    ctx: &<b>mut</b> TxContext
) {
    <a href="loyalty_system.md#0x0_loyalty_system_increment_total_minted">loyalty_system::increment_total_minted</a>(ls);

    <b>let</b> nft = <a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">LoyaltyToken</a> {
        id: <a href="_new">object::new</a>(ctx),
        <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: <a href="_id">object::id</a>(ls),
        name: *<a href="loyalty_system.md#0x0_loyalty_system_get_name">loyalty_system::get_name</a>(ls),
        description: *<a href="loyalty_system.md#0x0_loyalty_system_get_description">loyalty_system::get_description</a>(ls),
        <a href="">url</a>: *<a href="loyalty_system.md#0x0_loyalty_system_get_url">loyalty_system::get_url</a>(ls),
        level: <a href="loyalty_token.md#0x0_loyalty_token_INITIAL_LVL">INITIAL_LVL</a>,
        xp: <a href="loyalty_token.md#0x0_loyalty_token_INITIAL_XP">INITIAL_XP</a>,
        xp_to_next_lvl: <a href="loyalty_token.md#0x0_loyalty_token_get_xp_to_next_lvl">get_xp_to_next_lvl</a>(<a href="loyalty_token.md#0x0_loyalty_token_INITIAL_LVL">INITIAL_LVL</a>, <a href="loyalty_token.md#0x0_loyalty_token_INITIAL_XP">INITIAL_XP</a>),
    };
    <b>let</b> sender = <a href="_sender">tx_context::sender</a>(ctx);

    emit(<a href="loyalty_token.md#0x0_loyalty_token_MintTokenEvent">MintTokenEvent</a> {
        object_id: <a href="_id">object::id</a>(&nft),
        <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: <a href="_id">object::id</a>(ls),
        minter: sender,
        name: nft.name,
    });

    <a href="user_store.md#0x0_user_store_add_user">user_store::add_user</a>(<a href="loyalty_system.md#0x0_loyalty_system_get_mut_user_store">loyalty_system::get_mut_user_store</a>(ls), &<a href="_id">object::id</a>(&nft), ctx);
    <a href="_transfer">transfer::transfer</a>(nft, sender);
}
</code></pre>



</details>

<a name="0x0_loyalty_token_claim_xp"></a>

## Function `claim_xp`


Claim the XP earned by the given token.
The token's level and XP to next level are updated accordingly.
Aborts if the token has no XP to claim.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_claim_xp">claim_xp</a>(ls: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, token: &<b>mut</b> <a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">loyalty_token::LoyaltyToken</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_claim_xp">claim_xp</a>(
    ls: &<b>mut</b> LoyaltySystem,
    token: &<b>mut</b> <a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">LoyaltyToken</a>,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> sender = <a href="_sender">tx_context::sender</a>(ctx);
    <b>let</b> claimable_xp = <a href="user_store.md#0x0_user_store_get_user_xp">user_store::get_user_xp</a>(<a href="loyalty_system.md#0x0_loyalty_system_get_user_store">loyalty_system::get_user_store</a>(ls), sender);
    <b>assert</b>!(claimable_xp &gt; 0, <a href="loyalty_token.md#0x0_loyalty_token_ENoClaimableXp">ENoClaimableXp</a>);

    emit(<a href="loyalty_token.md#0x0_loyalty_token_ClaimXpEvent">ClaimXpEvent</a> {
        token_id: <a href="_id">object::id</a>(token),
        claimer: sender,
        claimed_xp: claimable_xp,
    });

    <a href="user_store.md#0x0_user_store_reset_user_xp">user_store::reset_user_xp</a>(<a href="loyalty_system.md#0x0_loyalty_system_get_mut_user_store">loyalty_system::get_mut_user_store</a>(ls), sender);

    <a href="loyalty_token.md#0x0_loyalty_token_update_token_stats">update_token_stats</a>(claimable_xp, ls, token);
}
</code></pre>



</details>

<a name="0x0_loyalty_token_claim_reward"></a>

## Function `claim_reward`


Claim the reward for the given token for the given level.
Aborts if the token's level is lower than the reward's level.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_claim_reward">claim_reward</a>(ls: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, token: &<a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">loyalty_token::LoyaltyToken</a>, reward_lvl: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_claim_reward">claim_reward</a>(
    ls: &<b>mut</b> LoyaltySystem,
    token: &<a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">LoyaltyToken</a>,
    reward_lvl: u64,
    ctx: &<b>mut</b> TxContext
) {
    <b>assert</b>!(token.level &gt;= reward_lvl, <a href="loyalty_token.md#0x0_loyalty_token_EInvalidLvl">EInvalidLvl</a>);
    <a href="reward_store.md#0x0_reward_store_claim_reward">reward_store::claim_reward</a>(
        <a href="_id">object::id</a>(ls),
        <a href="loyalty_system.md#0x0_loyalty_system_get_mut_reward">loyalty_system::get_mut_reward</a>(ls, reward_lvl),
        ctx
    );
}
</code></pre>



</details>

<a name="0x0_loyalty_token_start_quest"></a>

## Function `start_quest`


This function is called by the user.
User function to start quest.
Verifier cant finish quest if user didnt start it.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_start_quest">start_quest</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, token: &<a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">loyalty_token::LoyaltyToken</a>, quest_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_start_quest">start_quest</a>(
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> LoyaltySystem,
    token: &<a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">LoyaltyToken</a>,
    quest_id: ID,
    ctx: &<b>mut</b> TxContext
) {
    <b>assert</b>!(
        token.level &gt;= <a href="quest_store.md#0x0_quest_store_get_quest_lvl">quest_store::get_quest_lvl</a>(<a href="loyalty_system.md#0x0_loyalty_system_get_quests">loyalty_system::get_quests</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>), &quest_id),
        <a href="loyalty_token.md#0x0_loyalty_token_EInvalidLvl">EInvalidLvl</a>
    );
    <a href="quest_store.md#0x0_quest_store_increment_quest_started_count">quest_store::increment_quest_started_count</a>(<a href="loyalty_system.md#0x0_loyalty_system_get_mut_quests">loyalty_system::get_mut_quests</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>), &quest_id);
    <a href="user_store.md#0x0_user_store_start_quest">user_store::start_quest</a>(<a href="loyalty_system.md#0x0_loyalty_system_get_mut_user_store">loyalty_system::get_mut_user_store</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>), &quest_id, <a href="_sender">tx_context::sender</a>(ctx))
}
</code></pre>



</details>

<a name="0x0_loyalty_token_update_token_stats"></a>

## Function `update_token_stats`


Update the token's level and XP based on the given XP to add.



<pre><code><b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_update_token_stats">update_token_stats</a>(xp_to_add: u64, ls: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, token: &<b>mut</b> <a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">loyalty_token::LoyaltyToken</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_update_token_stats">update_token_stats</a>(
    xp_to_add: u64,
    ls: &<b>mut</b> LoyaltySystem,
    token: &<b>mut</b> <a href="loyalty_token.md#0x0_loyalty_token_LoyaltyToken">LoyaltyToken</a>,
) {
    <b>let</b> new_xp = token.xp + xp_to_add;
    <b>let</b> new_lvl = <a href="loyalty_token.md#0x0_loyalty_token_get_lvl_by_xp">get_lvl_by_xp</a>(new_xp);

    token.xp = new_xp;
    token.xp_to_next_lvl = <a href="loyalty_token.md#0x0_loyalty_token_get_xp_to_next_lvl">get_xp_to_next_lvl</a>(new_lvl, new_xp);

    <b>let</b> max_lvl = <a href="loyalty_system.md#0x0_loyalty_system_get_max_lvl">loyalty_system::get_max_lvl</a>(ls);
    token.level = <b>if</b> (new_lvl &lt;= max_lvl) new_lvl <b>else</b> max_lvl;
}
</code></pre>



</details>

<a name="0x0_loyalty_token_get_lvl_by_xp"></a>

## Function `get_lvl_by_xp`


Get the level of the token based on its XP.



<pre><code><b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_get_lvl_by_xp">get_lvl_by_xp</a>(xp: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_get_lvl_by_xp">get_lvl_by_xp</a>(xp: u64): u64 {
    <a href="_sqrt">math::sqrt</a>(xp / <a href="loyalty_token.md#0x0_loyalty_token_LVL_DIVIDER">LVL_DIVIDER</a>)
}
</code></pre>



</details>

<a name="0x0_loyalty_token_get_xp_by_lvl"></a>

## Function `get_xp_by_lvl`


Get the XP needed to reach the given level.



<pre><code><b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_get_xp_by_lvl">get_xp_by_lvl</a>(lvl: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_get_xp_by_lvl">get_xp_by_lvl</a>(lvl: u64): u64 {
    lvl * lvl * <a href="loyalty_token.md#0x0_loyalty_token_LVL_DIVIDER">LVL_DIVIDER</a>
}
</code></pre>



</details>

<a name="0x0_loyalty_token_get_xp_to_next_lvl"></a>

## Function `get_xp_to_next_lvl`


Get the XP needed to reach the next level by current level and XP.



<pre><code><b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_get_xp_to_next_lvl">get_xp_to_next_lvl</a>(lvl: u64, xp: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="loyalty_token.md#0x0_loyalty_token_get_xp_to_next_lvl">get_xp_to_next_lvl</a>(lvl: u64, xp: u64): u64 {
    <a href="loyalty_token.md#0x0_loyalty_token_get_xp_by_lvl">get_xp_by_lvl</a>(lvl + 1) - xp
}
</code></pre>



</details>
