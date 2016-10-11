-module(user_lib).
-compile(export_all).

-include("tfacode.hrl").
%% Tests for presence and validity of session.
%% Forces login on failure.
require_login(Req) ->
  case Req:cookie("user_id") of
    undefined -> {redirect, "/user/login"};
    Id ->
      case boss_db:find(Id) of
        undefined -> {json,[{<<"status">>, ?login_none}]};
        User ->
          case User:session_identifier() =:= Req:cookie("session_id") of
            false -> {json,[{<<"status">>, ?login_session_error}]};
            true -> {ok, User}
          end
      end
  end.

compare_password(PasswordAttempt, Password) ->
  PasswordAttempt =:= Password.