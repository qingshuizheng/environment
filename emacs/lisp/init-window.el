;;; init-window.el --- Window configurations -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2015-2021 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;; Version: 0.1
;; Package-Requires: ((emacs "27.2"))
;;
;; Created: 07 Feb 2021
;;
;; URL: https://github.com/d12frosted/environment/tree/master/emacs
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
;; Configurations for window system.
;;
;;; Code:

(require 'init-kbd)

;; Prefer vertical splits by default
(setq split-height-threshold nil
      split-width-threshold 160)

(use-package ace-window
  :defer t
  :init
  (setq-default aw-keys '(?q ?w ?e ?r ?t ?y ?u ?i ?o)))

(defun window-split-vertically ()
  "Split window vertically."
  (interactive)
  (split-window-right))

(defun window-split-vertically-and-focus ()
  "Split window vertically and focus it."
  (interactive)
  (split-window-right)
  (windmove-right))

(defun window-split-horizontally ()
  "Split window horizontally."
  (interactive)
  (split-window-below))

(defun window-split-horizontally-and-focus ()
  "Split window horizontally and focus it."
  (interactive)
  (split-window-below)
  (windmove-down))

(defun window-zoom ()
  "Close other windows to focus on this one.

Activate again to undo this. If the window changes before then,
the undo expires."
  (interactive)
  (if (and (one-window-p)
           (assq ?_ register-alist))
      (jump-to-register ?_)
    (window-configuration-to-register ?_)
    (delete-other-windows)))

(leader-def
  "C-w" '(ace-window :which-key "Ace window")
  "M-w" '(ace-window :which-key "Ace window")

  "w"  '(nil :which-key "window...")
  "wS" '(window-split-horizontally
         :which-key "split frame horizontally")
  "wV" '(window-split-vertically
         :which-key "split frame vertically")
  "wk" '(delete-window
         :which-key "kill window")
  "wm" '(window-zoom
         :which-key "kill other windows")
  "ws" '(window-split-horizontally-and-focus
         :which-key "split frame horizontally and focus")
  "wv" '(window-split-vertically-and-focus
         :which-key "split frame vertically and focus"))

;; by protesilaos
(use-package window
  :straight nil
  :init
  (setq display-buffer-alist
        `(;; top side window
          ("\\**prot-elfeed-bongo-queue.*"
           (display-buffer-reuse-window display-buffer-in-side-window)
           (window-height . 0.16)
           (side . top)
           (slot . -2))
          ("\\*\\(prot-elfeed-mpv-output\\|world-clock\\).*"
           (display-buffer-in-side-window)
           (window-height . 0.16)
           (side . top)
           (slot . -1))
          ("\\*\\(Flymake\\|Package-Lint\\|vc-git :\\).*"
           (display-buffer-in-side-window)
           (window-height . 0.16)
           (side . top)
           (slot . 0))
          ("\\*Messages.*"
           (display-buffer-in-side-window)
           (window-height . 0.16)
           (side . top)
           (slot . 1))
          ("\\*\\(Backtrace\\|Warnings\\|Compile-Log\\)\\*"
           (display-buffer-in-side-window)
           (window-height . 0.16)
           (side . top)
           (slot . 2)
           (window-parameters . ((no-other-window . t))))
          ;; bottom side window
          ("\\*\\(Embark\\)?.*Completions.*"
           (display-buffer-in-side-window)
           (side . bottom)
           (slot . 0)
           (window-parameters . ((no-other-window . t)
                                 (mode-line-format . none))))
          ;; left side window
          ;; right side window
          ("\\*Help.*"
           (display-buffer-in-side-window)
           (window-width . 0.20)        ; See the :hook
           (side . right)
           (slot . 0))
          ("\\*keycast\\*"
           (display-buffer-in-side-window)
           (dedicated . t)
           (window-width . 0.25)
           (side . right)
           (slot . -1)
           (window-parameters . ((no-other-window . t)
                                 (mode-line-format . none))))
          ("\\*Faces\\*"
           (display-buffer-in-side-window)
           (window-width . 0.25)
           (side . right)
           (slot . 0))
          ("\\*Custom.*"
           (display-buffer-in-side-window)
           (window-width . 0.25)
           (side . right)
           (slot . 1))
          ;; bottom buffer (NOT side window)
          ("\\*\\vc-\\(incoming\\|outgoing\\).*"
           (display-buffer-at-bottom))
          ("\\*\\(Output\\|Register Preview\\).*"
           (display-buffer-at-bottom))
          ("\\*.*\\(e?shell\\|v?term\\).*"
           (display-buffer-reuse-mode-window display-buffer-at-bottom)
           (window-height . 0.2))
          ;; below current window
          ("\\*Calendar.*"
           (display-buffer-reuse-mode-window
            display-buffer-below-selected)
           (window-height . shrink-window-if-larger-than-buffer))))
  (setq window-combination-resize t)
  (setq even-window-sizes 'height-only)
  (setq window-sides-vertical nil)
  (setq switch-to-buffer-in-dedicated-window 'pop)
  (add-hook 'help-mode-hook #'visual-line-mode)
  (add-hook 'custom-mode-hook #'visual-line-mode)
  (let ((map global-map))
    (define-key map (kbd "s-n") #'next-buffer)
    (define-key map (kbd "s-p") #'previous-buffer)
    (define-key map (kbd "s-o") #'other-window)
    (define-key map (kbd "s-2") #'split-window-below)
    (define-key map (kbd "s-3") #'split-window-right)
    (define-key map (kbd "s-0") #'delete-window)
    (define-key map (kbd "s-1") #'delete-other-windows)
    (define-key map (kbd "s-!") #'delete-other-windows-vertically)
    (define-key map (kbd "s-5") #'delete-frame)
    (define-key map (kbd "C-x _") #'balance-windows)
    (define-key map (kbd "C-x -") #'fit-window-to-buffer)
    (define-key map (kbd "C-x +") #'balance-windows-area)
    (define-key map (kbd "s-q") #'window-toggle-side-windows)
    (define-key map (kbd "C-x }") #'enlarge-window)
    (define-key map (kbd "C-x {") #'shrink-window)
                                        ; override "scroll-right"
    (define-key map (kbd "C-x >") #'enlarge-window-horizontally)
                                        ; override "scroll-left"
    (define-key map (kbd "C-x <") #'shrink-window-horizontally))
  (let ((map resize-window-repeat-map))
    (define-key map ">" #'enlarge-window-horizontally)
    (define-key map "<" #'shrink-window-horizontally)))

;; by protesilaos
(use-package winner
  :straight nil
  :init
  (add-hook 'after-init-hook #'winner-mode)
  (let ((map global-map))
    (define-key map (kbd "<M-s-right>") #'winner-redo)
    (define-key map (kbd "<M-s-left>") #'winner-undo)))

(provide 'init-window)
;;; init-window.el ends here
