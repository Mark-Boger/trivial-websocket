(in-package :trivial-websockets)

(defvar +fin+ #x80)
(defvar +rsv1+ #x40)
(defvar +rsv2+ #x20)
(defvar +rsv3+ #x10)
(defvar +mask+ #x80)
(defvar +len+ #x7F)
(defvar +op+ #x0F)
