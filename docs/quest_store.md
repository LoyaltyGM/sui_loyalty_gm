
<a name="0x0_quest_store"></a>

# Module `0x0::quest_store`


Quest Store module.
This module is responsible for storing all the quests in the system.
Its functions are only accessible by the friend modules.


-  [Struct `Quest`](#0x0_quest_store_Quest)
-  [Struct `CreateQuestEvent`](#0x0_quest_store_CreateQuestEvent)
-  [Constants](#@Constants_0)
-  [Function `empty`](#0x0_quest_store_empty)
-  [Function `add_quest`](#0x0_quest_store_add_quest)
-  [Function `remove_quest`](#0x0_quest_store_remove_quest)
-  [Function `increment_quest_started_count`](#0x0_quest_store_increment_quest_started_count)
-  [Function `increment_quest_completed_count`](#0x0_quest_store_increment_quest_completed_count)
-  [Function `get_quest`](#0x0_quest_store_get_quest)
-  [Function `get_quest_lvl`](#0x0_quest_store_get_quest_lvl)
-  [Function `get_quest_reward`](#0x0_quest_store_get_quest_reward)
-  [Function `get_mut_quest`](#0x0_quest_store_get_mut_quest)
-  [Function `to_string_vec`](#0x0_quest_store_to_string_vec)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x2::event</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x2::vec_map</a>;
</code></pre>



<a name="0x0_quest_store_Quest"></a>

## Struct `Quest`


Quest struct.
This struct represents a quest that the user can complete.
The quest is represented by a function that needs to be executed.
Quest can be completed only once by the user.



<pre><code><b>struct</b> <a href="quest_store.md#0x0_quest_store_Quest">Quest</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>name: <a href="_String">string::String</a></code>
</dt>
<dd>
 The name of the quest
</dd>
<dt>
<code>description: <a href="_String">string::String</a></code>
</dt>
<dd>
 The description of the quest
</dd>
<dt>
<code>lvl: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 The level required to start the quest
</dd>
<dt>
<code>reward_exp: u64</code>
</dt>
<dd>
 The amount of XP that the user will receive upon completing the quest
</dd>
<dt>
<code>started_count: u64</code>
</dt>
<dd>
 The counter of the number of times the quest has been started
</dd>
<dt>
<code>completed_count: u64</code>
</dt>
<dd>
 The counter of the number of times the quest has been completed
</dd>
<dt>
<code>completed_supply: <a href="_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 The maximum number of times the quest can be completed
</dd>
<dt>
<code>package_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 The ID of the package that contains the function that needs to be executed
</dd>
<dt>
<code>module_name: <a href="_String">string::String</a></code>
</dt>
<dd>
 The name of the module that contains the function that needs to be executed
</dd>
<dt>
<code>function_name: <a href="_String">string::String</a></code>
</dt>
<dd>
 The name of the function that needs to be executed
</dd>
<dt>
<code>arguments: <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;</code>
</dt>
<dd>
 The arguments that need to be passed to the function
</dd>
</dl>


</details>

<a name="0x0_quest_store_CreateQuestEvent"></a>

## Struct `CreateQuestEvent`



<pre><code><b>struct</b> <a href="quest_store.md#0x0_quest_store_CreateQuestEvent">CreateQuestEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>quest_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 Object ID of the Quest
</dd>
<dt>
<code>name: <a href="_String">string::String</a></code>
</dt>
<dd>
 Name of the Quest
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x0_quest_store_INITIAL_XP"></a>



<pre><code><b>const</b> <a href="quest_store.md#0x0_quest_store_INITIAL_XP">INITIAL_XP</a>: u64 = 0;
</code></pre>



<a name="0x0_quest_store_BASIC_REWARD_XP"></a>



<pre><code><b>const</b> <a href="quest_store.md#0x0_quest_store_BASIC_REWARD_XP">BASIC_REWARD_XP</a>: u64 = 5;
</code></pre>



<a name="0x0_quest_store_EMaxQuestsReached"></a>



<pre><code><b>const</b> <a href="quest_store.md#0x0_quest_store_EMaxQuestsReached">EMaxQuestsReached</a>: u64 = 0;
</code></pre>



<a name="0x0_quest_store_EQuestCompletedSupplyReached"></a>



<pre><code><b>const</b> <a href="quest_store.md#0x0_quest_store_EQuestCompletedSupplyReached">EQuestCompletedSupplyReached</a>: u64 = 1;
</code></pre>



<a name="0x0_quest_store_MAX_QUESTS"></a>



<pre><code><b>const</b> <a href="quest_store.md#0x0_quest_store_MAX_QUESTS">MAX_QUESTS</a>: u64 = 100;
</code></pre>



<a name="0x0_quest_store_empty"></a>

## Function `empty`


Creates a new empty quest store.
Store represents a map of quest IDs to quests.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_empty">empty</a>(): <a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_empty">empty</a>(): VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt; {
    <a href="_empty">vec_map::empty</a>&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;()
}
</code></pre>



</details>

<a name="0x0_quest_store_add_quest"></a>

## Function `add_quest`


Creates a new quest and adds it to the store.
The quest is represented by a function that needs to be executed.
The function is identified by the package ID, module name and function name.
The arguments are the arguments that need to be passed to the function.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_add_quest">add_quest</a>(store: &<b>mut</b> <a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;, lvl: u64, name: <a href="">vector</a>&lt;u8&gt;, description: <a href="">vector</a>&lt;u8&gt;, reward_exp: u64, completed_supply: <a href="_Option">option::Option</a>&lt;u64&gt;, package_id: <a href="_ID">object::ID</a>, module_name: <a href="">vector</a>&lt;u8&gt;, function_name: <a href="">vector</a>&lt;u8&gt;, arguments: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_add_quest">add_quest</a>(
    store: &<b>mut</b> VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;,
    lvl: u64,
    name: <a href="">vector</a>&lt;u8&gt;,
    description: <a href="">vector</a>&lt;u8&gt;,
    reward_exp: u64,
    completed_supply: Option&lt;u64&gt;,
    package_id: ID,
    module_name: <a href="">vector</a>&lt;u8&gt;,
    function_name: <a href="">vector</a>&lt;u8&gt;,
    arguments: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;,
    ctx: &<b>mut</b> TxContext
) {
    <b>assert</b>!(<a href="_size">vec_map::size</a>(store) &lt;= <a href="quest_store.md#0x0_quest_store_MAX_QUESTS">MAX_QUESTS</a>, <a href="quest_store.md#0x0_quest_store_EMaxQuestsReached">EMaxQuestsReached</a>);

    <b>let</b> uid = <a href="_new">object::new</a>(ctx);
    <b>let</b> id = <a href="_uid_to_inner">object::uid_to_inner</a>(&uid);
    <a href="_delete">object::delete</a>(uid);

    <b>let</b> quest = <a href="quest_store.md#0x0_quest_store_Quest">Quest</a> {
        id,
        name: <a href="_utf8">string::utf8</a>(name),
        description: <a href="_utf8">string::utf8</a>(description),
        lvl: <b>if</b> (lvl == 0)  <a href="_none">option::none</a>&lt;u64&gt;() <b>else</b> <a href="_some">option::some</a>(lvl),
        reward_exp,
        completed_supply,
        started_count: 0,
        completed_count: 0,
        package_id,
        module_name: <a href="_utf8">string::utf8</a>(module_name),
        function_name: <a href="_utf8">string::utf8</a>(function_name),
        arguments: <a href="quest_store.md#0x0_quest_store_to_string_vec">to_string_vec</a>(arguments),
    };

    emit(<a href="quest_store.md#0x0_quest_store_CreateQuestEvent">CreateQuestEvent</a> {
        quest_id: id,
        name: quest.name,
    });

    <a href="_insert">vec_map::insert</a>(store, id, quest);
}
</code></pre>



</details>

<a name="0x0_quest_store_remove_quest"></a>

## Function `remove_quest`


Removes a quest from the store.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_remove_quest">remove_quest</a>(store: &<b>mut</b> <a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;, quest_id: &<a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_remove_quest">remove_quest</a>(store: &<b>mut</b> VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;, quest_id: &ID) {
    <a href="_remove">vec_map::remove</a>(store, quest_id);
}
</code></pre>



</details>

<a name="0x0_quest_store_increment_quest_started_count"></a>

## Function `increment_quest_started_count`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_increment_quest_started_count">increment_quest_started_count</a>(store: &<b>mut</b> <a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;, quest_id: &<a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_increment_quest_started_count">increment_quest_started_count</a>(store: &<b>mut</b> VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;, quest_id: &ID) {
    <b>let</b> quest = <a href="quest_store.md#0x0_quest_store_get_mut_quest">get_mut_quest</a>(store, quest_id);
    quest.started_count = quest.started_count + 1;
}
</code></pre>



</details>

<a name="0x0_quest_store_increment_quest_completed_count"></a>

## Function `increment_quest_completed_count`


Increments the number of times the quest has been completed.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_increment_quest_completed_count">increment_quest_completed_count</a>(store: &<b>mut</b> <a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;, quest_id: &<a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="quest_store.md#0x0_quest_store_increment_quest_completed_count">increment_quest_completed_count</a>(store: &<b>mut</b> VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;, quest_id: &ID) {
    <b>let</b> quest = <a href="quest_store.md#0x0_quest_store_get_mut_quest">get_mut_quest</a>(store, quest_id);
    <b>let</b> new_count = quest.completed_count + 1;
    <b>assert</b>!(
        <a href="_is_none">option::is_none</a>(&quest.completed_supply) || new_count &lt;= *<a href="_borrow">option::borrow</a>(&quest.completed_supply),
        <a href="quest_store.md#0x0_quest_store_EQuestCompletedSupplyReached">EQuestCompletedSupplyReached</a>
    );
    quest.completed_count = new_count;
}
</code></pre>



</details>

<a name="0x0_quest_store_get_quest"></a>

## Function `get_quest`


Returns the quest for the given quest ID.



<pre><code><b>public</b> <b>fun</b> <a href="quest_store.md#0x0_quest_store_get_quest">get_quest</a>(store: &<a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;, quest_id: &<a href="_ID">object::ID</a>): &<a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quest_store.md#0x0_quest_store_get_quest">get_quest</a>(store: &VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;, quest_id: &ID): &<a href="quest_store.md#0x0_quest_store_Quest">Quest</a> {
    <a href="_get">vec_map::get</a>(store, quest_id)
}
</code></pre>



</details>

<a name="0x0_quest_store_get_quest_lvl"></a>

## Function `get_quest_lvl`


Returns the quest ID for the given quest name.



<pre><code><b>public</b> <b>fun</b> <a href="quest_store.md#0x0_quest_store_get_quest_lvl">get_quest_lvl</a>(store: &<a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;, quest_id: &<a href="_ID">object::ID</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quest_store.md#0x0_quest_store_get_quest_lvl">get_quest_lvl</a>(store: &VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;, quest_id: &ID): u64 {
    <b>let</b> quest = <a href="_get">vec_map::get</a>(store, quest_id);
    <b>if</b> (<a href="_is_some">option::is_some</a>(&quest.lvl)) *<a href="_borrow">option::borrow</a>(&quest.lvl)
    <b>else</b> 0
}
</code></pre>



</details>

<a name="0x0_quest_store_get_quest_reward"></a>

## Function `get_quest_reward`


Returns the quest reward amount for the given quest ID.



<pre><code><b>public</b> <b>fun</b> <a href="quest_store.md#0x0_quest_store_get_quest_reward">get_quest_reward</a>(store: &<a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;, quest_id: &<a href="_ID">object::ID</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quest_store.md#0x0_quest_store_get_quest_reward">get_quest_reward</a>(store: &VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;, quest_id: &ID): u64 {
    <a href="quest_store.md#0x0_quest_store_get_quest">get_quest</a>(store, quest_id).reward_exp
}
</code></pre>



</details>

<a name="0x0_quest_store_get_mut_quest"></a>

## Function `get_mut_quest`


Returns the mutable quest for the given quest ID.



<pre><code><b>public</b> <b>fun</b> <a href="quest_store.md#0x0_quest_store_get_mut_quest">get_mut_quest</a>(store: &<b>mut</b> <a href="_VecMap">vec_map::VecMap</a>&lt;<a href="_ID">object::ID</a>, <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>&gt;, quest_id: &<a href="_ID">object::ID</a>): &<b>mut</b> <a href="quest_store.md#0x0_quest_store_Quest">quest_store::Quest</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quest_store.md#0x0_quest_store_get_mut_quest">get_mut_quest</a>(store: &<b>mut</b> VecMap&lt;ID, <a href="quest_store.md#0x0_quest_store_Quest">Quest</a>&gt;, quest_id: &ID): &<b>mut</b> <a href="quest_store.md#0x0_quest_store_Quest">Quest</a> {
    <a href="_get_mut">vec_map::get_mut</a>(store, quest_id)
}
</code></pre>



</details>

<a name="0x0_quest_store_to_string_vec"></a>

## Function `to_string_vec`

Converts a vector of vectors of u8 to a vector of strings


<pre><code><b>fun</b> <a href="quest_store.md#0x0_quest_store_to_string_vec">to_string_vec</a>(args: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;): <a href="">vector</a>&lt;<a href="_String">string::String</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="quest_store.md#0x0_quest_store_to_string_vec">to_string_vec</a>(args: <a href="">vector</a>&lt;<a href="">vector</a>&lt;u8&gt;&gt;): <a href="">vector</a>&lt;String&gt; {
    <b>let</b> string_args = <a href="_empty">vector::empty</a>&lt;String&gt;();
    <a href="_reverse">vector::reverse</a>(&<b>mut</b> args);

    <b>while</b> (!<a href="_is_empty">vector::is_empty</a>(&args)) {
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> string_args, <a href="_utf8">string::utf8</a>(<a href="_pop_back">vector::pop_back</a>(&<b>mut</b> args)))
    };

    string_args
}
</code></pre>



</details>
