%% -------------------------------------------------------------------
%%
%% Copyright (c) 2007-2012 Basho Technologies, Inc.  All Rights Reserved.
%%
%% -------------------------------------------------------------------

%% @doc Module to process bucket creation requests.

-module(bucket_bouncer_server).

-behaviour(gen_server).

-include("bucket_bouncer.hrl").

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

%% Test API
-export([test_link/0]).

-endif.

%% API
-export([start_link/0,
         create_bucket/2,
         delete_bucket/2,
         stop/1]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {riak_ip :: string(),
                riak_port :: pos_integer(),
                buckets_bucket :: binary()}).
-type state() :: #state{}.


%% ===================================================================
%% Public API
%% ===================================================================

%% @doc Start a `bucket_bouncer_server'.
-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_server:start_link({local, ?MODULE}, [], []).

%% @doc Attempt to create a bucket
-spec create_bucket(binary(), binary()) -> ok | {error, term()}.
create_bucket(Bucket, UserId) ->
    gen_server:call(?MODULE, {create_bucket, Bucket, UserId}).

%% @doc Attempt to delete a bucket
-spec delete_bucket(binary(), binary()) -> ok | {error, term()}.
delete_bucket(Bucket, UserId) ->
    gen_server:call(?MODULE, {delete_bucket, Bucket, UserId}).

stop(Pid) ->
    gen_server:cast(Pid, stop).

%% ===================================================================
%% gen_server callbacks
%% ===================================================================

%% @doc Initialize the server.
-spec init([] | {test, [atom()]}) -> {ok, state()} | {stop, term()}.
init([]) ->
    {ok, #state{}};
init(test) ->
      {ok, #state{}}.

%% @doc Handle synchronous commands issued via exported functions.
-spec handle_call(term(), {pid(), term()}, state()) ->
                         {reply, ok, state()}.
handle_call({create_bucket, Bucket, OwnerId},
            _From,
            State=#state{}) ->
    Result = bucket_bouncer_utils:create_bucket(Bucket, OwnerId),
    {reply, Result, State};
handle_call({delete_bucket, Bucket, OwnerId},
            _From,
            State=#state{}) ->
    Result = bucket_bouncer_utils:delete_bucket(Bucket, OwnerId),
    {reply, Result, State};
handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

%% @doc Handle asynchronous commands issued via
%% the exported functions.
-spec handle_cast(term(), state()) ->
                         {noreply, state()}.
handle_cast(list_buckets, State) ->
    %% @TODO Handle bucket listing and reply
    {noreply, State};
handle_cast(stop, State) ->
    {stop, normal, State};
handle_cast(Event, State) ->
    lager:warning("Received unknown cast event: ~p", [Event]),
    {noreply, State}.

%% @doc @TODO
-spec handle_info(term(), state()) ->
                         {noreply, state()}.
handle_info(_Info, State) ->
    {noreply, State}.

%% @doc Unused.
-spec terminate(term(), state()) -> ok.
terminate(_Reason, _State) ->
    ok.

%% @doc Unused.
-spec code_change(term(), state(), term()) ->
                         {ok, state()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% ====================================================================
%% Internal functions
%% ====================================================================

%% ===================================================================
%% Test API
%% ===================================================================

-ifdef(TEST).

%% @doc Start a `bucket_bouncer_server' for testing.
-spec test_link() -> {ok, pid()} | {error, term()}.
test_link() ->
    gen_server:start_link(?MODULE, test, []).

-endif.