;;; lang/org/autoload/org.el -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2018 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 09 Dec 2018
;;
;; URL: https://github.com/d12frosted/environment/emacs
;;
;; License: GPLv3
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;; Code:

;;;###autoload
(defmacro +org-with-file (file &rest body)
  `(with-current-buffer (find-file-noselect ,file)
     ,@body))

;;;###autoload
(defun +org-parent-id ()
  "Return parent id of entry at point."
  (save-excursion
    (when (org-up-heading-safe)
      (org-id-get-create))))
