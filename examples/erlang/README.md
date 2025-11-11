# Erlang Distributed Messaging Node

A production-quality distributed P2P messaging system demonstrating Erlang/OTP's legendary capabilities for building fault-tolerant, distributed blockchain networks.

## Why Erlang for Blockchain?

Erlang was designed for building telecom systems with 99.9999999% uptime (31ms downtime per year!):

- **Massive Concurrency**: Millions of lightweight processes
- **Fault Tolerance**: "Let it crash" philosophy with supervision trees
- **Distribution**: Built-in support for distributed systems
- **Hot Code Reloading**: Update code without stopping the system
- **Message Passing**: Actor model for safe concurrency
- **Battle-Tested**: 30+ years in production (WhatsApp, Discord, RabbitMQ)

**Perfect for**: Blockchain P2P networks, consensus algorithms, validator nodes

## Features

- Distributed messaging across Erlang nodes
- Automatic peer discovery and management
- Fault tolerance with automatic node monitoring
- Hot code reloading for zero-downtime updates
- Message encryption and validation
- Broadcast and unicast messaging

## Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get install erlang

# macOS
brew install erlang

# Using asdf (recommended)
asdf plugin add erlang
asdf install erlang 26.0

# Verify
erl -version
```

## Installation

```bash
cd examples/erlang

# Compile
rebar3 compile

# Or use erlc
erlc -o ebin src/*.erl
```

## Usage

### Single Node

```bash
# Start Erlang shell
erl -pa ebin

% Start the messenger
1> distributed_messenger:start_link(<<"node1">>).

% Get peers
2> distributed_messenger:get_peers().

% Broadcast message
3> distributed_messenger:broadcast(<<"Hello, blockchain!">>, <<"sig">>).
```

### Distributed Network

Terminal 1:
```bash
# Start first node
erl -sname node1@localhost -setcookie secret -pa ebin

1> distributed_messenger:start_link(<<"node1">>).
```

Terminal 2:
```bash
# Start second node
erl -sname node2@localhost -setcookie secret -pa ebin

1> distributed_messenger:start_link(<<"node2">>).
2> net_adm:ping('node1@localhost').  % Connect to node1
3> distributed_messenger:send_message('node1@localhost', <<"Hi!">>, <<"sig">>).
```

Terminal 3:
```bash
# Start third node
erl -sname node3@localhost -setcookie secret -pa ebin

1> distributed_messenger:start_link(<<"node3">>).
2> net_adm:ping('node1@localhost').
3> distributed_messenger:broadcast(<<"Everyone receives this!">>, <<"sig">>).
```

## Key Concepts

### Lightweight Processes

```erlang
% Spawn millions of processes with ease
spawn(fun() ->
    receive
        {msg, Content} -> io:format("Got: ~p~n", [Content])
    end
end).
```

### Let It Crash Philosophy

```erlang
% Don't defensive program - let supervisors handle failures
-behaviour(supervisor).

init([]) ->
    SupFlags = #{strategy => one_for_one, intensity => 5, period => 10},
    ChildSpecs = [
        #{id => messenger,
          start => {distributed_messenger, start_link, []},
          restart => permanent}
    ],
    {ok, {SupFlags, ChildSpecs}}.
```

### Hot Code Reloading

```erlang
% Update code without stopping
% In production:
c(distributed_messenger).  % Recompile
sys:suspend(distributed_messenger).  % Pause
code:purge(distributed_messenger).   % Remove old code
code:load_file(distributed_messenger). % Load new
sys:resume(distributed_messenger).   % Resume
```

### Pattern Matching

```erlang
handle_call({send_message, To, Content, _Sig}, _From, State) ->
    case To of
        broadcast ->
            % Handle broadcast
            {reply, ok, State};
        SingleNode when is_atom(SingleNode) ->
            % Handle unicast
            {reply, ok, State}
    end.
```

## Production Deployment

### Release

```bash
# Create release with rebar3
rebar3 release

# Run release
_build/default/rel/distributed_messenger/bin/distributed_messenger console
```

### Docker

```dockerfile
FROM erlang:26

WORKDIR /app
COPY . .
RUN rebar3 as prod release

CMD ["_build/prod/rel/distributed_messenger/bin/distributed_messenger", "foreground"]
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: erlang-messenger
spec:
  serviceName: messenger
  replicas: 3
  selector:
    matchLabels:
      app: messenger
  template:
    spec:
      containers:
      - name: messenger
        image: messenger:latest
        env:
        - name: ERLANG_COOKIE
          value: "secret_cookie"
```

## Benchmarks

Erlang excels at:

- **Process spawn**: 1-2 microseconds
- **Message passing**: Sub-microsecond for local
- **Memory per process**: ~300 bytes minimum
- **Max processes**: Millions (billions theoretically)
- **Latency**: Microseconds (p99)

## Real-World Usage

Erlang powers:
- **WhatsApp**: 2 million connections per server
- **Discord**: Real-time messaging for millions
- **RabbitMQ**: Message broker
- **Riak**: Distributed database
- **Blockchain nodes**: Aeternity, Algorand components

## Resources

- [Learn You Some Erlang](http://learnyousomeerlang.com/)
- [Erlang Official Docs](https://www.erlang.org/docs)
- [OTP Design Principles](https://www.erlang.org/doc/design_principles/users_guide.html)

## License

MIT License

---

Built with 🔥 for the WhisperChain Multi-Language Web3 Platform
