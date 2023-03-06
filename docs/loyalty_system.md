
<a name="0x0_loyalty_system"></a>

# Module `0x0::loyalty_system`


Loyalty System Module.
This module contains the implementation of the Loyalty System.
Module for creating and managing loyalty systems by the admin and verifying tasks by the verifier.


-  [Resource `AdminCap`](#0x0_loyalty_system_AdminCap)
-  [Resource `VerifierCap`](#0x0_loyalty_system_VerifierCap)
-  [Resource `LoyaltySystem`](#0x0_loyalty_system_LoyaltySystem)
-  [Struct `CreateLoyaltySystemEvent`](#0x0_loyalty_system_CreateLoyaltySystemEvent)
-  [Constants](#@Constants_0)
-  [Function `init`](#0x0_loyalty_system_init)
-  [Function `create_loyalty_system`](#0x0_loyalty_system_create_loyalty_system)
-  [Function `update_name`](#0x0_loyalty_system_update_name)
-  [Function `update_description`](#0x0_loyalty_system_update_description)
-  [Function `update_url`](#0x0_loyalty_system_update_url)
-  [Function `update_max_supply`](#0x0_loyalty_system_update_max_supply)
-  [Function `add_reward`](#0x0_loyalty_system_add_reward)
-  [Function `remove_reward`](#0x0_loyalty_system_remove_reward)
-  [Function `add_task`](#0x0_loyalty_system_add_task)
-  [Function `remove_task`](#0x0_loyalty_system_remove_task)
-  [Function `finish_task`](#0x0_loyalty_system_finish_task)
-  [Function `get_mut_user_store`](#0x0_loyalty_system_get_mut_user_store)
-  [Function `get_mut_tasks`](#0x0_loyalty_system_get_mut_tasks)
-  [Function `get_mut_reward`](#0x0_loyalty_system_get_mut_reward)
-  [Function `increment_total_minted`](#0x0_loyalty_system_increment_total_minted)
-  [Function `get_name`](#0x0_loyalty_system_get_name)
-  [Function `get_max_supply`](#0x0_loyalty_system_get_max_supply)
-  [Function `get_total_minted`](#0x0_loyalty_system_get_total_minted)
-  [Function `get_description`](#0x0_loyalty_system_get_description)
-  [Function `get_url`](#0x0_loyalty_system_get_url)
-  [Function `get_user_store`](#0x0_loyalty_system_get_user_store)
-  [Function `get_user`](#0x0_loyalty_system_get_user)
-  [Function `get_max_lvl`](#0x0_loyalty_system_get_max_lvl)
-  [Function `get_tasks`](#0x0_loyalty_system_get_tasks)
-  [Function `get_rewards`](#0x0_loyalty_system_get_rewards)
-  [Function `check_admin`](#0x0_loyalty_system_check_admin)


<pre><code><b>use</b> <a href="reward_store.md#0x0_reward_store">0x0::reward_store</a>;
<b>use</b> <a href="system_store.md#0x0_system_store">0x0::system_store</a>;
<b>use</b> <a href="task_store.md#0x0_task_store">0x0::task_store</a>;
<b>use</b> <a href="user_store.md#0x0_user_store">0x0::user_store</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::dynamic_object_field</a>;
<b>use</b> <a href="">0x2::event</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::sui</a>;
<b>use</b> <a href="">0x2::table</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x2::url</a>;
<b>use</b> <a href="">0x2::vec_map</a>;
</code></pre>



<a name="0x0_loyalty_system_AdminCap"></a>

## Resource `AdminCap`


Admin capability to manage the loyalty system.
Created separately for each system.



<pre><code><b>struct</b> <a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a> <b>has</b> store, key
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
<code><a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_loyalty_system_VerifierCap"></a>

## Resource `VerifierCap`


Verifier capability to finish tasks.
Created once per package.



<pre><code><b>struct</b> <a href="loyalty_system.md#0x0_loyalty_system_VerifierCap">VerifierCap</a> <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_UID">object::UID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_loyalty_system_LoyaltySystem"></a>

## Resource `LoyaltySystem`


Loyalty system struct.
Contains all the information about the loyalty system.
Contains the user store in the dynamic field.



<pre><code><b>struct</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a> <b>has</b> key
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
<code>name: <a href="_String">string::String</a></code>
</dt>
<dd>
 Loyalty system name
</dd>
<dt>
<code>description: <a href="_String">string::String</a></code>
</dt>
<dd>
 Loyalty system description
</dd>
<dt>
<code>total_minted: u64</code>
</dt>
<dd>
 Total number of NFTs that have been issued.
</dd>
<dt>
<code>max_supply: u64</code>
</dt>
<dd>
 Loyalty NFTs total max supply
</dd>
<dt>
<code><a href="">url</a>: <a href="_Url">url::Url</a></code>
</dt>
<dd>
 Loyalty system image url
</dd>
<dt>
<code>creator: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>max_lvl: u64</code>
</dt>
<dd>
 Max level of the loyalty NFTs
</dd>
<dt>
<code>tasks: <a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="task_store.md#0x0_task_store_Task">task_store::Task</a>&gt;</code>
</dt>
<dd>
 Tasks of the loyalty system task_ID -> Task
</dd>
<dt>
<code>rewards: <a href="_VecMap">vec_map::VecMap</a>&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>&gt;</code>
</dt>
<dd>
 Rewards of the loyalty system reward_lvl -> Reward
</dd>
</dl>


</details>

<a name="0x0_loyalty_system_CreateLoyaltySystemEvent"></a>

## Struct `CreateLoyaltySystemEvent`



<pre><code><b>struct</b> <a href="loyalty_system.md#0x0_loyalty_system_CreateLoyaltySystemEvent">CreateLoyaltySystemEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>object_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 The Object ID of the NFT
</dd>
<dt>
<code>admin_cap: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 To control the access to the admin functions
</dd>
<dt>
<code>creator: <b>address</b></code>
</dt>
<dd>
 The creator of LS
</dd>
<dt>
<code>name: <a href="_String">string::String</a></code>
</dt>
<dd>
 The name of the NFT
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x0_loyalty_system_ADMIN_CAP_URL"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_ADMIN_CAP_URL">ADMIN_CAP_URL</a>: <a href="">vector</a>&lt;u8&gt; = [105, 112, 102, 115, 58, 47, 47, 98, 97, 102, 121, 98, 101, 105, 97, 55, 119, 99, 106, 101, 117, 109, 122, 104, 121, 105, 122, 113, 111, 103, 101, 111, 110, 55, 117, 114, 106, 100, 103, 108, 108, 53, 122, 112, 109, 115, 51, 115, 99, 107, 118, 102, 118, 54, 116, 117, 116, 55, 55, 105, 51, 107, 110, 101, 114, 117, 47, 70, 97, 118, 105, 99, 111, 110, 46, 112, 110, 103];
</code></pre>



<a name="0x0_loyalty_system_BASIC_MAX_LVL"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_BASIC_MAX_LVL">BASIC_MAX_LVL</a>: u64 = 100;
</code></pre>



<a name="0x0_loyalty_system_EAdminOnly"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_EAdminOnly">EAdminOnly</a>: u64 = 0;
</code></pre>



<a name="0x0_loyalty_system_EInvalidLevel"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_EInvalidLevel">EInvalidLevel</a>: u64 = 2;
</code></pre>



<a name="0x0_loyalty_system_EMaxSupplyReached"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_EMaxSupplyReached">EMaxSupplyReached</a>: u64 = 3;
</code></pre>



<a name="0x0_loyalty_system_ETextOverflow"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_ETextOverflow">ETextOverflow</a>: u64 = 1;
</code></pre>



<a name="0x0_loyalty_system_MAX_DESCRIPTION_LENGTH"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_MAX_DESCRIPTION_LENGTH">MAX_DESCRIPTION_LENGTH</a>: u64 = 255;
</code></pre>



<a name="0x0_loyalty_system_MAX_NAME_LENGTH"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_MAX_NAME_LENGTH">MAX_NAME_LENGTH</a>: u64 = 32;
</code></pre>



<a name="0x0_loyalty_system_USER_STORE_KEY"></a>



<pre><code><b>const</b> <a href="loyalty_system.md#0x0_loyalty_system_USER_STORE_KEY">USER_STORE_KEY</a>: <a href="">vector</a>&lt;u8&gt; = [117, 115, 101, 114, 95, 115, 116, 111, 114, 101];
</code></pre>



<a name="0x0_loyalty_system_init"></a>

## Function `init`

Transfer to publisher VerifierCap


<pre><code><b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_init">init</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_init">init</a>(ctx: &<b>mut</b> TxContext) {
    <a href="_transfer">transfer::transfer</a>(<a href="loyalty_system.md#0x0_loyalty_system_VerifierCap">VerifierCap</a> {
        id: <a href="_new">object::new</a>(ctx)
    }, <a href="_sender">tx_context::sender</a>(ctx))
}
</code></pre>



</details>

<a name="0x0_loyalty_system_create_loyalty_system"></a>

## Function `create_loyalty_system`


Create a new loyalty system.
Transfer to the creator AdminCap.
The creator of the system will be the admin of the system.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_create_loyalty_system">create_loyalty_system</a>(name: <a href="">vector</a>&lt;u8&gt;, description: <a href="">vector</a>&lt;u8&gt;, <a href="">url</a>: <a href="">vector</a>&lt;u8&gt;, max_supply: u64, max_lvl: u64, <a href="system_store.md#0x0_system_store">system_store</a>: &<b>mut</b> <a href="system_store.md#0x0_system_store_SystemStore">system_store::SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">system_store::SYSTEM_STORE</a>&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_create_loyalty_system">create_loyalty_system</a>(
    name: <a href="">vector</a>&lt;u8&gt;,
    description: <a href="">vector</a>&lt;u8&gt;,
    <a href="">url</a>: <a href="">vector</a>&lt;u8&gt;,
    max_supply: u64,
    max_lvl: u64,
    <a href="system_store.md#0x0_system_store">system_store</a>: &<b>mut</b> SystemStore&lt;SYSTEM_STORE&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>assert</b>!(length(&name) &lt;= <a href="loyalty_system.md#0x0_loyalty_system_MAX_NAME_LENGTH">MAX_NAME_LENGTH</a>, <a href="loyalty_system.md#0x0_loyalty_system_ETextOverflow">ETextOverflow</a>);
    <b>assert</b>!(length(&description) &lt;= <a href="loyalty_system.md#0x0_loyalty_system_MAX_DESCRIPTION_LENGTH">MAX_DESCRIPTION_LENGTH</a>, <a href="loyalty_system.md#0x0_loyalty_system_ETextOverflow">ETextOverflow</a>);
    <b>assert</b>!(max_lvl &lt;= <a href="loyalty_system.md#0x0_loyalty_system_BASIC_MAX_LVL">BASIC_MAX_LVL</a>, <a href="loyalty_system.md#0x0_loyalty_system_EInvalidLevel">EInvalidLevel</a>);

    <b>let</b> creator = <a href="_sender">tx_context::sender</a>(ctx);

    <b>let</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a> = <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a> {
        id: <a href="_new">object::new</a>(ctx),
        name: <a href="_utf8">string::utf8</a>(name),
        description: <a href="_utf8">string::utf8</a>(description),
        <a href="">url</a>: <a href="_new_unsafe_from_bytes">url::new_unsafe_from_bytes</a>(<a href="">url</a>),
        total_minted: 0,
        max_supply,
        creator,
        max_lvl,
        tasks: <a href="task_store.md#0x0_task_store_empty">task_store::empty</a>(),
        rewards: <a href="reward_store.md#0x0_reward_store_empty">reward_store::empty</a>(),
    };
    dof::add(&<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.id, <a href="loyalty_system.md#0x0_loyalty_system_USER_STORE_KEY">USER_STORE_KEY</a>, <a href="user_store.md#0x0_user_store_new">user_store::new</a>(ctx));

    <b>let</b> admin_cap = <a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a> {
        id: <a href="_new">object::new</a>(ctx),
        name: <a href="_utf8">string::utf8</a>(b"Admin Cap"),
        description: <a href="_utf8">string::utf8</a>(b"Allows <b>to</b> manage the loyalty system"),
        <a href="">url</a>: <a href="_new_unsafe_from_bytes">url::new_unsafe_from_bytes</a>(<a href="loyalty_system.md#0x0_loyalty_system_ADMIN_CAP_URL">ADMIN_CAP_URL</a>),
        <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: <a href="_uid_to_inner">object::uid_to_inner</a>(&<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.id),
    };

    emit(<a href="loyalty_system.md#0x0_loyalty_system_CreateLoyaltySystemEvent">CreateLoyaltySystemEvent</a> {
        object_id: <a href="_uid_to_inner">object::uid_to_inner</a>(&<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.id),
        creator,
        name: <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.name,
        admin_cap: <a href="_uid_to_inner">object::uid_to_inner</a>(&admin_cap.id),
    });

    <a href="system_store.md#0x0_system_store_add_system">system_store::add_system</a>(<a href="system_store.md#0x0_system_store">system_store</a>, <a href="_uid_to_inner">object::uid_to_inner</a>(&<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.id), ctx);
    <a href="_share_object">transfer::share_object</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);
    <a href="_transfer">transfer::transfer</a>(admin_cap, creator);
}
</code></pre>



</details>

<a name="0x0_loyalty_system_update_name"></a>

## Function `update_name`



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_update_name">update_name</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, new_name: <a href="">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_update_name">update_name</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>, new_name: <a href="">vector</a>&lt;u8&gt;) {
    <b>assert</b>!(length(&new_name) &lt;= <a href="loyalty_system.md#0x0_loyalty_system_MAX_NAME_LENGTH">MAX_NAME_LENGTH</a>, <a href="loyalty_system.md#0x0_loyalty_system_ETextOverflow">ETextOverflow</a>);
    <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.name = <a href="_utf8">string::utf8</a>(new_name);
}
</code></pre>



</details>

<a name="0x0_loyalty_system_update_description"></a>

## Function `update_description`



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_update_description">update_description</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, new_description: <a href="">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_update_description">update_description</a>(
    admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>,
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>,
    new_description: <a href="">vector</a>&lt;u8&gt;
) {
    <b>assert</b>!(length(&new_description) &lt;= <a href="loyalty_system.md#0x0_loyalty_system_MAX_DESCRIPTION_LENGTH">MAX_DESCRIPTION_LENGTH</a>, <a href="loyalty_system.md#0x0_loyalty_system_ETextOverflow">ETextOverflow</a>);
    <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.description = <a href="_utf8">string::utf8</a>(new_description);
}
</code></pre>



</details>

<a name="0x0_loyalty_system_update_url"></a>

## Function `update_url`



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_update_url">update_url</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, new_url: <a href="">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_update_url">update_url</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>, new_url: <a href="">vector</a>&lt;u8&gt;) {
    <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.<a href="">url</a> = <a href="_new_unsafe_from_bytes">url::new_unsafe_from_bytes</a>(new_url);
}
</code></pre>



</details>

<a name="0x0_loyalty_system_update_max_supply"></a>

## Function `update_max_supply`



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_update_max_supply">update_max_supply</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, new_max_supply: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_update_max_supply">update_max_supply</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>, new_max_supply: u64) {
    <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.max_supply = new_max_supply;
}
</code></pre>



</details>

<a name="0x0_loyalty_system_add_reward"></a>

## Function `add_reward`


Add a new reward to the loyalty system.
Users can claim rewards by reaching a certain level.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_add_reward">add_reward</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, level: u64, description: <a href="">vector</a>&lt;u8&gt;, coins: <a href="">vector</a>&lt;<a href="_Coin">coin::Coin</a>&lt;<a href="_SUI">sui::SUI</a>&gt;&gt;, reward_pool: u64, reward_supply: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_add_reward">add_reward</a>(
    admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>,
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>,
    level: u64,
    description: <a href="">vector</a>&lt;u8&gt;,
    coins: <a href="">vector</a>&lt;Coin&lt;SUI&gt;&gt;,
    reward_pool: u64,
    reward_supply: u64,
    ctx: &<b>mut</b> TxContext
) {
    <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);
    <b>assert</b>!(level &lt;= <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.max_lvl, <a href="loyalty_system.md#0x0_loyalty_system_EInvalidLevel">EInvalidLevel</a>);

    <a href="reward_store.md#0x0_reward_store_add_reward">reward_store::add_reward</a>(
        &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.rewards,
        level,
        description,
        coins,
        reward_pool,
        reward_supply,
        ctx
    );
}
</code></pre>



</details>

<a name="0x0_loyalty_system_remove_reward"></a>

## Function `remove_reward`


Remove a reward from the loyalty system.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_remove_reward">remove_reward</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, level: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_remove_reward">remove_reward</a>(
    admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>,
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>,
    level: u64,
    ctx: &<b>mut</b> TxContext
) {
    <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);

    <a href="reward_store.md#0x0_reward_store_remove_reward">reward_store::remove_reward</a>(&<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.rewards, level, ctx);
}
</code></pre>



</details>

<a name="0x0_loyalty_system_add_task"></a>

## Function `add_task`


Add a new task to the loyalty system.
Users can complete tasks to earn XP.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_add_task">add_task</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, lvl: u64, name: <a href="">vector</a>&lt;u8&gt;, description: <a href="">vector</a>&lt;u8&gt;, reward_xp: u64, completed_supply: u64, package_id: <a href="_ID">object::ID</a>, module_name: <a href="">vector</a>&lt;u8&gt;, function_name: <a href="">vector</a>&lt;u8&gt;, arguments: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_add_task">add_task</a>(
    admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>,
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>,
    lvl: u64,
    name: <a href="">vector</a>&lt;u8&gt;,
    description: <a href="">vector</a>&lt;u8&gt;,
    reward_xp: u64,
    completed_supply: u64,
    package_id: ID,
    module_name: <a href="">vector</a>&lt;u8&gt;,
    function_name: <a href="">vector</a>&lt;u8&gt;,
    arguments: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;,
    ctx: &<b>mut</b> TxContext
) {
    <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);

    <a href="task_store.md#0x0_task_store_add_task">task_store::add_task</a>(
        &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.tasks,
        lvl,
        name,
        description,
        reward_xp,
        <b>if</b> (completed_supply == 0) <a href="_none">option::none</a>&lt;u64&gt;() <b>else</b> <a href="_some">option::some</a>(completed_supply),
        package_id,
        module_name,
        function_name,
        arguments,
        ctx,
    );
}
</code></pre>



</details>

<a name="0x0_loyalty_system_remove_task"></a>

## Function `remove_task`


Remove a task from the loyalty system.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_remove_task">remove_task</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, task_id: <a href="_ID">object::ID</a>, _: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_remove_task">remove_task</a>(
    admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>,
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>,
    task_id: ID,
    _: &<b>mut</b> TxContext
) {
    <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);

    <a href="task_store.md#0x0_task_store_remove_task">task_store::remove_task</a>(&<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.tasks, &task_id);
}
</code></pre>



</details>

<a name="0x0_loyalty_system_finish_task"></a>

## Function `finish_task`


Verifier function to finish a task.
This function is called by publisher.



<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_finish_task">finish_task</a>(_: &<a href="loyalty_system.md#0x0_loyalty_system_VerifierCap">loyalty_system::VerifierCap</a>, <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, task_id: <a href="_ID">object::ID</a>, user: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_finish_task">finish_task</a>(
    _: &<a href="loyalty_system.md#0x0_loyalty_system_VerifierCap">VerifierCap</a>,
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>,
    task_id: ID,
    user: <b>address</b>
) {
    <b>let</b> reward_xp = <a href="task_store.md#0x0_task_store_get_task_reward">task_store::get_task_reward</a>(&<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.tasks, &task_id);
    <b>let</b> <a href="user_store.md#0x0_user_store">user_store</a> = <a href="loyalty_system.md#0x0_loyalty_system_get_mut_user_store">get_mut_user_store</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>);
    <a href="user_store.md#0x0_user_store_finish_task">user_store::finish_task</a>(
        <a href="user_store.md#0x0_user_store">user_store</a>,
        &task_id,
        user,
        reward_xp
    );
    <a href="task_store.md#0x0_task_store_increment_task_completed_count">task_store::increment_task_completed_count</a>(&<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.tasks, &task_id);
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_mut_user_store"></a>

## Function `get_mut_user_store`


Get the mutable user store.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_mut_user_store">get_mut_user_store</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): &<b>mut</b> <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_mut_user_store">get_mut_user_store</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): &<b>mut</b> Table&lt;<b>address</b>, User&gt; {
    dof::borrow_mut(&<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.id, <a href="loyalty_system.md#0x0_loyalty_system_USER_STORE_KEY">USER_STORE_KEY</a>)
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_mut_tasks"></a>

## Function `get_mut_tasks`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_mut_tasks">get_mut_tasks</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): &<b>mut</b> <a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="task_store.md#0x0_task_store_Task">task_store::Task</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_mut_tasks">get_mut_tasks</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): &<b>mut</b> VecMap&lt;ID, Task&gt; {
    &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.tasks
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_mut_reward"></a>

## Function `get_mut_reward`


Get the mutable reward.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_mut_reward">get_mut_reward</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, lvl: u64): &<b>mut</b> <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_mut_reward">get_mut_reward</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>, lvl: u64): &<b>mut</b> Reward {
    <a href="_get_mut">vec_map::get_mut</a>(&<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.rewards, &lvl)
}
</code></pre>



</details>

<a name="0x0_loyalty_system_increment_total_minted"></a>

## Function `increment_total_minted`


Increment the total minted count.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_increment_total_minted">increment_total_minted</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_increment_total_minted">increment_total_minted</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<b>mut</b> <a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>) {
    <b>assert</b>!(<a href="loyalty_system.md#0x0_loyalty_system_get_total_minted">get_total_minted</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>) &lt;= <a href="loyalty_system.md#0x0_loyalty_system_get_max_supply">get_max_supply</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>), <a href="loyalty_system.md#0x0_loyalty_system_EMaxSupplyReached">EMaxSupplyReached</a>);
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.total_minted = <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.total_minted + 1;
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_name"></a>

## Function `get_name`


Get the name of the loyalty system.



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_name">get_name</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): &<a href="_String">string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_name">get_name</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): &<a href="_String">string::String</a> {
    &<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.name
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_max_supply"></a>

## Function `get_max_supply`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_max_supply">get_max_supply</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_max_supply">get_max_supply</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): u64 {
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.max_supply
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_total_minted"></a>

## Function `get_total_minted`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_total_minted">get_total_minted</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_total_minted">get_total_minted</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): u64 {
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.total_minted
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_description"></a>

## Function `get_description`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_description">get_description</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): &<a href="_String">string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_description">get_description</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): &<a href="_String">string::String</a> {
    &<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.description
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_url"></a>

## Function `get_url`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_url">get_url</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): &<a href="_Url">url::Url</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_url">get_url</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): &Url {
    &<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.<a href="">url</a>
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_user_store"></a>

## Function `get_user_store`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_user_store">get_user_store</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): &<a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_user_store">get_user_store</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): &Table&lt;<b>address</b>, User&gt; {
    dof::borrow(&<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.id, <a href="loyalty_system.md#0x0_loyalty_system_USER_STORE_KEY">USER_STORE_KEY</a>)
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_user"></a>

## Function `get_user`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_user">get_user</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>, user: <b>address</b>): &<a href="user_store.md#0x0_user_store_User">user_store::User</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_user">get_user</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>, user: <b>address</b>): &User {
    <a href="user_store.md#0x0_user_store_get_user">user_store::get_user</a>(<a href="loyalty_system.md#0x0_loyalty_system_get_user_store">get_user_store</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>), user)
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_max_lvl"></a>

## Function `get_max_lvl`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_max_lvl">get_max_lvl</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_max_lvl">get_max_lvl</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): u64 {
    <a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.max_lvl
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_tasks"></a>

## Function `get_tasks`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_tasks">get_tasks</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): &<a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="task_store.md#0x0_task_store_Task">task_store::Task</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_tasks">get_tasks</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): &VecMap&lt;ID, Task&gt; {
    &<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.tasks
}
</code></pre>



</details>

<a name="0x0_loyalty_system_get_rewards"></a>

## Function `get_rewards`



<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_rewards">get_rewards</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>): &<a href="_VecMap">vec_map::VecMap</a>&lt;u64, <a href="reward_store.md#0x0_reward_store_Reward">reward_store::Reward</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_get_rewards">get_rewards</a>(<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>): &VecMap&lt;u64, Reward&gt; {
    &<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>.rewards
}
</code></pre>



</details>

<a name="0x0_loyalty_system_check_admin"></a>

## Function `check_admin`



<pre><code><b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">loyalty_system::AdminCap</a>, system: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">loyalty_system::LoyaltySystem</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="loyalty_system.md#0x0_loyalty_system_check_admin">check_admin</a>(admin_cap: &<a href="loyalty_system.md#0x0_loyalty_system_AdminCap">AdminCap</a>, system: &<a href="loyalty_system.md#0x0_loyalty_system_LoyaltySystem">LoyaltySystem</a>) {
    <b>assert</b>!(<a href="_borrow_id">object::borrow_id</a>(system) == &admin_cap.<a href="loyalty_system.md#0x0_loyalty_system">loyalty_system</a>, <a href="loyalty_system.md#0x0_loyalty_system_EAdminOnly">EAdminOnly</a>);
}
</code></pre>



</details>
