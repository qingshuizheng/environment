;;; config.el --- elfeed Layer extensions File for Spacemacs
;;
;; Copyright (c) 2012-2015 Sylvain Benner
;; Copyright (c) 2015- Uri Sharf & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Variables

(defvar elfeed-web-enabled-on-emacs-startup nil
  "If true, serve web interface Elfeed with simpl-httpd.")

(defvar rmh-elfeed-org-files nil
  "The files where we look to find trees with the
  `rmh-elfeed-org-tree-id'.")
