;;; bootstrap.el ---  Bootstrap personal configurations -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2015-2021 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;; Version: 0.1
;; Package-Requires: ((emacs "27.1"))
;;
;; Created: 08 Feb 2021
;;
;; URL: https://github.com/d12frosted/environment/emacs
;;
;; License: GPLv3
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see
;; <http://www.gnu.org/licenses/>.
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; This script simply loads all files from Lisp directory thus
;; enforcing installation of dependencies. The import important bit
;; here is setting `bootstrap-p' to `t'.
;;
;;; Code:

(require 'seq)
(require 'subr-x)

;; Since we might be running in CI or other environments, stick to
;; XDG_CONFIG_HOME value if possible.
(defvar emacs-home
  (if-let ((xdg (getenv "XDG_CONFIG_HOME")))
      (expand-file-name "emacs/" xdg)
    user-emacs-directory))

;; Add Lisp directory to `load-path'.
(add-to-list 'load-path (expand-file-name "lisp" emacs-home))

(setq-default
 elpa-bootstrap-p t
 load-prefer-newer t)

(seq-map
 (lambda (f)
   (when (string-suffix-p ".el" f)
     (setq f (string-remove-suffix ".el" f))
     (unless (or (string-suffix-p "autoloads" f)
                 (string-prefix-p "flycheck_" f))
       (let ((m (intern f)))
         (message "loading %s" m)
         (require m)))))
 (directory-files (expand-file-name "lisp/" emacs-home)))

(provide 'bootstrap)
;;; bootstrap.el ends here
