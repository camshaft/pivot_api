%%
%% pivot_api_assign_handler.erl
%%
-module (pivot_api_assign_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
  {ok, Req, undefined}.

handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  {ID, Req3} = cowboy_req:qs_val(<<"i">>, Req2),
  {Test, Req4} = cowboy_req:qs_val(<<"t">>, Req3),

  {ok, Req5} = respond(Method, ID, Test, Req4),
  {ok, Req5, State}.

respond(_, _, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

terminate(_Reason, _Req, _State) ->
  ok.
