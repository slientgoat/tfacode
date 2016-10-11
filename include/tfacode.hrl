-define(DB,db).
-define(tb_tfa_secret,tfa_secret).
-record(tfa_secret, {uid :: integer(), secret :: binary()}).


-define(login_sucess,1).%% 登录成功
-define(login_dismatch,2).%% 帐号不匹配
-define(login_user_none,3).%% 帐号不存在
-define(login_session_error,4).%% session error
-define(login_none,5).%% 未登录


-define(check_failed,0).%% code验证失败
-define(check_sucess,1).%% code验证成功


-define(register_failed,0).%% 注册失败
-define(register_sucess,1).%% 注册成功

-define(GV(K, P), proplists:get_value(K, P)).


%%-record(totp_extra_params,
%%{ hash_algo = sha :: hotp_hmac:hash_algo()
%%  , length    = 8   :: integer()  % Number of digits desired
%%  , time_zero = 0   :: non_neg_integer()
%%  , time_now        :: non_neg_integer()
%%  , time_step = 30  :: pos_integer()
%%}).
