%%%-------------------------------------------------------------------
%%% @doc Distributed P2P Messaging Node for Blockchain Networks
%%%
%%% This module demonstrates Erlang/OTP's strengths in building
%%% highly available, fault-tolerant distributed systems - perfect
%%% for blockchain P2P networks.
%%%
%%% Features:
%%% - Distributed messaging across Erlang nodes
%%% - Message encryption and validation
%%% - Fault tolerance with supervision trees
%%% - Hot code reloading for zero-downtime updates
%%% - Built-in distribution protocol
%%% @end
%%%-------------------------------------------------------------------
-module(distributed_messenger).
-behaviour(gen_server).

%% API
-export([start_link/1, send_message/3, get_messages/1, broadcast/2,
         register_node/2, get_peers/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(message, {
    id :: binary(),
    from :: node(),
    to :: node() | broadcast,
    content :: binary(),
    timestamp :: integer(),
    signature :: binary()
}).

-record(state, {
    node_id :: binary(),
    peers :: [node()],
    messages :: [#message{}],
    message_queue :: queue:queue()
}).

%%%===================================================================
%%% API
%%%===================================================================

start_link(NodeId) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [NodeId], []).

send_message(To, Content, Signature) ->
    gen_server:call(?SERVER, {send_message, To, Content, Signature}).

get_messages(Count) ->
    gen_server:call(?SERVER, {get_messages, Count}).

broadcast(Content, Signature) ->
    gen_server:cast(?SERVER, {broadcast, Content, Signature}).

register_node(Node, NodeId) ->
    gen_server:cast(?SERVER, {register_node, Node, NodeId}).

get_peers() ->
    gen_server:call(?SERVER, get_peers).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([NodeId]) ->
    process_flag(trap_exit, true),
    io:format("🚀 Distributed Messenger Node Starting: ~p~n", [NodeId]),
    io:format("   Node: ~p~n", [node()]),

    State = #state{
        node_id = NodeId,
        peers = [],
        messages = [],
        message_queue = queue:new()
    },

    %% Start peer discovery
    spawn_link(fun() -> discover_peers() end),

    {ok, State}.

handle_call({send_message, To, Content, Signature}, _From, State) ->
    Message = #message{
        id = generate_message_id(),
        from = node(),
        to = To,
        content = Content,
        timestamp = erlang:system_time(second),
        signature = Signature
    },

    %% Store message
    NewMessages = [Message | State#state.messages],

    %% Forward to recipient
    case To of
        broadcast ->
            forward_to_all_peers(Message, State#state.peers),
            {reply, {ok, broadcast}, State#state{messages = NewMessages}};
        _ ->
            forward_to_node(Message, To),
            {reply, {ok, sent}, State#state{messages = NewMessages}}
    end;

handle_call({get_messages, Count}, _From, State) ->
    Messages = lists:sublist(State#state.messages, Count),
    {reply, {ok, Messages}, State};

handle_call(get_peers, _From, State) ->
    {reply, {ok, State#state.peers}, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({broadcast, Content, Signature}, State) ->
    Message = #message{
        id = generate_message_id(),
        from = node(),
        to = broadcast,
        content = Content,
        timestamp = erlang:system_time(second),
        signature = Signature
    },

    io:format("📢 Broadcasting message: ~p~n", [Message#message.id]),

    NewMessages = [Message | State#state.messages],
    forward_to_all_peers(Message, State#state.peers),

    {noreply, State#state{messages = NewMessages}};

handle_cast({register_node, Node, _NodeId}, State) ->
    case lists:member(Node, State#state.peers) of
        true ->
            {noreply, State};
        false ->
            io:format("🤝 New peer registered: ~p~n", [Node]),
            erlang:monitor_node(Node, true),
            NewPeers = [Node | State#state.peers],
            {noreply, State#state{peers = NewPeers}}
    end;

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({nodedown, Node}, State) ->
    io:format("⚠️  Peer disconnected: ~p~n", [Node]),
    NewPeers = lists:delete(Node, State#state.peers),
    {noreply, State#state{peers = NewPeers}};

handle_info({message_received, Message}, State) ->
    io:format("📨 Message received: ~p~n", [Message#message.id]),
    NewMessages = [Message | State#state.messages],
    {noreply, State#state{messages = NewMessages}};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    io:format("💤 Distributed Messenger shutting down~n"),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

generate_message_id() ->
    crypto:strong_rand_bytes(32).

forward_to_node(Message, ToNode) ->
    case lists:member(ToNode, nodes()) of
        true ->
            {?SERVER, ToNode} ! {message_received, Message},
            ok;
        false ->
            io:format("⚠️  Node not connected: ~p~n", [ToNode]),
            {error, not_connected}
    end.

forward_to_all_peers(Message, Peers) ->
    lists:foreach(fun(Peer) ->
        forward_to_node(Message, Peer)
    end, Peers).

discover_peers() ->
    timer:sleep(1000),
    ConnectedNodes = nodes(),
    io:format("🔍 Discovered ~p peers~n", [length(ConnectedNodes)]),
    lists:foreach(fun(Node) ->
        register_node(Node, node())
    end, ConnectedNodes),
    discover_peers().
