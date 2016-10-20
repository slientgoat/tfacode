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
  check_code/2
]).

-export([reg/2]).
-export([generate_qrcode/2]).
-export([generate_qrcode/3]).


%% test func
-export([get_code/1]).
-compile(export_all).

%% @doc
%% 数据库初始化
%% @end
-spec init_db() -> {atomic, ok}|{aborted, {already_exists, ?tb_tfa_secret}}.
init_db() ->
  Res = mnesia:create_table(?tb_tfa_secret, [{disc_copies, [node()]}, {attributes, record_info(fields, ?tb_tfa_secret)}]),
  lager:info("create table (~p): ~p~n", [Res, [?tb_tfa_secret, {attributes, ?tb_tfa_secret}]]),
  Res.




%% @doc
%% 授权验证
%% @end
-spec check_token(Secret :: binary(), TfaCode :: integer()) -> boolean().
check_token(Token,Token2) ->
  lager:debug("Server Token:~p,  client Token2:~p~n", [Token2,Token]),
  case Token2 of
    Token ->
      true;
    _ ->
      false
  end.


%% @doc
%% 随机码验证
%% @end
-spec check_code(Secret :: binary(), TfaCode :: integer()) -> boolean().
check_code(Secret, TfaCode) ->
  Tfacode2 = totp:cons(Secret),
  lager:debug("Server Tfacode:~p,  Clinet TfaCode:~p~n", [Tfacode2,TfaCode]),
  case Tfacode2 of
    TfaCode ->
      true;
    _ ->
      false
  end.





%% @doc
%% 获取secret
%% @end
-spec get_secret(UID :: integer()) -> binary().
get_secret(UID) ->
  mnesia:dirty_read(?tb_tfa_secret, UID).




%% @doc
%% 设置secret
%% @end
-spec set_secret(UID :: integer(), Secret :: binary()) -> ok.
set_secret(UID, Secret) ->
  mnesia:dirty_write(?tb_tfa_secret, #tfa_secret{uid = UID, secret = Secret}).







get_code(Secret) ->
  Secret2 = crypto:sha(Secret),
  totp:cons(Secret2).


generate_secret()->
  Secret = crypto:sha(integer_to_binary(rand:uniform(99999999999999999))),
  base32:encode(Secret).


-spec generate_qrcode(Secret :: binary(),Username::binary()) -> binary().
generate_qrcode(Secret,Username) ->
%%  Mail = list_to_binary(config:get_mail()),
  PasscodeBase32 = base32:encode(Secret),
  Token = <<"otpauth://totp/", "BLIZZMI:", Username/binary, "?&secret=", PasscodeBase32/binary>>,
  QRCode = qrcode:encode(Token),
  Image = qrcode_demo:simple_png_encode(QRCode),
  Image.


-spec generate_qrcode(Appid :: binary(), Uid :: binary(), Secret :: binary()) -> binary().
generate_qrcode(Appid, Uid, Secret) ->
  Token = <<"otpauth://totp/", Appid/binary, ":", Uid/binary, "?&secret=", Secret/binary>>,
  QRCode = qrcode:encode(Token),
  Image = qrcode_demo:simple_png_encode(QRCode),
  Image.


%% @doc
%% 随机码验证
%% @end
-spec verify(Secret :: binary(), TfaCode :: integer()) -> boolean().
verify(Secret, TfaCode) ->
  NewSecret = base32:decode(Secret),
  Tfacode2 = totp:cons(NewSecret),
  lager:debug("Server Tfacode:~p,  Clinet TfaCode:~p~n", [Tfacode2,TfaCode]),
  case Tfacode2 of
    TfaCode ->
      true;
    _ ->
      false
  end.





%% test for register
reg(_Pre, 0) ->
  ok;

reg(Pre, Max) ->
  I = integer_to_binary(Max),
  Username = <<Pre/binary, I/binary>>,
  Password = <<"123456">>,
  Secret = crypto:sha(integer_to_binary(rand:uniform(99999999999999999))),
  Appname = <<"blizzmi">>,
  Appid = <<"1">>,
  User = users:new(id, Username, Password, Secret, Appid, Appname, ?isbanded_false,<<>>),
  Result = User:save(),
  lager:debug("register result:~p~n", [Result]),
  reg(Pre, Max - 1).



%% test for register
regapps(_Pre, 0) ->
  ok;

regapps(Pre, Max) ->
  I = integer_to_binary(Max),
  Appid = <<Pre/binary, I/binary>>,
  Token = <<"123456">>,
  App = ?tb_apps:new(id,Appid,Appid,Token),
  Result = App:save(),
  lager:debug("register result:~p~n", [Result]),
  regapps(Pre, Max - 1).