%%
%% pivot_api_assign_handler.erl
%%
-module (pivot_api_assign_handler).

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
  {UserID, Req3} = cowboy_req:qs_val(<<"u">>, Req2),
  maybed_assign(App, UserID, Ref, Req3);
check_method(<<"POST">>, Ref, Req) ->
  {ok, Params, Req2} = cowboy_req:body_qs(Req),
  App = fast_key:get(<<"a">>, Params),
  UserID = fast_key:get(<<"u">>, Params),
  maybed_assign(App, UserID, Ref, Req2);
check_method(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

maybed_assign(undefined, _, _, Req) ->
  ?ERROR(<<"Missing app (a) parameter.">>, Req);
maybed_assign(_, undefined, _, Req) ->
  ?ERROR(<<"Missing user id (u) parameter.">>, Req);
maybed_assign(App, UserID, Ref, Req) ->
  Res = pivot:assign(Ref, App, UserID),
  respond(Res, Req).

respond({ok, Assignments, CacheLength}, Req) ->
  Body = jsx:encode([
    {<<"assignments">>, Assignments}
  ]),
  cowboy_req:reply(200, [{<<"cache-control">>, <<"max-age=", (integer_to_binary(CacheLength))/binary>>}], Body, Req);

respond({ok, Assignments}, Req) ->
  Body = jsx:encode([
    {<<"assignments">>, Assignments}
  ]),
  cowboy_req:reply(200, [], Body, Req);
respond(_, Req) ->
  cowboy_req:reply(404, [], <<>>, Req).

terminate(_Reason, _Req, _State) ->
  ok.
