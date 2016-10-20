%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 十月 2016 11:05
%%%-------------------------------------------------------------------
-module(tfacode_auth_controller, [Req,SessionID]).
-compile(export_all).
-include("tfacode.hrl").

login('GET', []) ->
  Url = config:get_url(),
  {ok, [{url,<<Url/binary,"/auth/login">>}], []};


login('POST', []) ->
  try
    lager:debug("Req():~p~n", [Req]),
    lager:debug("Req:request_body():~p~n", [Req:request_body()]),
    lager:debug("Req:query_params():~p~n", [Req:query_params()]),
    Params = mochiweb_util:parse_qs(Req:request_body()),
    Username = list_to_binary(?GV("username", Params)),
    Password = list_to_binary(?GV("password", Params)),
    lager:debug("Username:~p~n", [Username]),
    lager:debug("Passward:~p~n", [Password]),
    case boss_db:find(users, [{username, Username}], [{limit, 1}]) of
      [User] ->
        case User:check_password(Password) of
          true ->
            U2 = User:set(session, SessionID),
            {ok, _User2} = U2:save(),
            lager:debug("User:~p~nUser2:~p~n", [User,_User2]),
            Header = User:set_login_cookies()++[{"Access-Control-Allow-Origin", "*"}],
            lager:debug("Header:~p~n", [Header]),
            case User:isbanded() of
              ?isbanded_false ->
                {json, [{<<"status">>, ?login_sucess}, {<<"isbanded">>, ?isbanded_false}],Header};
              _ ->
                {json, [{<<"status">>, ?login_sucess}, {<<"isbanded">>, ?isbanded_true}],Header}
            end;
          false ->
            {json, [{<<"status">>, ?login_dismatch}]}
        end;
      [] ->
        {json, [{<<"status">>, ?login_none}],[{"Access-Control-Allow-Origin", "*"}]}
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
%%    Secret = <<"12345678901234567890">>,
    Secret = crypto:sha(integer_to_binary(rand:uniform(99999999999999999))),
    Appname = <<"blizzmi">>,
    Appid = <<"1">>,
    User = users:new(id, Username, Password, Secret, Appid, Appname, ?isbanded_false),
    Result = User:save(),
    lager:debug("register result:~p~n", [Result]),
    {json, [{<<"status">>, ?register_sucess}]}
  catch
    _:_Why ->
      io:format("Error！！！ Why[~p] stack[~p]~n", [_Why, erlang:get_stacktrace()]),
      {json, [{<<"status">>, ?server_error}]}
  end.


