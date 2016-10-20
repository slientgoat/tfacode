%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 十月 2016 11:05
%%%-------------------------------------------------------------------
-module(tfacode_api_controller, [Req]).
-compile(export_all).
-include("tfacode.hrl").


safe('POST', []) ->
  try
    lager:debug("Req:request_body():~p~n", [Req:request_body()]),
    Params = user_lib:parse(Req:request_body()),
    Appid = list_to_binary(?GV("appid", Params)),
    Token = list_to_binary(?GV("token", Params)),
    Uid = list_to_binary(?GV("uid", Params)),
    case Uid of
      <<>>->
        throw({json, [{<<"status">>, ?server_error}]});
      _ ->
        ok
    end,
    case boss_db:find(?tb_apps, [{appid, Appid}], [{limit, 1}]) of
      [App] ->
        case App:checkAuth(Token) of
          true ->
            ok;
          false ->
            throw({json, [{<<"status">>, ?safe_failed}]})
        end;
      [] ->
        throw({json, [{<<"status">>, ?safe_app_none}]})
    end,
    Url = config:get_url(),
    case boss_db:find(?tb_secret, [{uid, Uid}], [{limit, 1}]) of
      [User] ->
        lager:debug("Create secret User:secret()User:secret():~p~n", [User:secret()]),
        Params2 = term_to_binary({Uid, Appid, User:secret()}),
        EnParams = base64:encode(Params2),
        throw({json, [{<<"status">>, ?safe_success}, {<<"isbanded">>, User:isbanded()}, {<<"qrcode">>, <<Url/binary, "/api/qrcode/", EnParams/binary>>}, {<<"uid">>, Uid}]});
      [] ->

        Secret = tfacode:generate_secret(),
        User2 = ?tb_secret:new(id, Uid, Appid, Secret, ?isbanded_false),
        Result = User2:save(),
        lager:debug("Create secret result:~p~n", [Result]),
        Params2 = term_to_binary({Uid, Appid, Secret}),
        EnParams = base64:encode(Params2),
        throw({json, [{<<"status">>, ?safe_success}, {<<"isbanded">>, ?isbanded_false}, {<<"qrcode">>, <<Url/binary, "/api/qrcode/", EnParams/binary>>}, {<<"uid">>, Uid}]})
    end
  catch
    {json, Msg} ->
      {json, Msg, [{"Access-Control-Allow-Origin", "*"}]};
    _:_Why ->
      io:format("Error！！！ Why[~p] stack[~p]~n", [_Why, erlang:get_stacktrace()]),
      {json, [{<<"status">>, ?server_error}], [{"Access-Control-Allow-Origin", "*"}]}
  end.




verify('POST', []) ->
  try
    lager:debug("Req:request_body():~p~n", [Req:request_body()]),
    Params = user_lib:parse(Req:request_body()),
    Appid = list_to_binary(?GV("appid", Params)),
    Token = list_to_binary(?GV("token", Params)),
    Uid = list_to_binary(?GV("uid", Params)),
    Code = list_to_integer(?GV("code", Params)),
    case boss_db:find(?tb_apps, [{appid, Appid}], [{limit, 1}]) of
      [App] ->
        case App:checkAuth(Token) of
          true ->
            ok;
          false ->
            throw({json, [{<<"status">>, ?safe_failed}]})
        end;
      [] ->
        throw({json, [{<<"status">>, ?safe_app_none}]})
    end,
    case boss_db:find(?tb_secret, [{uid, Uid}], [{limit, 1}]) of
      [User] ->
        case User:verify(Code) of
          true ->
            throw({json, [{<<"status">>, ?safe_success}]});
          false ->
            throw({json, [{<<"status">>, ?safe_code_error}]})
        end;
      [] ->
        throw({json, [{<<"status">>, ?safe_user_none}]})
    end
  catch
    {json, Msg} ->
      {json, Msg, [{"Access-Control-Allow-Origin", "*"}]};
    _:_Why ->
      io:format("Error！！！ Why[~p] stack[~p]~n", [_Why, erlang:get_stacktrace()]),
      {json, [{<<"status">>, ?server_error}], [{"Access-Control-Allow-Origin", "*"}]}
  end.



qrcode('GET', [EnParams]) ->
  Params = base64:decode(EnParams),
  {Uid, Appid, Secret} = binary_to_term(Params),
  lager:debug("get qrcode Secret:~p~n", [Secret]),
  BinPng = tfacode:generate_qrcode(Appid, Uid, Secret),
  {output, BinPng, [{"Content-Type", "image/png"},{"Access-Control-Allow-Origin", "*"}]}.

