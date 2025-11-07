module whisper_addr::message_board {
    use std::string::{Self, String};
    use std::signer;
    use std::vector;
    use aptos_framework::timestamp;
    use aptos_framework::event;

    /// Error codes
    const EBOARD_NOT_INITIALIZED: u64 = 1;
    const EMESSAGE_NOT_FOUND: u64 = 2;
    const ENOT_MESSAGE_OWNER: u64 = 3;

    /// Message structure
    struct Message has store, drop, copy {
        id: u64,
        sender: address,
        content: String,
        timestamp: u64,
    }

    /// Message board for an account
    struct MessageBoard has key {
        messages: vector<Message>,
        next_id: u64,
    }

    /// Events
    struct MessagePostedEvent has drop, store {
        sender: address,
        message_id: u64,
        content: String,
        timestamp: u64,
    }

    struct MessageDeletedEvent has drop, store {
        message_id: u64,
        deleted_by: address,
    }

    /// Event handles
    struct MessageBoardEvents has key {
        message_posted_events: event::EventHandle<MessagePostedEvent>,
        message_deleted_events: event::EventHandle<MessageDeletedEvent>,
    }

    /// Initialize message board for account
    public entry fun initialize(account: &signer) {
        let addr = signer::address_of(account);

        if (!exists<MessageBoard>(addr)) {
            move_to(account, MessageBoard {
                messages: vector::empty<Message>(),
                next_id: 0,
            });
        };

        if (!exists<MessageBoardEvents>(addr)) {
            move_to(account, MessageBoardEvents {
                message_posted_events: event::new_event_handle<MessagePostedEvent>(account),
                message_deleted_events: event::new_event_handle<MessageDeletedEvent>(account),
            });
        };
    }

    /// Post a message to own board
    public entry fun post_message(
        account: &signer,
        content: String
    ) acquires MessageBoard, MessageBoardEvents {
        let addr = signer::address_of(account);

        if (!exists<MessageBoard>(addr)) {
            initialize(account);
        };

        let board = borrow_global_mut<MessageBoard>(addr);
        let message_id = board.next_id;

        let message = Message {
            id: message_id,
            sender: addr,
            content,
            timestamp: timestamp::now_seconds(),
        };

        vector::push_back(&mut board.messages, message);
        board.next_id = message_id + 1;

        // Emit event
        let events = borrow_global_mut<MessageBoardEvents>(addr);
        event::emit_event(&mut events.message_posted_events, MessagePostedEvent {
            sender: addr,
            message_id,
            content,
            timestamp: timestamp::now_seconds(),
        });
    }

    /// Delete a message (only owner can delete)
    public entry fun delete_message(
        account: &signer,
        message_id: u64
    ) acquires MessageBoard, MessageBoardEvents {
        let addr = signer::address_of(account);
        assert!(exists<MessageBoard>(addr), EBOARD_NOT_INITIALIZED);

        let board = borrow_global_mut<MessageBoard>(addr);
        let messages = &mut board.messages;

        let len = vector::length(messages);
        let i = 0;
        let found = false;

        while (i < len) {
            let msg = vector::borrow(messages, i);
            if (msg.id == message_id) {
                assert!(msg.sender == addr, ENOT_MESSAGE_OWNER);
                vector::remove(messages, i);
                found = true;
                break
            };
            i = i + 1;
        };

        assert!(found, EMESSAGE_NOT_FOUND);

        // Emit event
        let events = borrow_global_mut<MessageBoardEvents>(addr);
        event::emit_event(&mut events.message_deleted_events, MessageDeletedEvent {
            message_id,
            deleted_by: addr,
        });
    }

    /// Get all messages from a board
    #[view]
    public fun get_messages(account: address): vector<Message> acquires MessageBoard {
        if (!exists<MessageBoard>(account)) {
            return vector::empty<Message>()
        };

        let board = borrow_global<MessageBoard>(account);
        *&board.messages
    }

    /// Get message count
    #[view]
    public fun get_message_count(account: address): u64 acquires MessageBoard {
        if (!exists<MessageBoard>(account)) {
            return 0
        };

        let board = borrow_global<MessageBoard>(account);
        vector::length(&board.messages)
    }

    #[test_only]
    use aptos_framework::account;

    #[test(user = @0x123)]
    fun test_post_and_read_message(user: &signer) acquires MessageBoard, MessageBoardEvents {
        // Setup
        account::create_account_for_test(signer::address_of(user));
        timestamp::set_time_has_started_for_testing(&account::create_signer_for_test(@0x1));

        // Initialize and post message
        initialize(user);
        let content = string::utf8(b"Hello, Aptos!");
        post_message(user, content);

        // Verify
        let messages = get_messages(signer::address_of(user));
        assert!(vector::length(&messages) == 1, 1);

        let msg = vector::borrow(&messages, 0);
        assert!(msg.content == content, 2);
        assert!(msg.sender == signer::address_of(user), 3);
    }

    #[test(user = @0x123)]
    fun test_delete_message(user: &signer) acquires MessageBoard, MessageBoardEvents {
        // Setup
        account::create_account_for_test(signer::address_of(user));
        timestamp::set_time_has_started_for_testing(&account::create_signer_for_test(@0x1));

        // Post and delete
        initialize(user);
        post_message(user, string::utf8(b"Test message"));

        assert!(get_message_count(signer::address_of(user)) == 1, 1);

        delete_message(user, 0);

        assert!(get_message_count(signer::address_of(user)) == 0, 2);
    }
}
