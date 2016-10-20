-module(apps, [Id,Appid,Appname,Token]).
-compile(export_all).

%% @doc
%% 权限认证
%% @end
checkAuth(Token2)->
  Token =:= Token2.

