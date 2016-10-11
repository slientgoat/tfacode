-module(users, [Id,Username,Password,Secret,Appid,Appname]).
-compile(export_all).

-define(SETEC_ASTRONOMY, "Too many secrets").

session_identifier() ->
  mochihex:to_hex(erlang:md5(?SETEC_ASTRONOMY ++ Id)).

check_password(PasswordAttempt) ->
  user_lib:compare_password(PasswordAttempt, Password).


%% cookies
set_login_cookies() ->
  L =  [ mochiweb_cookies:cookie("user_id", Id, [{path, "/"}]),
    mochiweb_cookies:cookie("session_id", session_identifier(), [{path, "/"}]) ],
  L.


check_code(TfaCode)->
  tfacode:check_code(Secret,binary_to_integer(TfaCode)).