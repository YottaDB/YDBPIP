/SCA/sca_gtm/extcall/libmqmapi.sl
ClConnect: void ClConnect(I:xc_char_t *,IO:xc_long_t *,IO:xc_long_t *)
ClDisconnect: void ClDisconnect(I:xc_long_t,IO:xc_long_t *)
ClExchmsg: void ClExchmsg(IO:xc_string_t *,IO:xc_string_t *,I:xc_string_t *,O:xc_char_t*[2001],I:xc_long_t,I:xc_long_t,IO:xc_long_t *)
ClSend: void ClSend(IO:xc_string_t *,I:xc_string_t *,I:xc_long_t,IO:xc_long_t *)
SrvConnect: void SrvConnect(I:xc_char_t *,IO:xc_long_t *,IO:xc_long_t *)
SrvDisconnect: void SrvDisconnect()
SrvGetMsg: void SrvGetMsg(IO:xc_string_t *,O:xc_char_t*[2001],I:xc_long_t,IO:xc_long_t *)
SrvReply: void SrvReply(IO:xc_string_t *,I:xc_string_t *,IO:xc_long_t *)
