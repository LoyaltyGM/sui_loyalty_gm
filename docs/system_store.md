
<a name="0x0_system_store"></a>

# Module `0x0::system_store`


System Store is a module that stores all the loyalty systems IDs that are created.
It is a singleton module that is created when package is published/


-  [Struct `SYSTEM_STORE`](#0x0_system_store_SYSTEM_STORE)
-  [Resource `SystemStore`](#0x0_system_store_SystemStore)
-  [Function `init`](#0x0_system_store_init)
-  [Function `add_system`](#0x0_system_store_add_system)
-  [Function `length`](#0x0_system_store_length)
-  [Function `contains`](#0x0_system_store_contains)
-  [Function `borrow`](#0x0_system_store_borrow)


<pre><code><b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
</code></pre>



<a name="0x0_system_store_SYSTEM_STORE"></a>

## Struct `SYSTEM_STORE`


The SYSTEM_STORE struct is a witness that the module is a singleton module.



<pre><code><b>struct</b> <a href="system_store.md#0x0_system_store_SYSTEM_STORE">SYSTEM_STORE</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_system_store_SystemStore"></a>

## Resource `SystemStore`


The SystemStore struct contains the vector of loyalty systems IDs.



<pre><code><b>struct</b> <a href="system_store.md#0x0_system_store_SystemStore">SystemStore</a>&lt;T&gt; <b>has</b> key
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
<code>systems: <a href="">vector</a>&lt;<a href="_ID">object::ID</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x0_system_store_init"></a>

## Function `init`


The init function creates the SystemStore when the package is published and shares it.



<pre><code><b>fun</b> <a href="system_store.md#0x0_system_store_init">init</a>(_: <a href="system_store.md#0x0_system_store_SYSTEM_STORE">system_store::SYSTEM_STORE</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="system_store.md#0x0_system_store_init">init</a>(_: <a href="system_store.md#0x0_system_store_SYSTEM_STORE">SYSTEM_STORE</a>, ctx: &<b>mut</b> TxContext) {
    <b>let</b> store = <a href="system_store.md#0x0_system_store_SystemStore">SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">SYSTEM_STORE</a>&gt; {
        id: <a href="_new">object::new</a>(ctx),
        systems: <a href="_empty">vector::empty</a>&lt;ID&gt;()
    };

    <a href="_share_object">transfer::share_object</a>(store)
}
</code></pre>



</details>

<a name="0x0_system_store_add_system"></a>

## Function `add_system`


The add_system function adds a new loyalty system ID to the vector.



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="system_store.md#0x0_system_store_add_system">add_system</a>(store: &<b>mut</b> <a href="system_store.md#0x0_system_store_SystemStore">system_store::SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">system_store::SYSTEM_STORE</a>&gt;, loyalty_system_id: <a href="_ID">object::ID</a>, _: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="system_store.md#0x0_system_store_add_system">add_system</a>(store: &<b>mut</b> <a href="system_store.md#0x0_system_store_SystemStore">SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">SYSTEM_STORE</a>&gt;, loyalty_system_id: ID, _: &<b>mut</b> TxContext) {
    <a href="_push_back">vector::push_back</a>(&<b>mut</b> store.systems, loyalty_system_id);
}
</code></pre>



</details>

<a name="0x0_system_store_length"></a>

## Function `length`


Returns the length of the vector.



<pre><code><b>public</b> <b>fun</b> <a href="system_store.md#0x0_system_store_length">length</a>(store: &<a href="system_store.md#0x0_system_store_SystemStore">system_store::SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">system_store::SYSTEM_STORE</a>&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="system_store.md#0x0_system_store_length">length</a>(store: &<a href="system_store.md#0x0_system_store_SystemStore">SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">SYSTEM_STORE</a>&gt;): u64 {
    <a href="_length">vector::length</a>(&store.systems)
}
</code></pre>



</details>

<a name="0x0_system_store_contains"></a>

## Function `contains`


Returns true if the vector contains the given system ID.



<pre><code><b>public</b> <b>fun</b> <a href="system_store.md#0x0_system_store_contains">contains</a>(store: &<a href="system_store.md#0x0_system_store_SystemStore">system_store::SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">system_store::SYSTEM_STORE</a>&gt;, key: <a href="_ID">object::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="system_store.md#0x0_system_store_contains">contains</a>(store: &<a href="system_store.md#0x0_system_store_SystemStore">SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">SYSTEM_STORE</a>&gt;, key: ID): bool {
    <a href="_contains">vector::contains</a>(&store.systems, &key)
}
</code></pre>



</details>

<a name="0x0_system_store_borrow"></a>

## Function `borrow`


Returns the system ID at the given index.



<pre><code><b>public</b> <b>fun</b> <a href="system_store.md#0x0_system_store_borrow">borrow</a>(store: &<a href="system_store.md#0x0_system_store_SystemStore">system_store::SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">system_store::SYSTEM_STORE</a>&gt;, i: u64): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="system_store.md#0x0_system_store_borrow">borrow</a>(store: &<a href="system_store.md#0x0_system_store_SystemStore">SystemStore</a>&lt;<a href="system_store.md#0x0_system_store_SYSTEM_STORE">SYSTEM_STORE</a>&gt;, i: u64): ID {
    *<a href="_borrow">vector::borrow</a>(&store.systems, i)
}
</code></pre>



</details>
