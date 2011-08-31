;; google-contacts-mew.el
;; -*- coding: utf-8 -*-

;; Author: Takashi Masuda <masutaka@nifty.com>
;; License: Public domain, use at own risk, no warranties of any kind.

;; Install:
;; Put this file into load-path'ed directory, and byte compile it if
;; desired. And put the following expression into your ~/.mew.el.
;;
;; (require 'google-contacts-mew)
;; (setq google-contacts-email "Your GMail address")
;; and
;; M-x google-contacts-mew-renew-addrbook
;;
;; If you want to renew your Mew Addrbook when you do \\[mew-status-update].
;;
;; (setq google-contacts-mew-renew-when-status-update t)

;;** BACKUP YOUR Mew Addrbook BEFORE TESTING THIS FUNCTION **

(require 'google-contacts)

(defvar google-contacts-mew-renew-when-status-update nil
  "*If *non-nil*, `mew-addrbook-file' will rewrite when do \\[mew-status-update]")

(defvar google-contacts-mew-ask t
  "*If *non-nil*, ask whether or not you really renew your Mew addrbook.")

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
  (if (and google-contacts-mew-ask
	   (not (y-or-n-p "Renew Your Mew addrbook? ")))
      (message "Your Mew addrbook is not renewed.")
    (condition-case err
	(let ((google-contacts-email
	       (or google-contacts-email (read-string "GMail address: ")))
	      (google-contacts-passwd
	       (or google-contacts-passwd (read-passwd "GMail password: "))))
	  (if (or (string= google-contacts-email "")
		  (string= google-contacts-passwd ""))
	      (message "Your Gmail Address or Password are empty.")
	    (with-temp-buffer
	      (dolist (contact (google-contacts-retrieve))
		(let ((shortname (cdr (assoc 'aka contact)))
		      (emails (cadr (assoc 'emails contact)))
		      (name (cdr (assoc 'name contact))))
		  (when emails
		    (insert (if shortname shortname "*") "\t"
			    (mapconcat 'identity emails ", "))
		    (if name (insert "\t\"" name "\"\t\"" name "\""))
		    (insert "\n"))))
	      (write-region
	       (point-min) (point-max)
	       (expand-file-name mew-addrbook-file mew-conf-path)))))
      (quit nil))))

(defadvice mew-addrbook-setup
  (before google-contacts-mew activate)
  (if google-contacts-mew-renew-when-status-update
      (google-contacts-mew-renew-addrbook)))

(provide 'google-contacts-mew)
