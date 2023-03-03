
<a name="0x0_reward_store"></a>

# Module `0x0::reward_store`


Reward Store Module.
This module is responsible for managing the rewards for the loyalty system.
Its functions are only accessible by the friend modules.


-  [Resource `Reward`](#0x0_reward_store_Reward)
-  [Struct `CreateRewardEvent`](#0x0_reward_store_CreateRewardEvent)
-  [Constants](#@Constants_0)
-  [Function `empty`](#0x0_reward_store_empty)
-  [Function `add_reward`](#0x0_reward_store_add_reward)
-  [Function `remove_reward`](#0x0_reward_store_remove_reward)
-  [Function `claim_reward`](#0x0_reward_store_claim_reward)
-  [Function `set_reward_claimed`](#0x0_reward_store_set_reward_claimed)
-  [Function `check_claimed`](#0x0_reward_store_check_claimed)
-  [Function `delete_reward`](#0x0_reward_store_delete_reward)


<pre><code><b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::dynamic_object_field</a>;
<b>use</b> <a href="">0x2::event</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::pay</a>;
<b>use</b> <a href="">0x2::sui</a>;
<b>use</b> <a href="">0x2::table</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x2::vec_map</a>;
</code></pre>



<a name="0x0_reward_store_Reward"></a>

## Resource `Reward`


Reward struct.
This struct represents a reward for the loyalty system.



<pre><code><b>struct</b> <a href="reward_store.md#0x0_reward_store_Reward">Reward</a> <b>has</b> store, key
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
<code>level: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>description: <a href="_String">string::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>reward_pool: <a href="_Balance">balance::Balance</a>&lt;<a href="_SUI">sui::SUI</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>reward_supply: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>reward_per_user: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_reward_store_CreateRewardEvent"></a>

## Struct `CreateRewardEvent`



<pre><code><b>struct</b> <a href="reward_store.md#0x0_reward_store_CreateRewardEvent">CreateRewardEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>reward_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 Object ID of the Reward
</dd>
<dt>
<code>lvl: u64</code>
</dt>
<dd>
 Lvl of the Reward
</dd>
<dt>
<code>description: <a href="_String">string::String</a></code>
</dt>
<dd>
 Description of the Reward
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x0_reward_store_INITIAL_XP"></a>



<pre><code><b>const</b> <a href="reward_store.md#0x0_reward_store_INITIAL_XP">INITIAL_XP</a>: u64 = 0;
</code></pre>



<a name="0x0_reward_store_BASIC_REWARD_XP"></a>



<pre><code><b>const</b> <a href="reward_store.md#0x0_reward_store_BASIC_REWARD_XP">BASIC_REWARD_XP</a>: u64 = 5;
</code></pre>



<a name="0x0_reward_store_EAlreadyClaimed"></a>



<pre><code><b>const</b> <a href="reward_store.md#0x0_reward_store_EAlreadyClaimed">EAlreadyClaimed</a>: u64 = 2;
</code></pre>



<a name="0x0_reward_store_EInvalidSupply"></a>



<pre><code><b>const</b> <a href="reward_store.md#0x0_reward_store_EInvalidSupply">EInvalidSupply</a>: u64 = 0;
</code></pre>



<a name="0x0_reward_store_ERewardPoolExceeded"></a>



<pre><code><b>const</b> <a href="reward_store.md#0x0_reward_store_ERewardPoolExceeded">ERewardPoolExceeded</a>: u64 = 1;
</code></pre>



<a name="0x0_reward_store_REWARD_RECIPIENTS_KEY"></a>



<pre><code><b>const</b> <a href="reward_store.md#0x0_reward_store_REWARD_RECIPIENTS_KEY">REWARD_RECIPIENTS_KEY</a>: <a href="">vector</a>&lt;u8&gt; = [114, 101, 119, 97, 114, 100, 95, 114, 101, 99, 105, 112, 105, 101, 110, 116, 115];
</code></pre>



<a name="0x0_reward_store_empty"></a>

## Function `empty`


Creates a new Reward Store.
It represents a map of rewards, where the key is the level of the reward.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="reward_store.md#0x0_reward_store_empty">empty</a>(): <a href="_VecMap">vec_map::VecMap</a>&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="reward_store.md#0x0_reward_store_empty">empty</a>(): VecMap&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">Reward</a>&gt; {
    <a href="_empty">vec_map::empty</a>&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">Reward</a>&gt;()
}
</code></pre>



</details>

<a name="0x0_reward_store_add_reward"></a>

## Function `add_reward`


Adds a new reward to the store.
It creates a new Reward struct and adds it to the store.
It also creates a new table for the current reward recipients.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="reward_store.md#0x0_reward_store_add_reward">add_reward</a>(store: &<b>mut</b> <a href="_VecMap">vec_map::VecMap</a>&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>&gt;, level: u64, description: <a href="">vector</a>&lt;u8&gt;, coins: <a href="">vector</a>&lt;<a href="_Coin">coin::Coin</a>&lt;<a href="_SUI">sui::SUI</a>&gt;&gt;, reward_pool: u64, reward_supply: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="reward_store.md#0x0_reward_store_add_reward">add_reward</a>(
    store: &<b>mut</b> VecMap&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">Reward</a>&gt;,
    level: u64,
    description: <a href="">vector</a>&lt;u8&gt;,
    coins: <a href="">vector</a>&lt;Coin&lt;SUI&gt;&gt;,
    reward_pool: u64,
    reward_supply: u64,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> <a href="">coin</a> = <a href="_pop_back">vector::pop_back</a>(&<b>mut</b> coins);
    <a href="_join_vec">pay::join_vec</a>(&<b>mut</b> <a href="">coin</a>, coins);
    <b>let</b> received_coin = <a href="_split">coin::split</a>(&<b>mut</b> <a href="">coin</a>, reward_pool, ctx);

    <b>if</b> (<a href="_value">coin::value</a>(&<a href="">coin</a>) == 0) {
        <a href="_destroy_zero">coin::destroy_zero</a>(<a href="">coin</a>);
    } <b>else</b> {
        <a href="_keep">pay::keep</a>(<a href="">coin</a>, ctx);
    };

    <b>let</b> <a href="">balance</a> = <a href="_into_balance">coin::into_balance</a>(received_coin);
    <b>let</b> balance_val = <a href="_value">balance::value</a>(&<a href="">balance</a>);
    <b>assert</b>!(balance_val % reward_supply == 0, <a href="reward_store.md#0x0_reward_store_EInvalidSupply">EInvalidSupply</a>);

    <b>let</b> reward = <a href="reward_store.md#0x0_reward_store_Reward">Reward</a> {
        id: <a href="_new">object::new</a>(ctx),
        level,
        description: <a href="_utf8">string::utf8</a>(description),
        reward_pool: <a href="">balance</a>,
        reward_supply,
        reward_per_user: balance_val / reward_supply,
    };

    emit(<a href="reward_store.md#0x0_reward_store_CreateRewardEvent">CreateRewardEvent</a> {
        reward_id: <a href="_id">object::id</a>(&reward),
        lvl: reward.level,
        description: reward.description,
    });

    dof::add(&<b>mut</b> reward.id, <a href="reward_store.md#0x0_reward_store_REWARD_RECIPIENTS_KEY">REWARD_RECIPIENTS_KEY</a>, <a href="_new">table::new</a>&lt;<b>address</b>, bool&gt;(ctx));
    <a href="_insert">vec_map::insert</a>(store, level, reward);
}
</code></pre>



</details>

<a name="0x0_reward_store_remove_reward"></a>

## Function `remove_reward`


Removes a reward from the store.
It removes the reward from the store and transfers the reward pool to the sender.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="reward_store.md#0x0_reward_store_remove_reward">remove_reward</a>(store: &<b>mut</b> <a href="_VecMap">vec_map::VecMap</a>&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>&gt;, level: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="reward_store.md#0x0_reward_store_remove_reward">remove_reward</a>(store: &<b>mut</b> VecMap&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">Reward</a>&gt;, level: u64, ctx: &<b>mut</b> TxContext) {
    <b>let</b> (_, reward) = <a href="_remove">vec_map::remove</a>(store, &level);

    <b>let</b> sui_amt = <a href="_value">balance::value</a>(&reward.reward_pool);
    <a href="_transfer">transfer::transfer</a>(
        <a href="_take">coin::take</a>(&<b>mut</b> reward.reward_pool, sui_amt, ctx),
        <a href="_sender">tx_context::sender</a>(ctx)
    );

    <a href="reward_store.md#0x0_reward_store_delete_reward">delete_reward</a>(reward);
}
</code></pre>



</details>

<a name="0x0_reward_store_claim_reward"></a>

## Function `claim_reward`


Claims a reward.
It checks if the reward has already been claimed by the sender.
It checks if the reward pool has enough funds.
It transfers the reward to the sender and sets the reward as claimed.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="reward_store.md#0x0_reward_store_claim_reward">claim_reward</a>(reward: &<b>mut</b> <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="reward_store.md#0x0_reward_store_claim_reward">claim_reward</a>(
    reward: &<b>mut</b> <a href="reward_store.md#0x0_reward_store_Reward">Reward</a>,
    ctx: &<b>mut</b> TxContext
) {
    <a href="reward_store.md#0x0_reward_store_check_claimed">check_claimed</a>(reward, ctx);

    <b>let</b> pool_amt = <a href="_value">balance::value</a>(&reward.reward_pool);
    <b>assert</b>!(pool_amt &gt;= reward.reward_per_user, <a href="reward_store.md#0x0_reward_store_ERewardPoolExceeded">ERewardPoolExceeded</a>);

    <a href="reward_store.md#0x0_reward_store_set_reward_claimed">set_reward_claimed</a>(reward, ctx);

    <a href="_transfer">transfer::transfer</a>(
        <a href="_take">coin::take</a>(&<b>mut</b> reward.reward_pool, reward.reward_per_user, ctx),
        <a href="_sender">tx_context::sender</a>(ctx)
    );
}
</code></pre>



</details>

<a name="0x0_reward_store_set_reward_claimed"></a>

## Function `set_reward_claimed`


Sets the reward as claimed by the sender.
It adds the sender to the reward recipients table.



<pre><code><b>fun</b> <a href="reward_store.md#0x0_reward_store_set_reward_claimed">set_reward_claimed</a>(reward: &<b>mut</b> <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="reward_store.md#0x0_reward_store_set_reward_claimed">set_reward_claimed</a>(reward: &<b>mut</b> <a href="reward_store.md#0x0_reward_store_Reward">Reward</a>, ctx: &<b>mut</b> TxContext) {
    <a href="_add">table::add</a>&lt;<b>address</b>, bool&gt;(
        dof::borrow_mut(&<b>mut</b> reward.id, <a href="reward_store.md#0x0_reward_store_REWARD_RECIPIENTS_KEY">REWARD_RECIPIENTS_KEY</a>),
        <a href="_sender">tx_context::sender</a>(ctx),
        <b>true</b>
    );
}
</code></pre>



</details>

<a name="0x0_reward_store_check_claimed"></a>

## Function `check_claimed`


Checks if the reward has already been claimed by the sender.



<pre><code><b>fun</b> <a href="reward_store.md#0x0_reward_store_check_claimed">check_claimed</a>(reward: &<a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="reward_store.md#0x0_reward_store_check_claimed">check_claimed</a>(reward: &<a href="reward_store.md#0x0_reward_store_Reward">Reward</a>, ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(
        !<a href="_contains">table::contains</a>&lt;<b>address</b>, bool&gt;(
            dof::borrow(&reward.id, <a href="reward_store.md#0x0_reward_store_REWARD_RECIPIENTS_KEY">REWARD_RECIPIENTS_KEY</a>),
            <a href="_sender">tx_context::sender</a>(ctx)
        ),
        <a href="reward_store.md#0x0_reward_store_EAlreadyClaimed">EAlreadyClaimed</a>
    );
}
</code></pre>



</details>

<a name="0x0_reward_store_delete_reward"></a>

## Function `delete_reward`


Deletes a reward.
It destroys the reward pool and deletes the reward.



<pre><code><b>fun</b> <a href="reward_store.md#0x0_reward_store_delete_reward">delete_reward</a>(reward: <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="reward_store.md#0x0_reward_store_delete_reward">delete_reward</a>(reward: <a href="reward_store.md#0x0_reward_store_Reward">Reward</a>) {
    <b>let</b> <a href="reward_store.md#0x0_reward_store_Reward">Reward</a> {
        id,
        description: _,
        level: _,
        reward_pool,
        reward_supply: _,
        reward_per_user: _,
    } = reward;
    <a href="_destroy_zero">balance::destroy_zero</a>(reward_pool);
    <a href="_delete">object::delete</a>(id);
}
</code></pre>



</details>
