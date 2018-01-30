;;; init.el --- init file for personal configurations -*- lexical-binding: t; -*-
;;
;;; Copyright (c) 2015-2017 Boris Buliga
;;
;;; Author: Boris Buliga <boris@d12frosted.io>
;;
;;; URL: https://github.com/d12frosted/environment/emacs
;;
;;; License: GPLv3
;;
;;; Commentary:
;;
;; Naming conventions:
;;
;;   d12-...   public variables or non-interactive functions
;;   d12--...  private anything (non-interactive), not safe for direct use
;;   d12/...   an interactive function; safe for M-x or keybinding
;;   d12|...   hook function
;;   d12*...   advising functions
;;
;;; Code:

;; Without this comment emacs25 adds (package-initialize) here
;; (package-initialize)
(defconst package--initialized nil)

(defvar d12-debug-mode nil
  "Non nil enables debug mode. Whatever that means.")

;; setup emacs configuration
(setq user-init-file (file-truename (or load-file-name (buffer-file-name))))
(setq user-emacs-directory (file-name-directory user-init-file))

;; load some core features
(require 'd12-path (concat user-emacs-directory "core/d12-path"))
(require 'd12-spacemacs (concat user-emacs-directory "core/d12-spacemacs"))
(require 'd12-command-line (concat user-emacs-directory "core/d12-command-line"))

;; setup and load `custom-file'
(setq custom-file d12-path-custom-file)
(load custom-file t)

;; load `private.el' file containing all the sensitive data
(let ((private-file (concat d12-path-emacs-private "private.el")))
  (when (file-exists-p private-file)
    (load private-file)))

;; setup package-user-dir to allow seamless switch between emacs versions
(setq package-user-dir
      (file-name-as-directory
       (concat d12-path-emacs-cache "elpa/" emacs-version)))

;; load spacemacs
(d12-spacemacs-load
 d12-path-spacemacs-distr-home
 d12-path-spacemacs-distr-init-file
 (if d12-debug-mode
     d12-path-spacemacs-user-config-test-file
   d12-path-spacemacs-user-config-file))

;; The worst key binding ever! If I ever want to quit Emacs, I'd call my doctor.
(unbind-key "C-x C-c")

;; I use meta a lot, and command key is much easier to hit than option.
(setq mac-command-modifier 'meta
      mac-option-modifier  'none)

;; (defun d12*kill-emacs (orig-fun &optional arg)
;;   (when (y-or-n-p "Who dares to kill emacs? Are you sure?")
;;     (apply orig-fun arg)))
;; (advice-add 'kill-emacs :around #'d12*kill-emacs)

;; (defun d12*message (orig-fun format-string &rest args)
;;   (apply orig-fun (format "[%s] %s" (format-time-string "%H:%M:%S.%6N") format-string) args))
;; (advice-add 'message :around #'d12*message)

;;; init.el ends here