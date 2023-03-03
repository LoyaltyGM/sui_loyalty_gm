/**
    Task Store module.
    This module is responsible for storing all the tasks in the system.
    Its functions are only accessible by the friend modules.
*/
module loyalty_gm::task_store {
    use std::string::{Self, String};
    use std::vector;

    use sui::event::emit;
    use sui::object::{Self, ID};
    use sui::tx_context::TxContext;
    use sui::vec_map::{Self, VecMap};

    friend loyalty_gm::loyalty_system;
    friend loyalty_gm::loyalty_token;

    // ======== Constants =========

    const INITIAL_XP: u64 = 0;
    const BASIC_REWARD_XP: u64 = 5;
    const MAX_TASKS: u64 = 100;

    // ======== Error codes =========

    const EMaxTasksReached: u64 = 0;

    // ======== Structs =========

    /**
        Task struct.
        This struct represents a task that the user can complete.
        The task is represented by a function that needs to be executed.
    */
    struct Task has store, drop {
        id: ID,
        lvl: u64,
        name: String,
        description: String,
        /// The amount of XP that the user will receive upon completing the task
        reward_exp: u64,
        /// The ID of the package that contains the function that needs to be executed
        package_id: ID,
        /// The name of the module that contains the function that needs to be executed
        module_name: String,
        /// The name of the function that needs to be executed
        function_name: String,
        /// The arguments that need to be passed to the function
        arguments: vector<String>,
    }

    // ======== Events =========

    struct CreateTaskEvent has copy, drop {
        /// Object ID of the Task
        task_id: ID,
        /// Name of the Task
        name: string::String,
    }

    // ======== Public functions =========

    // ======== Friend functions =========

    /**
        Creates a new empty task store.
        Store represents a map of task IDs to tasks.
    */
    public(friend) fun empty(): VecMap<ID, Task> {
        vec_map::empty<ID, Task>()
    }

    /**
        Creates a new task and adds it to the store.
        The task is represented by a function that needs to be executed.
        The function is identified by the package ID, module name and function name.
        The arguments are the arguments that need to be passed to the function.
    */
    public(friend) fun add_task(
        store: &mut VecMap<ID, Task>,
        lvl: u64,
        name: vector<u8>,
        description: vector<u8>,
        reward_exp: u64,
        package_id: ID,
        module_name: vector<u8>,
        function_name: vector<u8>,
        arguments: vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        assert!(vec_map::size(store) <= MAX_TASKS, EMaxTasksReached);

        let uid = object::new(ctx);
        let id = object::uid_to_inner(&uid);
        object::delete(uid);

        let task = Task {
            id,
            lvl,
            name: string::utf8(name),
            description: string::utf8(description),
            reward_exp,
            package_id,
            module_name: string::utf8(module_name),
            function_name: string::utf8(function_name),
            arguments: to_string_vec(arguments),
        };

        emit(CreateTaskEvent {
            task_id: id,
            name: task.name,
        });

        vec_map::insert(store, id, task);
    }

    /**
        Removes a task from the store.
    */
    public(friend) fun remove_task(store: &mut VecMap<ID, Task>, task_id: ID) {
        vec_map::remove(store, &task_id);
    }

    /**
        Returns the task ID for the given task name.
    */
    public fun get_task_lvl(store: &VecMap<ID, Task>, task_id: &ID): u64 {
        vec_map::get(store, task_id).lvl
    }

    /**
        Returns the task reward amount for the given task ID.
    */
    public fun get_task_reward(store: &VecMap<ID, Task>, task_id: &ID): u64 {
        vec_map::get(store, task_id).reward_exp
    }

    // ======= Private and Utility functions =======

    /// Converts a vector of vectors of u8 to a vector of strings
    fun to_string_vec(args: vector<vector<u8>>): vector<String> {
        let string_args = vector::empty<String>();
        vector::reverse(&mut args);

        while (!vector::is_empty(&args)) {
            vector::push_back(&mut string_args, string::utf8(vector::pop_back(&mut args)))
        };

        string_args
    }
}