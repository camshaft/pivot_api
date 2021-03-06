%%
%% pivot_api.erl
%%
-module (pivot_api).

-export([start/0]).

%% API.

start() ->
  ok = inets:start(),
  ok = application:start(crypto),
  ok = application:start(ranch),
  ok = application:start(cowboy),
  ok = application:start(pivot_api).
