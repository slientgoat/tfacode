%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 十月 2016 11:05
%%%-------------------------------------------------------------------
-module(tfacode_index_controller, [Req]).
-compile(export_all).
-include("tfacode.hrl").

before_(_) ->
  user_lib:require_login(Req).

index('GET', [], User) ->
  {json, [{<<"status">>, ?login_sucess}, {<<"secret">>, User:secret()}]}.

