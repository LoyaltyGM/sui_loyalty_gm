
<a name="0x0_user_store"></a>

# Module `0x0::user_store`


User Store Module.
This module is responsible for storing user data.
Its functions are only accessible by the friend modules.


-  [Struct `User`](#0x0_user_store_User)
-  [Constants](#@Constants_0)
-  [Function `new`](#0x0_user_store_new)
-  [Function `add_user`](#0x0_user_store_add_user)
-  [Function `update_user_xp`](#0x0_user_store_update_user_xp)
-  [Function `reset_user_xp`](#0x0_user_store_reset_user_xp)
-  [Function `start_task`](#0x0_user_store_start_task)
-  [Function `finish_task`](#0x0_user_store_finish_task)
-  [Function `size`](#0x0_user_store_size)
-  [Function `get_user`](#0x0_user_store_get_user)
-  [Function `user_exists`](#0x0_user_store_user_exists)
-  [Function `get_user_xp`](#0x0_user_store_get_user_xp)


<pre><code><b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::table</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x2::vec_set</a>;
</code></pre>



<a name="0x0_user_store_User"></a>

## Struct `User`


User data.



<pre><code><b>struct</b> <a href="user_store.md#0x0_user_store_User">User</a> <b>has</b> drop, store
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
<code>owner: <b>address</b></code>
</dt>
<dd>
 Address of the user that data belongs to.
</dd>
<dt>
<code>active_tasks: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_ID">object::ID</a>&gt;</code>
</dt>
<dd>
 Tasks that are currently active.
</dd>
<dt>
<code>done_tasks: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_ID">object::ID</a>&gt;</code>
</dt>
<dd>
 Tasks that are already done.
</dd>
<dt>
<code>claimable_xp: u64</code>
</dt>
<dd>
 XP that can be claimed by the user. It is reset to INITIAL_XP after claiming.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x0_user_store_ETaskAlreadyDone"></a>



<pre><code><b>const</b> <a href="user_store.md#0x0_user_store_ETaskAlreadyDone">ETaskAlreadyDone</a>: u64 = 0;
</code></pre>



<a name="0x0_user_store_ETaskNotStarted"></a>



<pre><code><b>const</b> <a href="user_store.md#0x0_user_store_ETaskNotStarted">ETaskNotStarted</a>: u64 = 1;
</code></pre>



<a name="0x0_user_store_INITIAL_XP"></a>



<pre><code><b>const</b> <a href="user_store.md#0x0_user_store_INITIAL_XP">INITIAL_XP</a>: u64 = 0;
</code></pre>



<a name="0x0_user_store_new"></a>

## Function `new`


Create a new user store.
It represents a table that maps user addresses to user data.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_new">new</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_new">new</a>(ctx: &<b>mut</b> TxContext): Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt; {
    <a href="_new">table::new</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;(ctx)
}
</code></pre>



</details>

<a name="0x0_user_store_add_user"></a>

## Function `add_user`


Add a new user to the store.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_add_user">add_user</a>(store: &<b>mut</b> <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;, token_id: &<a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_add_user">add_user</a>(
    store: &<b>mut</b> Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;,
    token_id: &ID,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> owner = <a href="_sender">tx_context::sender</a>(ctx);
    <b>let</b> data = <a href="user_store.md#0x0_user_store_User">User</a> {
        token_id: *token_id,
        active_tasks: <a href="_empty">vec_set::empty</a>(),
        done_tasks: <a href="_empty">vec_set::empty</a>(),
        owner,
        claimable_xp: <a href="user_store.md#0x0_user_store_INITIAL_XP">INITIAL_XP</a>,
    };

    <a href="_add">table::add</a>(store, owner, data)
}
</code></pre>



</details>

<a name="0x0_user_store_update_user_xp"></a>

## Function `update_user_xp`


Update the user's XP.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_update_user_xp">update_user_xp</a>(store: &<b>mut</b> <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;, owner: <b>address</b>, reward_xp: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_update_user_xp">update_user_xp</a>(
    store: &<b>mut</b> Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;,
    owner: <b>address</b>,
    reward_xp: u64
) {
    <b>let</b> user_data = <a href="_borrow_mut">table::borrow_mut</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;(store, owner);
    user_data.claimable_xp = user_data.claimable_xp + reward_xp;
}
</code></pre>



</details>

<a name="0x0_user_store_reset_user_xp"></a>

## Function `reset_user_xp`


Reset the user's XP to INITIAL_XP.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_reset_user_xp">reset_user_xp</a>(store: &<b>mut</b> <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;, owner: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_reset_user_xp">reset_user_xp</a>(store: &<b>mut</b> Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;, owner: <b>address</b>) {
    <b>let</b> user_data = <a href="_borrow_mut">table::borrow_mut</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;(store, owner);
    user_data.claimable_xp = <a href="user_store.md#0x0_user_store_INITIAL_XP">INITIAL_XP</a>;
}
</code></pre>



</details>

<a name="0x0_user_store_start_task"></a>

## Function `start_task`


Start a task with the given ID for the user.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_start_task">start_task</a>(store: &<b>mut</b> <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;, task_id: &<a href="_ID">object::ID</a>, owner: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_start_task">start_task</a>(store: &<b>mut</b> Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;, task_id: &ID, owner: <b>address</b>) {
    <b>let</b> user_data = <a href="_borrow_mut">table::borrow_mut</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;(store, owner);
    <b>assert</b>!(!<a href="_contains">vec_set::contains</a>(&user_data.done_tasks, task_id), <a href="user_store.md#0x0_user_store_ETaskAlreadyDone">ETaskAlreadyDone</a>);
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> user_data.active_tasks, *task_id)
}
</code></pre>



</details>

<a name="0x0_user_store_finish_task"></a>

## Function `finish_task`


Finish a task with the given ID for the user.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_finish_task">finish_task</a>(store: &<b>mut</b> <a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;, task_id: &<a href="_ID">object::ID</a>, owner: <b>address</b>, reward_xp: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="user_store.md#0x0_user_store_finish_task">finish_task</a>(
    store: &<b>mut</b> Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;,
    task_id: &ID,
    owner: <b>address</b>,
    reward_xp: u64
) {
    <b>let</b> user_data = <a href="_borrow_mut">table::borrow_mut</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;(store, owner);

    <b>assert</b>!(!<a href="_contains">vec_set::contains</a>(&user_data.done_tasks, task_id), <a href="user_store.md#0x0_user_store_ETaskAlreadyDone">ETaskAlreadyDone</a>);
    <b>assert</b>!(<a href="_contains">vec_set::contains</a>(&user_data.active_tasks, task_id), <a href="user_store.md#0x0_user_store_ETaskNotStarted">ETaskNotStarted</a>);

    <a href="_remove">vec_set::remove</a>(&<b>mut</b> user_data.active_tasks, task_id);
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> user_data.done_tasks, *task_id);

    <a href="user_store.md#0x0_user_store_update_user_xp">update_user_xp</a>(store, owner, reward_xp)
}
</code></pre>



</details>

<a name="0x0_user_store_size"></a>

## Function `size`


Get the size of the user store.



<pre><code><b>public</b> <b>fun</b> <a href="user_store.md#0x0_user_store_size">size</a>(store: &<a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user_store.md#0x0_user_store_size">size</a>(store: &Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;): u64 {
    <a href="_length">table::length</a>(store)
}
</code></pre>



</details>

<a name="0x0_user_store_get_user"></a>

## Function `get_user`


Get the user data for the given address.



<pre><code><b>public</b> <b>fun</b> <a href="user_store.md#0x0_user_store_get_user">get_user</a>(store: &<a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;, owner: <b>address</b>): &<a href="user_store.md#0x0_user_store_User">user_store::User</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user_store.md#0x0_user_store_get_user">get_user</a>(store: &Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;, owner: <b>address</b>): &<a href="user_store.md#0x0_user_store_User">User</a> {
    <a href="_borrow">table::borrow</a>(store, owner)
}
</code></pre>



</details>

<a name="0x0_user_store_user_exists"></a>

## Function `user_exists`


Check if the user exists in the store.



<pre><code><b>public</b> <b>fun</b> <a href="user_store.md#0x0_user_store_user_exists">user_exists</a>(<a href="">table</a>: &<a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;, owner: <b>address</b>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user_store.md#0x0_user_store_user_exists">user_exists</a>(<a href="">table</a>: &Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;, owner: <b>address</b>): bool {
    <a href="_contains">table::contains</a>(<a href="">table</a>, owner)
}
</code></pre>



</details>

<a name="0x0_user_store_get_user_xp"></a>

## Function `get_user_xp`


Get the user's claimable XP.



<pre><code><b>public</b> <b>fun</b> <a href="user_store.md#0x0_user_store_get_user_xp">get_user_xp</a>(<a href="">table</a>: &<a href="_Table">table::Table</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">user_store::User</a>&gt;, owner: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="user_store.md#0x0_user_store_get_user_xp">get_user_xp</a>(<a href="">table</a>: &Table&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;, owner: <b>address</b>): u64 {
    <b>let</b> user_data = <a href="_borrow">table::borrow</a>&lt;<b>address</b>, <a href="user_store.md#0x0_user_store_User">User</a>&gt;(<a href="">table</a>, owner);
    user_data.claimable_xp
}
</code></pre>



</details>
