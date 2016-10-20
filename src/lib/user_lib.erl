-module(user_lib).
-compile(export_all).

-include("tfacode.hrl").
%% Tests for presence and validity of session.
%% Forces login on failure.
require_login(Req, SessionID) ->
  try
    UserId = Req:cookie("user_id"),
    case UserId of
      undefined ->
        throw({redirect, "/auth/login"});
      _ ->
        ok
    end,

    User = boss_db:find(UserId),
    case User of
      undefined ->
        throw({error, [{?CodeForLogin, ?login_none}]});
      [] ->
        throw({error, [{?CodeForLogin, ?login_user_none}]});
      _ ->
        ok
    end,

    case User:session_identifier() =:= Req:cookie("session_id") of
      false ->
        throw({error, [{?CodeForLogin, ?login_session_error}]});
      true ->
        ok
    end,

    case User:session() of
      SessionID ->
        {ok, User};
      _ ->
        throw({error, [{?CodeForLogin, ?user_conflict}]})
    end
  catch
    {redirect, URL} ->
      {redirect, URL};
    {error, Msg} ->
      lager:warning("~p~n",[Msg]),
      {redirect, "/auth/login"};
    _:_Why ->
      io:format("Error！！！ Why[~p] stack[~p]~n", [_Why, erlang:get_stacktrace()]),
      {json, [{<<"status">>, ?server_error}]}
  end.
%%  case Req:cookie("user_id") of
%%    undefined ->
%%      {redirect, "/auth/login"};
%%    Id ->
%%      case boss_db:find(Id) of
%%        undefined ->
%%          {json, [{<<"status">>, ?login_none}]};
%%        [] ->
%%          {json, [{<<"status">>, ?login_user_none}]};
%%        User ->
%%          case User:session_identifier() =:= Req:cookie("session_id") of
%%            false -> {json, [{<<"status">>, ?login_session_error}]};
%%            true -> {ok, User}
%%          end
%%      end
%%  end.

compare_password(PasswordAttempt, Password) ->
  PasswordAttempt =:= Password.



%% @doc
%% 解析
%% Body like <<"username=Test5&password=123456">>
%% @end
-spec parse(Body::binary()) -> ok.
parse(Body) ->
  mochiweb_util:parse_qs(Body).



