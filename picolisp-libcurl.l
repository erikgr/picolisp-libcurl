#!/usr/bin/pil
#
# libcurl wrappers
#
# 2019 :: EJG


[setq *LIBCURL* "/usr/lib/libcurl.so"]
[setq *CALLBACKS* "./pil_libcurl_callbacks.so"]
[setq *GARBAGE* NIL]


[load "curl_enums.l"]


[class +HTTPResponse]
[dm T ()
    (=: data NIL)
    (=: info-http-code (native *CALLBACKS* "get_long_arr" 'N 1) ) ]

(setq struct_simple_buffer_t
    '(I I S))


[de curl-global-init ()
    (native *LIBCURL* "curl_global_init" 'N NIL) ]

[de curl-global-cleanup ()
    (native *LIBCURL* "curl_global_cleanup" NIL NIL) ]

[de curl-easy-init ()
    (native *LIBCURL* "curl_easy_init" 'N NIL) ]

[de curl-easy-setopt ( curl curl-opt curl-opt-val )
    (unless curl-opt
        (prinl "curl_easy_setopt: bad opt " curl-opt)
        (throw 'invalid-opt-exception))
    (native *LIBCURL* "curl_easy_setopt" 'I curl curl-opt curl-opt-val) ]

[de curl-easy-getinfo ( curl curl-info curl-info-dest )
    (unless curl-info
        (prinl "curl_easy_getinfo: bad opt")
        (throw 'invalid-opt-exception))
    (native *LIBCURL* "curl_easy_getinfo" 'I curl curl-info curl-info-dest) ]

[de curl-easy-perform ( curl )
    (unless curl
        (throw 'null-pointer-exception))
    (native *LIBCURL* "curl_easy_perform" 'I curl) ]

[de curl-easy-cleanup ( curl )
    (native *LIBCURL* "curl_easy_cleanup" NIL curl) ]

[de curl-easy-strerror ( curlcode )
    (native *LIBCURL* "curl_easy_strerror" 'S curlcode) ]

[de curl-easy-urlencode ( str )
    (native *LIBCURL* "curl_easy_escape" 'S str) ]

[de curl_easy_urldecode ( str )
    (native *LIBCURL* "curl_easy_unescape" 'S str) ]

[de curl-easy-version ()
    (native *LIBCURL* "curl_version" 'S) ]


[de curl-easy-getdate ( datestr )
    (native *LIBCURL* "curl_getdate" 'I datestr 0) ]

[de curl-slist-append ( container data )
    # container can be null (0) to create new list.
    (let (ptr (native *LIBCURL* "curl_slist_append" 'N container data))
        (conc *GARBAGE* (cons 'malloc ptr))
        ptr ) ]

[de curl-slist-free-all ( container )
    (unless container
        (throw 'null-pointer-exception))
    (native *LIBCURL* "curl_slist_free_all" NIL container) ]

# container must be freed with curl_slist_free_all
[de curl-headers ( headers )
    (let (container (curl-slist-append 0 "Accept:"))
        (for H headers
            (setq container (native *LIBCURL* "curl_slist_append" 'N container H)))
        (unless container
            (throw 'null-pointer-exception))
        container ) ]

[de curl-get ( url headers )
    (let (tmpcurl (curl-easy-init)
        data-buffer (native *CALLBACKS* "buffer_new" 'N 1024)
        tmp-headers (when headers (curl-headers headers))
        http-response (new '(+HTTPResponse)))
            (curl-easy-setopt tmpcurl CURLOPT_URL url)
            (curl-easy-setopt tmpcurl CURLOPT_WRITEDATA data-buffer)
            (curl-easy-setopt tmpcurl CURLOPT_WRITEFUNCTION (native *CALLBACKS* "get_callback" 'N))
            (when tmp-headers (curl-easy-setopt tmpcurl CURLOPT_HTTPHEADER tmp-headers))
            (curl-easy-setopt tmpcurl CURLOPT_FOLLOWLOCATION 1)
            (curl-easy-getinfo tmpcurl CURLINFO_HTTP_CODE (; http-restponse info-http-code))
            (put http-response 'curl-msg (curl-easy-strerror (curl-easy-perform tmpcurl)))
            (put http-response 'data (caddr (struct data-buffer struct_simple_buffer_t)))
            (when tmp-headers (curl-slist-free-all tmp-headers))
            (native *CALLBACKS* "free" 'I data-buffer)
            (curl-easy-cleanup tmpcurl)
        http-response ) ]

[de curl-post ( url headers data )
    (let (tmpcurl (curl-easy-init)
        data-buffer (native *CALLBACKS* "buffer_new" 'N 1024)
        tmp-headers (when headers (curl-headers headers))
        http-response (new '(+HTTPResponse)))
            (curl-easy-setopt tmpcurl CURLOPT_URL url)
            (curl-easy-setopt tmpcurl CURLOPT_CUSTOMREQUEST "POST")
            (curl-easy-setopt tmpcurl CURLOPT_WRITEDATA data-buffer)
            (curl-easy-setopt tmpcurl CURLOPT_WRITEFUNCTION (native *CALLBACKS* "get_callback" 'N))
            (when data
                (curl-easy-setopt tmpcurl CURLOPT_POSTFIELDSIZE (length data))
                (curl-easy-setopt tmpcurl CURLOPT_COPYPOSTFIELDS data))
            (when tmp-headers
                (curl-easy-setopt tmpcurl CURLOPT_HTTPHEADER tmp-headers))
            (curl-easy-getinfo tmpcurl CURLINFO_HTTP_CODE (; http-response info-http-code))
            (put http-response 'curl-msg (curl-easy-strerror (curl-easy-perform tmpcurl)))
            (put http-response 'data (caddr (struct data-buffer struct_simple_buffer_t)))
            (when tmp-headers (curl-slist-free-all tmp-headers))
            (native *CALLBACKS* "free" 'I data-buffer)
            (curl-easy-cleanup tmpcurl)
        http-response ) ]

[de curl-put ( url headers data )
    (let (tmpcurl (curl-easy-init)
        data-buffer (native *CALLBACKS* "buffer_new" 'N 1024)
        tmp-headers (when headers (curl-headers headers))
        http-response (new '(HTTPResponse)))
            (curl-easy-setopt tmpcurl CURLOPT_URL url)
            (curl-easy-setopt tmpcurl CURLOPT_CUSTOMREQUEST "PUT")
            (curl-easy-setopt tmpcurl CURLOPT_WRITEDATA data-buffer)
            (curl-easy-setopt tmpcurl CURLOPT_WRITEFUNCTION (native *CALLBACKS* "get_callback" 'N))
            (when headers
                (curl-easy-setopt CURLOPT_HTTPHEADER tmp-headers))
            (when data
                (curl-easy-setopt CURLOPT_POSTFIELDSIZE (length data))
                (curl-easy-setopt tmpcurl CURLOPT_COPYPOSTFIELDS data))
            (curl-easy-getinfo tmpcurl CURLINFO_HTTP_CODE (; http-response info-http-code))
            (put http-response 'curl-msg (curl-easy-strerror (curl-easy-perform tmpcurl)))
            (put http-response 'data (caddr (struct data-buffer struct_simple_buffer_t)))
            (when tmp-headers (curl-slist-free-all tmp-headers))
            (curl-easy-cleanup tmpcurl)
        http-response ) ]

[de curl-delete ( url headers data )
    (let (tmpcurl (curl-easy-init)
        data-buffer (native *CALLBACKS* "buffer_new" 'N 1024)
        tmp-headers (when headers (curl-headers headers))
        http-response (new '(+HTTPResponse)))
            (curl-easy-setopt tmpcurl CURLOPT_URL url)
            (curl-easy-setopt tmpcurl CURLOPT_CUSTOMREQUEST "DELETE")
            (curl-easy-setopt tmpcurl CURLOPT_WRITEDATA data-buffer)
            (curl-easy-setopt tmpcurl CURLOPT_WRITEFUNCTION (native *CALLBACKS* "get_callback" 'N))
            (when tmp-headers
                (curl-easy-setopt tmpcurl CURLOPT_HTTPHEADER tmp-headers))
            (when data
                (curl-easy-setopt CURLOPT_POSTFIELDSIZE (length data))
                (curl-easy-setopt tmpcurl CURLOPT_COPYPOSTFIELDS data))
            (curl-easy-setopt tmpcurl CURLOPT_FOLLOWLOCATION 1)
            (curl-easy-getinfo tmpcurl CURLINFO_HTTP_CODE (; http-restponse info-http-code))
            (put http-response 'curl-msg (curl-easy-strerror (curl-easy-perform tmpcurl)))
            (put http-response 'data (caddr (struct data-buffer struct_simple_buffer_t)))
            (when tmp-headers (curl-slist-free-all tmp-headers))
            (native *CALLBACKS* "free" 'I data-buffer)
            (curl-easy-cleanup tmpcurl)
        http-response ) ]
