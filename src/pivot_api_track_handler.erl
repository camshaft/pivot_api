%%
%% pivot_api_track_handler.erl
%%
-module (pivot_api_track_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
  {ok, Req, undefined}.

handle(Req, State) ->
  {Method, Req2} = cowboy_req:method(Req),
  {Event, Req3} = cowboy_req:qs_val(<<"e">>, Req2),
  {ID, Req4} = cowboy_req:qs_val(<<"i">>, Req3),
  {Test, Req5} = cowboy_req:qs_val(<<"t">>, Req4),

  {ok, Req6} = respond(Method, Event, ID, Test, Req5),
  {ok, Req6, State}.

respond(<<"GET">>, undefined, _, _, Req) ->
  cowboy_req:reply(400, [], <<"Missing 'e' parameter.">>, Req);
respond(<<"GET">>, _, undefined, _, Req) ->
  cowboy_req:reply(400, [], <<"Missing 'i' parameter.">>, Req);
respond(<<"GET">>, Event, ID, Test, Req) ->
  Env = case Test of
    <<"1">> ->
      test;
    _ ->
      prod
  end,

  {Ref, Req} = cowboy_req:meta(pivot_ref, Req),
  % pivot:event(Ref, Env, Event, ID),
  io:format("Ref ~p Event ~p ID ~p Env ~p\n", [Ref, Event, ID, Env]),

  cowboy_req:reply(200, [], <<"">>, Req);
respond(_, _, _, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

terminate(_Reason, _Req, _State) ->
  ok.
