(defvar +http-endline+ (concatenate 'string (list #\return #\linefeed)))

(defun http-line (line)
  (concatenate 'string line +http-endline+))

(defvar *http-header-get* (http-line "GET /echo HTTP/1.1"))
(defvar *http-header-host* (http-line "Host: localhost:8080"))
(defvar *http-user-agent* (http-line "User-Agent: trivial-websockets/1"))
(defvar *http-header-connection* (http-line "Connection: Upgrade"))
(defvar *http-sec-websocket-key* (http-line "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ=="))
(defvar *sec-websocket-protocol* (http-line "Sec-WebSocket-Protocol: chat"))
(defvar *sec-websocket-version* (http-line "Sec-WebSocket-Version: 13"))
(defvar *http-header-upgrade* (http-line "Upgrade: websocket"))
(defvar *http-header-accept* (http-line "Accept: */*"))
(defvar *http-header* (http-line (concatenate 'string
                                              *http-header-get*
                                              *http-header-host*
                                              *http-user-agent*
                                              *http-header-connection*
                                              *http-header-upgrade*
                                              *http-sec-websocket-key*
                                              *http-header-accept*
                                              *sec-websocket-protocol*
                                              *sec-websocket-version*)))

(defun read-http (stream)
  (flet ((buffer-char (char buffer)
           (setf (aref buffer 0) (aref buffer 1))
           (setf (aref buffer 1) char)
           buffer))
    (let (headers)
      (do ((char-buffer (make-array 2 :element-type 'character) (buffer-char c char-buffer))
           (c (peek-char nil stream) (peek-char nil stream))
           (header nil)
           (line-feed nil))

          ((and line-feed (string= char-buffer +http-endline+)))
        
        (if (string= char-buffer +http-endline+)
            (progn
              (setf line-feed t)
              (push header headers)
              (setf header nil))
            (unless (member c '(#\return #\linefeed))
              (setf line-feed nil)))

        (if (member c '(#\return #\linefeed))
            (read-char stream)
            (progn 
              (setf header (concatenate 'string header (string (read-char stream)))))))
      headers)))

(defun something ()
  (usocket:with-client-socket (socket stream "localhost" '8080
                                      :element-type '(unsigned-byte 8))
    (setf stream (flexi-streams:make-flexi-stream stream))
    (write-string *http-header* stream)
    (force-output stream)
    (usocket:wait-for-input socket)
    (print (read-http stream))
    (print (read-ws stream))
    (send-string "Hello from a client in common lisp!" stream)))
