# picolisp-libcurl

libcurl wrappers for picolisp

# Installation

1) Compile callbacks: `./compile_callbacks.sh`
2) Include in your project `[load "/path/to/picolisp-libcurl.l"]`  
3) Make a request


# Quick Example:

```
[load "./picolisp-libcurl.l"]
(with (curl-post
  "https://postman-echo.com/post"
  '("content-type: text/plain" "accept: */*")
  "postdata")
    (prinl (; This data)))
(bye)
```
