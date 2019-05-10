#!/usr/bin/pil
#
#
#



[setq *LIBCURL* "/usr/lib/libcurl.so"]


[load "curl_enums.l"]
#[load "callbacks.l"]

[class +CurlContext]
[dm T ( _url _headers _method _data )
    (=: url _url)
    (=: headers _header)
    (=: method (or _method "GET"))
    (=: out_data _out_data)
    (=: in_data _in_data)
    (=: curl_error NIL)
]


[de curl-debug ( func_name varslist )
    (prinl
        "Entering: " func_name "\n"
        "Parameters:\n"
        (when varslist
            (mapcar '((X) (pack (car X) " -- " (cdr X) "\n")) varslist) ) ) ]


[de curl-global-init ()
    (when *CURL-DEBUG*
        (curl-debug "curl-global-init"))
    # CURL curl_global_init(void)
    (native *LIBCURL* "curl_global_init" 'N NIL) ]


[de curl-global-cleanup ()
    (when *CURL-DEBUG*
        (curl-debug "curl_global_cleanup"))
    # ?? curl_global_cleanup(void)
    (native *LIBCURL* "curl_global_cleanup" NIL NIL) ]


[de curl-easy-init ()
    (when *CURL-DEBUG*
        (curl-debug "curl-easy-init"))
    # CURL curl_easy_init(void)
    (native *LIBCURL* "curl_easy_init" 'N NIL) ]


[de curl-easy-setopt ( curl curl-opt curl-opt-val )
    (when *CURL-DEBUG*
        (curl-debug "curl-easy-setopt"
            (list
                (cons 'curl curl)
                (cons 'curl-opt curl-opt)
                (cons 'curl-opt-val curl-opt-val))))
    # CURLCode curl_easy_setopt(CURL curl, CURLOPT curlopt, ? curl-opt-val)
    (native *LIBCURL* "curl_easy_setopt" 'I curl curl-opt curl-opt-val) ]


[de curl-easy-getinfo ( curl curl-info curl-info-dest )
    (when *CURL-DEBUG*
        (curl-debug "curl-easy-getinfo"
            (list
                (cons 'curl curl)
                (cons 'curl-info curl-info)
                (cons 'curl-info-dest curl-info-dest))))
    # CURLCODE curl_easy_getinfo(CURL curl, CURLOPT curl-opt, ? *dst)
    (native *LIBCURL* "curl_easy_getinfo" 'I curl curl-info curl-info-dest) ]


[de curl-easy-perform ( curl )
    (when *CURL-DEBUG*
        (curl-debug "curl-easy-perform"
            (list
                (cons 'curl curl))))
    # CURLCODE curl_easy_perform(CURL curl)
    (native *LIBCURL* "curl_easy_perform" 'I curl) ]


[de curl-easy-cleanup ( curl )
    (when *CURL-DEBUG*
        (curl-debug "curl-easy-cleanup"
            (list
                (cons 'curl curl))))
    (native *LIBCURL* "curl_easy_cleanup" NIL curl) ]


[de curl-easy-strerror ( curlcode )
    (native *LIBCURL* "curl_easy_strerror" 'S curlcode) ]


[de curl-quick-defaults ( curl )
    (curl-easy-setopt curl CURLOPT_USERAGENT "pilcurl_7.65.0-DEV") ]


[de curl-context ( context )
    (when *CURL-DEBUG*
        (curl-debug "curl-context"
         (list
             (cons 'url (; context url))
             (cons 'headers (; context headers))
             (cons 'method (; context method))
             (cons 'data (; context data)))))
    (let (
          tmpcurl (curl-easy-init)
          outfile "/tmp/erik"
         )
        (curl-easy-setopt tmpcurl CURLOPT_FOLLOWLOCATION 1)
        (curl-easy-setopt tmpcurl CURLOPT_BUFFERSIZE 512000)
        (curl-easy-setopt tmpcurl CURLOPT_URL (; context url))
        (curl-easy-setopt tmpcurl CURLOPT_WRITEDATA (native *LIBCURL* "fopen" 'N outfile "w"))
        (curl-easy-setopt tmpcurl CURLOPT_WRITEFUNCTION 0)
        # GET
        (when (= "GET" (; context method))
            (curl-easy-setopt tmpcurl CURLOPT_HTTPGET 1))
        # POST
        (when (= "POST" (; context method))
            (curl-easy-setopt tmpcurl CURLOPT_POST 1)
            (curl-easy-setopt tmpcurl CURLOPT_COPYPOSTFIELDS (; context out_data)))
        # PUT
        (when (= "PUT" (; context method))
            (curl-easy-setopt tmpcurl CURLOPT_PUT 1))
        # DELETE
        #(when (= "DELETE" (; context method))
        #    (curl-easy-setopt tmpcurl CURLOPT_))

        (prinl "outfile: " outfile)
        (prinl (curl-easy-strerror (curl-easy-perform tmpcurl)))
        (curl-easy-cleanup tmpcurl)
    )
]



(setq *CURL-DEBUG* T)
(setq *CURL* (curl-easy-init))

#(setq ctx (new '(+CurlContext) "https://api.binance.com/api/v1/exchangeInfo" NIL NIL NIL))
#(curl-context ctx)

(setq databuffer (native "./pilcurl_callbacks.so" "buffer_new" 'N 10000))
(setq outdata (native *LIBCURL* "fopen" 'N "/tmp/curldata.txt" "w"))
(setq callback (native "./pilcurl_callbacks.so" "get_callback" 'N NIL))

(prinl "databuf : " databuffer)
(prinl "outdata : " outdata)
(prinl "callback: " callback)

(curl-easy-setopt *CURL* CURLOPT_URL "https://api.binance.com/api/v1/exchangeInfo")
(curl-easy-setopt *CURL* CURLOPT_USERAGENT "pil_agent_0.0")
(curl-easy-setopt *CURL* CURLOPT_WRITEDATA databuffer)
(curl-easy-setopt *CURL* CURLOPT_WRITEFUNCTION callback)
(curl-easy-perform *CURL*)

(prinl (struct databuffer '(I I S)))

(curl-easy-cleanup *CURL*)


