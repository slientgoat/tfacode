%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 十月 2016 10:15
%%%-------------------------------------------------------------------
-module(tfacode).
-author("Administrator").
-include("tfacode.hrl").
%% API
-export([
  init_db/0,
  get_secret/1,
  set_secret/2,
  check_code/2,
  get_code/0
]).


%% @doc
%% 数据库初始化
%% @end
-spec init_db() -> {atomic,ok}|{aborted,{already_exists,?tb_tfa_secret}}.
init_db() ->
  Res = mnesia:create_table(?tb_tfa_secret, [{disc_copies, [node()]}, {attributes, record_info(fields, ?tb_tfa_secret)}]),
  lager:info("create table (~p): ~p~n", [Res, [?tb_tfa_secret, {attributes, ?tb_tfa_secret}]]),
  Res.


%% @doc
%% 获取secret
%% @end
-spec get_secret(UID :: integer()) -> binary().
get_secret(UID) ->
  mnesia:dirty_read(?tb_tfa_secret, UID).


%% @doc
%% 设置secret
%% @end
-spec set_secret(UID :: integer(),Secret::binary()) -> ok.
set_secret(UID,Secret) ->
  mnesia:dirty_write(?tb_tfa_secret, #tfa_secret{uid = UID,secret = Secret}).


%% @doc
%% 二次认证检查
%% @end
-spec check_code(Secret::binary(),TfaCode::integer()) -> boolean().
check_code(Secret, TfaCode)->
  Tfacode2 = totp:cons(Secret),
  io:format("TfaCode:~p,  Tfacode2:~p~n",[TfaCode,Tfacode2]),
  case  Tfacode2 of
    TfaCode ->
      true;
    _ ->
      false
  end.


get_code()->
  totp:cons(<<"12345678901234567890">>).