;; google-contacts-mew.el
;; -*- coding: utf-8 -*-

;; Author: Takashi Masuda <masutaka@nifty.com>
;; License: Public domain, use at own risk, no warranties of any kind.

;; Version 1.1
;; - Support for overwriting fetched contacts with Mew Addrbook.

;; Basic usage:
;; - Set variables `google-contacts-email' and `google-contacts-passwd'.
;; - Call function `google-contacts-mew-renew-addrbook'.
;;   It returns a simple Lisp structure which should contain all your contacts.

;; Install:
;; Put this file into load-path'ed directory, and byte compile it if
;; desired. And put the following expression into your ~/.mew.el.
;;
;; (require 'google-contacts-mew)
;; and
;; M-x google-contacts-mew-renew-addrbook
;;
;; If you renew your Mew Addrbook when do \\[mew-status-update].
;;
;; (setq google-contacts-mew-renew-addrbook-when-status-update t)

;; Be careful with the `google-contacts-mew-update' function. It will
;; replace all contacts you have in your Mew address book for which there
;; exists a Google contact, with only data from the Google contact. This is
;; because I mostly edit contacts in GMail and just export to Mew when
;; necessary, using this function. Also bear in mind that this is *alpha* code,
;; tailored to my own needs. It was written using Emacs 23, your milage may vary
;; if you're using a different Emacs flavour or version.
;;
;;** BACKUP YOUR Mew Addrbook BEFORE TESTING THIS FUNCTION **

(require 'google-contacts)

(defvar google-contacts-mew-renew-addrbook-when-status-update nil
  "*If non-nil, `mew-addrbook-file' will rewrite when do \\[mew-status-update]")

(defun google-contacts-mew-renew-addrbook ()
  "Gmail のアドレス帳を `mew-addrbook-file' に上書きします。

Mew Addrbook の「個人情報」の定義は以下のとおり。
<shortname> <address1>[, <address2>, <address3>,...] <nickname> <fullname>

このように対応させます。
--------------+----------------------------
 Mew Addrbook | (google-contacts-retrieve)
--------------+----------------------------
 shortname    | aka
 address1~n   | emails
 nickname     | name
 fullname     | name
--------------+----------------------------
"
  (interactive)
  (with-temp-buffer
    (dolist (contact (google-contacts-retrieve))
      (let ((shortname (cdr (assoc 'aka contact)))
	    (emails (cadr (assoc 'emails contact)))
	    (name (cdr (assoc 'name contact))))
	(when emails
	  (insert (if shortname shortname "*") "\t"
		  (mapconcat 'identity emails ", "))
	  (if name (insert "\t" name "\t" name))
	  (insert "\n"))))
    (write-region
     (point-min) (point-max)
     (expand-file-name mew-addrbook-file mew-conf-path))))

(defadvice mew-addrbook-setup
  (before google-contacts-mew activate)
  (if google-contacts-mew-renew-addrbook-when-status-update
      (google-contacts-mew-renew-addrbook)))

(provide 'google-contacts-mew)
