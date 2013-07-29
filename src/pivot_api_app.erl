%% @private
-module (pivot_api_app).
-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
  Port = simple_env:get_integer("PORT", 5000),

  Ebin = filename:dirname(code:which(?MODULE)),
  Priv = filename:join(filename:dirname(Ebin), "priv"),
  {ok, Routes} = file:consult(filename:join(Priv, "routes.econf")),

  Before = fun(Req) ->
    cowboy_req:set_meta(pivot_ref, pivot, Req)
  end,

  {ok, _} = cowboy:start_http(http, 100, [{port, Port}], [
    {compress, true},
    {env, [
      {dispatch, cowboy_router:compile(Routes)}
    ]},
    {onrequest, Before},
    {middlewares, [
      cowboy_router,
      cowboy_handler
    ]}
  ]),

  io:format("Server started on port ~p\n", [Port]),
  pivot_api_sup:start_link().

stop(_State) ->
  ok.
