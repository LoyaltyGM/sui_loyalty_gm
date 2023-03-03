/**
    System Store is a module that stores all the loyalty systems IDs that are created.
    It is a singleton module that is created when package is published/
*/
module loyalty_gm::system_store {
    use std::vector;

    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::TxContext;

    friend loyalty_gm::loyalty_system;

    // ======== Structs =========

    /**
        The SYSTEM_STORE struct is a witness that the module is a singleton module.
    */
    struct SYSTEM_STORE has drop {}

    /**
        The SystemStore struct contains the vector of loyalty systems IDs.
    */
    struct SystemStore<phantom T> has key {
        id: UID,
        systems: vector<ID>,
    }

    /**
        The init function creates the SystemStore when the package is published and shares it.
    */
    fun init(_: SYSTEM_STORE, ctx: &mut TxContext) {
        let store = SystemStore<SYSTEM_STORE> {
            id: object::new(ctx),
            systems: vector::empty<ID>()
        };

        transfer::share_object(store)
    }

    // ======== Public functions =========

    /**
        The add_system function adds a new loyalty system ID to the vector.
    */
    public(friend) fun add_system(store: &mut SystemStore<SYSTEM_STORE>, loyalty_system_id: ID, _: &mut TxContext) {
        vector::push_back(&mut store.systems, loyalty_system_id);
    }

    /**
        Returns the length of the vector.
    */
    public fun length(store: &SystemStore<SYSTEM_STORE>): u64 {
        vector::length(&store.systems)
    }

    /**
        Returns true if the vector contains the given system ID.
    */
    public fun contains(store: &SystemStore<SYSTEM_STORE>, key: ID): bool {
        vector::contains(&store.systems, &key)
    }

    /**
        Returns the system ID at the given index.
    */
    public fun borrow(store: &SystemStore<SYSTEM_STORE>, i: u64): ID {
        *vector::borrow(&store.systems, i)
    }

    #[test_only]
    public fun init_test(ctx: &mut TxContext) {
        init(SYSTEM_STORE {}, ctx)
    }
}