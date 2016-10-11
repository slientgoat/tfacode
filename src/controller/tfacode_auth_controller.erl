%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 十月 2016 11:05
%%%-------------------------------------------------------------------
-module(tfacode_auth_controller, [Req]).
-compile(export_all).
-include("tfacode.hrl").

%%login('GET', []) ->
%%  Header = binary_to_list(Req:header(<<"authorization">>)),
%%  ["Basic",EnAuth]=string:tokens(Header," "),
%%  DeAuth = base64:decode_to_string(EnAuth),
%%  [UserName,Passward] = string:tokens(DeAuth,":"),
%%  io:format("UserName:~p~n", [UserName]),
%%  io:format("Passward:~p~n", [Passward]),
%%  {output, "test"};

login('POST', []) ->
  Params = mochijson2:decode(Req:request_body(), [{format, proplist}]),
  try
    Username = ?GV(<<"username">>, Params),
    Password = ?GV(<<"password">>, Params),
    lager:debug("Username:~p~n", [Username]),
    lager:debug("Passward:~p~n", [Password]),
    case boss_db:find(users, [{username, Username}], [{limit, 1}]) of
      [User] ->
        case User:check_password(Password) of
          true ->
            {json, [{<<"status">>, ?login_sucess}, {<<"appid">>, User:appid()},{<<"appname">>, User:appname()},{<<"secret">>, User:secret()}]};
%%            {redirect, "/", User:set_login_cookies()};
          false ->
            {json, [{<<"status">>, ?login_dismatch}]}
        end;
      [] ->
        {json, [{<<"status">>, ?login_user_none}]}
    end
  catch
    _ ->
      Result2 = [{<<"msg">>, <<"unknow server problem happen!">>}],
      lager:error("console_channel_rest_controller Fun:~p, Result2:~p~n", [get_captcha, Result2]),
      {json, Result2}
  end.



register('GET', []) ->
  {ok, []};

register('POST', []) ->
  Params = mochijson2:decode(Req:request_body(), [{format, proplist}]),
  try
    Username = ?GV(<<"username">>, Params),
    Password = ?GV(<<"password">>, Params),
    Secret = <<"12345678901234567890">>,
    Appname = <<"blizzmi">>,
    Appid = <<"1">>,
    User = users:new(id, Username, Password, Secret,Appid,Appname),
    Result = User:save(),
    lager:debug("register result:~p~n", [Result]),
    {json, [{<<"status">>, ?register_sucess}]}
  catch
    _:_Why ->
      io:format("Error！！！ Why[~p] stack[~p]~n", [_Why, erlang:get_stacktrace()]),
      {json, [{<<"status">>, ?register_failed}]}
  end.

check('GET', []) ->
  {ok, []};

check('POST', []) ->
  Params = mochijson2:decode(Req:request_body(), [{format, proplist}]),
  try
    Username = ?GV(<<"username">>, Params),
    TfaCode = ?GV(<<"tfacode">>, Params),
    case boss_db:find(users, [{username, Username}], [{limit, 1}]) of
      [User] ->
        case User:check_code(TfaCode) of
          true ->
            {json, [{<<"status">>, ?check_sucess}]};
%%          {redirect,"/", User:set_login_cookies()};
          false ->
            {json, [{<<"status">>, ?check_failed}]}
        end;
      [] ->
        {json, [{<<"status">>, ?login_user_none}]}
    end
  catch
    _:_Why ->
      io:format("Error！！！ Why[~p] stack[~p]~n", [_Why, erlang:get_stacktrace()]),
      {json, [{<<"status">>, ?check_failed}]}
  end.
