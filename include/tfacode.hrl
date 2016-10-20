-define(DB,db).
-define(tb_tfa_secret,tfa_secret).
-record(tfa_secret, {uid :: integer(), secret :: binary()}).

%% database table
-define(tb_users,users).
-define(tb_apps,apps).
-define(tb_secret,secret).


-define(server_error,999).%% 服务器内部错误


%% login code
-define(CodeForLogin,<<"CodeForLogin">>).
-define(login_sucess,1).%% 登录成功
-define(exit_sucess,1).%% 退出成功
-define(login_dismatch,2).%% 帐号不匹配
-define(login_user_none,3).%% 帐号不存在
-define(login_session_error,4).%% session error
-define(login_none,5).%% 未登录
-define(user_conflict,6).%% 用户冲突





-define(check_failed,<<"0">>).%% code验证失败
-define(check_sucess,<<"1">>).%% code验证成功
-define(isbanded_false,0).%% 未绑定二次验证
-define(isbanded_true,1).%% 已绑定二次验证
-define(closeverify_false,0).%% 解除二次验证失败
-define(closeverify_true,1).%% 解除二次验证成功

-define(safe_failed,0). %% token error
-define(safe_success,1).  %% success
-define(safe_app_none,2). %% appid error
-define(safe_user_none,3). %% uid error
-define(safe_code_error,4). %% code error




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
