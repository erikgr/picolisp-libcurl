#
#
#
#

(load "picolisp-libcurl.l")


[de http-get-test ()
    (with (curl-get "https://postman-echo.com/get?my-get-arg=my-get-val"
	'("X-my-header: my-header-val"))
	(prinl
	    "Response: \n\n" (; This data) "\n\n"
	    "Curl message : " (; This curl-msg) )
    This ) ]


[de http-post-text-plain-test ()
    (with (curl-post "https://postman-echo.com/post?my-get-arg=my-get-val"
	'("Content-Type: text/plain") "POST DATA STRING" )
	    (prinl
		"Response: \n\n" (; This data) "\n\n"
		"Curl message: " (; This curl-msg) )
    This ) ]


[de http-post-application-json-test ()
    (with (curl-post "https://postman-echo.com/post?my-get-arg=my-get-val"
	'("Content-Type: application/json") "{\"json_arg\":\"json_val\"}" )
	    (prinl
		"Response: \n\n" (; This data) "\n\n"
		"Curl message: "(; This curl-msg) )
    This ) ]


[de http-put-test ()
    (with (curl-put "https://postman-echo.com/put"
	'("Content-Type: text/plain") "PUTDATA" )
	    (prinl
		"Response: \n\n" (; This data) "\n\n"
		"Curl message: "(; This curl-msg) )
    This ) ]


[de http-request-headers-test ()
    (with (curl-get "https://postman-echo.com/headers"
	'("X-fish-bone: ><)))*>"))
	    (prinl
		"Response: \n\n" (; This data) "\n\n"
		"Curl message: " (; This curl-msg))
    This ) ]

[de http-response-headers-test ()
    (with (curl-get "https://postman-echo.com/response-headers?response_header1=response_val1&repsonse_header2=response_val2"
	NIL)
	    (prinl
		"Response: \n\n" (; This data) "\n\n"
		"Curl message: " (; This curl-msg))
    This ) ]


(prinl "-----------------------------------------")
(prinl ">> Testing HTTP GET")
(prinl "")
(setq resp-get (http-get-test))
(prinl "")
(prinl "-----------------------------------------")
(prinl ">> Testing HTTP POST (text/plain)")
(prinl "")
(setq resp-post-text-plain (http-post-text-plain-test))
(prinl "")
(prinl "-----------------------------------------")
(prinl ">> Testing HTTP POST (application/json)")
(prinl "")
(setq resp-post-application-json (http-post-application-json-test))
(prinl "")
(prinl "-----------------------------------------")
(prinl ">> Testing HTTP PUT")
(prinl "")
(setq resp-put (http-put-test))
(prinl "")
(prinl "-----------------------------------------")
(prinl ">> Testing HTTP HEADERS (request)")
(prinl "")
(setq resp-get-request-headers (http-request-headers-test))
(prinl "")
(prinl "-----------------------------------------")
(prinl ">> Testing HTTP HEADERS (response)")
(prinl "")
(setq resp-get-response-headers (http-response-headers-test))
(prinl "")