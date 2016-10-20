-module(secret, [Id,Uid,Appid,Secret,Isbanded]).
-compile(export_all).

%% @doc
%% 随机码验证
%% @end
verify(TfaCode)->
  tfacode:verify(Secret,TfaCode).