;;; init-ctags.el --- frying ctags -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2020 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 26 May 2020
;;
;; URL:
;;
;; License: GPLv3
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;; Code:

(require 'init-package)

(defvar +ctags-file-name "TAGS"
  "Location for tags file produced by 'ctags'.")

(defun +ctags-create (dir-name lang)
  "Generate tags file in DIR-NAME.

Only files matching LANG are processed.

Returns path to generated file."
  (interactive)
  (shell-command
   (format "%s -f %s/%s -e -R %s --languages=%s"
           (executable-find "ctags")
           dir-name
           +ctags-file-name
           (directory-file-name dir-name)
           lang))
  (expand-file-name +ctags-file-name dir-name))

(defun +ctags-enable-auto-update ()
  "Enable TAGS file automatic update."
  (add-hook 'after-save-hook
            'counsel-etags-update-tags-force 'append 'local))

(use-package etags
  :straight (:type built-in)
  :defer t
  :init
  (setq tags-revert-without-query t))

(use-package counsel-etags
  :defer t
  :init
  (setq counsel-etags-update-interval 10)
  :config
  (push "build" counsel-etags-ignore-directories))

(use-package company-ctags
  :defer t)

(provide 'init-ctags)
;;; init-ctags.el ends here