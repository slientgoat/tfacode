%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 十月 2016 11:05
%%%-------------------------------------------------------------------
-module(tfacode_main_controller, [Req,SessionID]).
-compile(export_all).
-include("tfacode.hrl").

before_(_) ->
  user_lib:require_login(Req,SessionID).

%% 退出登录
index('GET', [], _User) ->
  {output,"hello"}.


%% 退出登录
exit('POST', [], User) ->
  U2 = User:set(session, <<>>),
  {ok, _User2} = U2:save(),
  {json, [{<<"status">>, ?exit_sucess}],[mochiweb_cookies:cookie("session_id",<<>>,[{path, "/"}]),{"Access-Control-Allow-Origin", "*"}]}.

closeverify('POST', [], User) ->
  U2 = User:set(isbanded, ?isbanded_false),
  {ok, _User2} = U2:save(),
  {json, [{<<"status">>, ?closeverify_true}],[{"Access-Control-Allow-Origin", "*"}]}.



authQrcode('GET', [], User) ->
  BinPng = tfacode:generate_qrcode(User:secret(),User:username()),
  {output, BinPng, [{"Content-Type", "image/png"}]}.

loginsucess('GET', [], _User) ->
  Url = config:get_url(),
  {ok, [{url,<<Url/binary,"/main/exit">>}], []}.

opensafe('GET', [], _User) ->
  Url = config:get_url(),
  {ok, [{url,<<Url/binary,"/main/verify">>}], []}.


verify('GET', [], _User) ->
  Url = config:get_url(),
  {ok, [{url,<<Url/binary,"/main/verify">>}], []};

verify('POST', [], User) ->
  try
    lager:debug("Req:request_body():~p~n", [Req:request_body()]),
    Params = mochiweb_util:parse_qs(Req:request_body()),
    Tfacode = list_to_binary(?GV("tfacode", Params)),
    case User:check_code(Tfacode) of
      true ->
        case User:isbanded() of
          ?isbanded_false ->
            U2 = User:set(isbanded, ?isbanded_true),
            {ok, _User2} = U2:save();
          _ ->
            ok
        end,
        {json, [{<<"status">>, ?check_sucess}],[{"Access-Control-Allow-Origin", "*"}]};
      false ->
        {json, [{<<"status">>, ?check_failed}],[{"Access-Control-Allow-Origin", "*"}]}
    end
  catch
    _:_Why ->
      io:format("Error！！！ Why[~p] stack[~p]~n", [_Why, erlang:get_stacktrace()]),
      {json, [{<<"status">>, ?server_error}]}
  end.


verifysuccess('GET', [], _User) ->
  Url = config:get_url(),
  {ok, [{url_exit,<<Url/binary,"/main/exit">>},{url_closeverify,<<Url/binary,"/main/closeverify">>}], []}.