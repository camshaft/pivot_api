%%
%% pivot_api_track_handler.erl
%%
-module (pivot_api_track_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-include("pivot_api.hrl").

init(_Transport, Req, [Ref]) ->
  {ok, Req, Ref}.

handle(Req, Ref) ->
  {Method, Req2} = cowboy_req:method(Req),
  {ok, Req3} = check_method(Method, Ref, Req2),
  {ok, Req3, Ref}.

check_method(<<"GET">>, Ref, Req) ->
  {App, Req2} = cowboy_req:qs_val(<<"a">>, Req),
  {Event, Req3} = cowboy_req:qs_val(<<"e">>, Req2),
  {UserID, Req4} = cowboy_req:qs_val(<<"u">>, Req3),
  maybe_track(App, Event, UserID, Ref, Req4);
check_method(<<"POST">>, Ref, Req) ->
  {ok, Params, Req2} = cowboy_req:body_qs(Req),
  App = fast_key:get(<<"a">>, Params),
  Event = fast_key:get(<<"e">>, Params),
  UserID = fast_key:get(<<"u">>, Params),
  maybe_track(App, Event, UserID, Ref, Req2);
check_method(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

maybe_track(undefined, _, _, _, Req) ->
  ?ERROR(<<"Missing app (a) parameter.">>, Req);
maybe_track(_, undefined, _, _, Req) ->
  ?ERROR(<<"Missing event (e) parameter.">>, Req);
maybe_track(_, _, undefined, _, Req) ->
  ?ERROR(<<"Missing user id (u) parameter.">>, Req);
maybe_track(App, Event, UserID, Ref, Req) ->
  ok = pivot:track(Ref, App, Event, UserID),
  cowboy_req:reply(200, [], <<"">>, Req).

terminate(_Reason, _Req, _State) ->
  ok.
