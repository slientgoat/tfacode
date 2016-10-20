%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 十一月 2015 11:13
%%%-------------------------------------------------------------------
-module(config).
-author("Administrator").

-define(Appname, tfacode).

%% API
-compile(export_all).


%% 获取域名
get_domain() ->
  application:get_env(?Appname, domain, "192.168.10.58").

%% 获取port
get_port() ->
  application:get_env(simple_bridge, port, 8001).

%% 获取邮箱
get_mail() ->
  application:get_env(?Appname, mail, "mail@blizzmi.com").

get_url() ->
  Domain = list_to_binary(config:get_domain()),
  Port = integer_to_binary(config:get_port()),
  <<"http://",Domain/binary, ":", Port/binary>>.