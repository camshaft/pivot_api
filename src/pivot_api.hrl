
-define(ERROR (Error, Req), cowboy_req:reply(400, [{<<"content-type">>, <<"application/json">>}], <<"{\"error\":{\"message\":\"", Error/binary, "\",\"code\":400}}">>, Req)).
