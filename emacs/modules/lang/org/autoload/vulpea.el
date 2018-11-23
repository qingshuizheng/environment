;;; lang/org/autoload/vulpea.el -*- lexical-binding: t; -*-
;;
;; Copyright (c) 2017-2018 Boris Buliga
;;
;; Author: Boris Buliga <boris@d12frosted.io>
;; Maintainer: Boris Buliga <boris@d12frosted.io>
;;
;; Created: 23 Nov 2018
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

(require 'org-brain)

(defun vulpea-brain/insert-link ()
  "Insert a link to brain entry."
  (interactive)
  (insert (vulpea-brain--make-link (vulpea-brain--choose-entry))))

(defun vulpea-brain--make-link (entry-or-id)
  "Make an org-mode link to ENTRY."
  (org-make-link-string
   (concat "brain:"
           (vulpea-brain--as-id entry-or-id))
   (org-brain-title (vulpea-brain--as-entry entry-or-id))))

(defun vulpea-brain--choose-entry ()
  "Choose a brain entry."
  (org-brain-choose-entry
   "Entry: "
   (append (org-brain-files t) (org-brain-headline-entries))
   nil
   t))

(defun vulpea-brain--choose-entry-by-parent (prompt parent)
  "Choose a brain entry from children of PARENT."
  (let ((org-brain-file-entries-use-title nil))
    (org-brain-choose-entry
     prompt
     (org-brain-children (vulpea-brain--as-entry parent))
     nil
     t)))

(defun vulpea-brain--is-child-of (child parent)
  "Returns non-nil, when CHILD is a child of PARENT."
  (let ((children (org-brain-children (vulpea-brain--as-entry parent))))
    (seq-contains children child #'vulpea-brain--entry-id-equal)))

(defun vulpea-brain--is-transitive-child-of (child parent)
  "Returns non-nil, when CHILD is a transitive child of PARENT."
  (let ((children (org-brain-children (vulpea-brain--as-entry parent))))
    (if (seq-contains children child #'vulpea-brain--entry-id-equal)
        t
      (seq-some (lambda (new-parent)
                  (vulpea-brain--is-transitive-child-of child new-parent))
                children))))

(defun vulpea-brain--transitive-children (parent)
  "Returns list of transitive children of PARENT."
  (seq-mapcat
   (lambda (entry)
     (seq-concatenate
      'list
      (list entry)
      (vulpea-brain--transitive-children entry)))
   (org-brain-children (vulpea-brain--as-entry parent))))

(defun vulpea-brain--as-entry (entry-or-id)
  "Returns brain entry."
  (if (stringp entry-or-id)
      (org-brain-entry-from-id entry-or-id)
    entry-or-id))

(defun vulpea-brain--as-id (entry-or-id)
  "Returns identifier of ENTRY-OR-ID."
  (if (stringp entry-or-id)
      entry-or-id
    (org-brain-entry-identifier entry-or-id)))

(defun vulpea-brain--entry-id-equal (a b)
  "Returns non-nil, when id of A equals id of B."
  (string-equal (vulpea-brain--as-id a)
                (vulpea-brain--as-id b)))

(defun vulpea-brain--new-child (entry-or-id name)
  "Insert new entry with NAME as a child of ENTRY-OR-ID."
  (let ((entry (vulpea-brain--as-entry entry-or-id)))
    (if (org-brain-filep entry)
        ;; File entry
        (with-current-buffer (find-file-noselect (org-brain-entry-path entry))
          (goto-char (point-min))
          (if (re-search-forward (concat "^\\(" org-outline-regexp "\\)") nil t)
              (progn
                (beginning-of-line)
                (open-line 1))
            (goto-char (point-max)))
          (insert (concat "* " name))
          (org-id-get-create))
      ;; Headline entry
      (org-with-point-at (org-brain-entry-marker entry)
        (if (org-goto-first-child)
            (open-line 1)
          (org-end-of-subtree t))
        (org-insert-heading)
        (org-do-demote)
        (insert name)
        (org-id-get-create)))))

(defun vulpea-brain--get-property (entry-or-id name)
  "Returns property with NAME of ENTRY-OR-ID."
  (vulpea-brain--map-entry
   entry-or-id
   (lambda (entry)
     (org-entry-get nil name))
   nil))

(defun vulpea-brain--map-entry (entry-or-id entry-fn file-fn)
  "Execute ENTRY-FN or FILE-FN on ENTRY-OR-ID.

If ENTRY-OR-ID points to file entry, then FILE-FN is executed.
Otherwise ENTRY-FN is executed.

Entry is passed to both functions as argument.

For the duration of every function, point is set on entry."
  (let ((entry (vulpea-brain--as-entry entry-or-id)))
    (if (org-brain-filep entry)
        (with-current-buffer (find-file-noselect (org-brain-entry-path entry))
          (goto-char (point-min))
          (unless (null file-fn)
            (funcall file-fn entry)))
      (org-with-point-at (org-brain-entry-marker entry)
        (unless (null entry-fn)
          (funcall entry-fn entry))))))



;;;###autoload
(define-minor-mode vulpea-mode
  "Note taking utilities."
  :lighter " vulpea"
  (setq-local vulpea-properties-order (vulpea--get-buffer-properties-order))
  (setq-local vulpea-places-config (vulpea--get-buffer-places-config))

  (setq-local vulpea-cha-tea-groups-parent-id
              (vulpea--get-buffer-setting "TEA_GROUPS_PARENT"))
  (setq-local vulpea-cha--tea-groups-parent
              (vulpea-brain--as-entry vulpea-cha-tea-groups-parent-id))

  (setq-local vulpea-cha-fermentation-types-parent-id
              (vulpea--get-buffer-setting "FERMENTATION_TYPES_PARENT"))
  (setq-local vulpea-cha--fermentation-types-parent
              (vulpea-brain--as-entry vulpea-cha-fermentation-types-parent-id))

  (setq-local vulpea-cha-pressing-types-parent-id
              (vulpea--get-buffer-setting "PRESSING_TYPES_PARENT"))
  (setq-local vulpea-cha--pressing-types-parent
              (vulpea-brain--as-entry vulpea-cha-pressing-types-parent-id))

  (setq-local vulpea-cha-tea-parent-id
              (vulpea--get-buffer-setting "TEA_PARENT"))
  (setq-local vulpea-cha--tea-parent
              (vulpea-brain--as-entry vulpea-cha-tea-parent-id))

  (setq-local vulpea-cha-tea-title-format
              (vulpea--get-buffer-setting "TEA_TITLE_FORMAT"))

  (setq-local vulpea-default-currency
              (vulpea--get-buffer-setting "DEFAULT_CURRENCY")))

;;;###autoload
(defun vulpea-mode-maybe-enable ()
  "Conditionally enable `vulpea-mode' in `org-mode' buffer.

Enables the `vulpea-mode' iff the buffer has 'vulpea-mode:t'
option set in the options section.

#+OPTIONS: vulpea-mode:t"
  (when (and (eq major-mode 'org-mode)
             (eq buffer-read-only nil))
    (save-excursion
      (widen)
      (goto-char (point-min))
      (when (re-search-forward "^#\\+OPTIONS:.*vulpea-mode:t" (point-max) t)
        (vulpea-mode)))))



(defvar-local vulpea-places-config '()
  "Association list of place level and it's entry ID.

Can be set in the org-mode buffer by adding following line in the
top of the file:

  #+PROPERTIES_ORDER: LEVEL1:ID1 LEVEL2:ID2 LEVEL3:ID3 ...")

(defun vulpea/set-place-dwim ()
  (interactive)
  (let* ((level (completing-read "Level: " (seq-map #'car vulpea-places-config) nil t))
         (level-id (cdr (assoc-string level vulpea-places-config)))
         (level-entries (seq-map (lambda (x)
                                   (cons (car x)
                                         (org-brain-entry-from-id (cdr x))))
                                 vulpea-places-config))
         (entry (vulpea-brain--choose-entry-by-parent "Level: " level-id))
         (entry-id (org-brain-entry-identifier entry)))

    ;; clear all levels
    (seq-do (lambda (level-cfg)
              (org-entry-delete nil (upcase (car level-cfg))))
            vulpea-places-config)

    (seq-do
     (lambda (x)
       (org-set-property (upcase (car x))
                         (vulpea-brain--make-link (cdr x))))
     ;; list of (level . specific-place-id) to set
     (seq-map
      (lambda (level-cfg)
        (cons (car level-cfg)
              (car (seq-filter
                    (lambda (e)
                      (vulpea-brain--is-transitive-child-of entry-id e))
                    (org-brain-children (cdr level-cfg))))))
      ;; list of levels to set
      (seq-filter
       (lambda (level-cfg)
         (and (not (string-equal level (car level-cfg)))
              (vulpea-brain--is-transitive-child-of entry-id (cdr level-cfg))))
       level-entries)))

    ;; set the level value
    (org-set-property (upcase level)
                      (vulpea-brain--make-link entry))))

(defun vulpea--get-buffer-places-config ()
  "Get the `vulpea-places-config' from current buffer."
  (seq-map
   (lambda (x)
     (let ((pairs (split-string x ":")))
       (cons (car pairs) (cadr pairs))))
   (vulpea--get-buffer-settings "PLACES_CONFIG")))

(defun vulpea--get-location-id ()
  "Get LOCATION id of entry at point."
  (seq-reduce
   (lambda (res level-cfg)
     (let ((val (org-entry-get nil (car level-cfg))))
       (if (or (null val) (string-empty-p val))
           res
         (vulpea--extract-id-from-link val))))
   vulpea-places-config
   nil))

(defun vulpea--get-location ()
  "Get LOCATION name of entry at point."
  (org-brain-title (vulpea-brain--as-entry (vulpea--get-location-id))))



(defun vulpea--get-year ()
  "Get YEAR of entry at point."
  (let ((year-gathered (org-entry-get nil "YEAR_GATHERED"))
        (year-manufactured (org-entry-get nil "YEAR_MANUFACTURED")))
    (cond
     ((string-equal year-gathered year-manufactured) year-gathered)
     ((null year-gathered) year-manufactured)
     ((null year-manufactured) year-gathered)
     (t (concat year-gathered " - " year-manufactured)))))



(defvar-local vulpea-properties-order '()
  "List of properties used for ordering.

Can be set in the org-mode buffer by adding following line in the
top of the file:

  #+PROPERTIES_ORDER: PROP1 PROP2 PROP3 ...")

(defun vulpea/sort-entry-properties ()
  "Sort properties in entry at point."
  (interactive)
  (let ((p0 (car (org-get-property-block)))
         (p1 (- (cdr (org-get-property-block)) 1))
         (props (org-entry-properties))
         (maxv (seq-length vulpea-properties-order))
         (pregx "^:\\([a-zA-Z_\\-]+\\):.*$"))
    (save-excursion
      (save-restriction
        (narrow-to-region p0 p1)
        (goto-char (point-min))
        (let ;; To make `end-of-line' and etc. to ignore fields.
            ((inhibit-field-text-motion t))
          (sort-subr
           nil 'forward-line 'end-of-line nil nil
           (lambda (l1 l2)
             (< (or
                 (seq-position vulpea-properties-order
                               (vulpea--match-regexp pregx l1))
                 maxv)
                (or
                 (seq-position vulpea-properties-order
                               (vulpea--match-regexp pregx l2))
                 maxv)))))))))

(defun vulpea--get-buffer-properties-order ()
  "Get the `vulpea-properties-order' from current buffer."
  (vulpea--get-buffer-settings "PROPERTIES_ORDER"))

(defun vulpea/format-entry-properties ()
  "Format properties in entry at point."
  (interactive)
  (let ((p0 (car (org-get-property-block)))
        (p1 (cdr (org-get-property-block))))
    (save-excursion
      (goto-char p0)
      (while (< (point) p1)
        (org-indent-line)
        (forward-line 1)
        (beginning-of-line)))))

(defun vulpea/pretty-entry-properties ()
  "Prettify properties of entry at point.

- `vulpea/format-entry-properties'
- `vulpea/sort-entry-properties'"
  (interactive)
  (vulpea/format-entry-properties)
  (vulpea/sort-entry-properties))



(defun vulpea/pretty-buffer ()
  "Prettify all entries in the buffer."
  (interactive)
  (org-map-entries
   (lambda ()
     (vulpea/format-entry-properties)
     (vulpea/sort-entry-properties)
     (when (vulpea-cha--tea-entry-p)
       (vulpea-cha/pretty-tea)))
   "prettify" 'file))



(defvar-local vulpea-default-currency ""
  "Default currency.

Can be set in the org-mode buffer by adding following line in the
top of the file:

  #+DEFAULT_CURRENCY: currency")



(defvar vulpea-cha-tea-groups-parent-id ""
  "ID of Tea Groups parent entry.

Can be set in the org-mode buffer by adding following line in the
top of the file:

  #+TEA_GROUPS_PARENT: ID")

(defvar vulpea-cha-fermentation-types-parent-id ""
  "ID of Fermentation types parent entry.

Can be set in the org-mode buffer by adding following line in the
top of the file:

  #+FERMENTATION_TYPES_PARENT: ID")

(defvar vulpea-cha-pressing-types-parent-id ""
  "ID of Pressing types parent entry.

Can be set in the org-mode buffer by adding following line in the
top of the file:

  #+PRESSING_TYPES_PARENT: ID")

(defvar vulpea-cha-tea-parent-id ""
  "ID of Tea parent entry.

Can be set in the org-mode buffer by adding following line in the
top of the file:

  #+TEA_PARENT: ID")

(defvar-local vulpea-cha--tea-groups-parent nil)
(defvar-local vulpea-cha--fermentation-types-parent nil)
(defvar-local vulpea-cha--pressing-types-parent nil)
(defvar-local vulpea-cha--tea-parent nil)

(defvar-local vulpea-cha-tea-title-format nil
  "

Can be set in the org-mode buffer by adding following line in the
top of the file:

  #+TEA_TITLE_FORMAT: {LOCATION} {NAME} | {YEAR} | {TAG}")

(defun vulpea-cha/new-tea-group ()
  "Create a new tea group entry."
  (interactive)
  (let* ((name (read-string "Tea group name: "))
         (id (vulpea-brain--new-child vulpea-cha--tea-groups-parent name)))
    (org-with-point-at (org-id-find id t)
      (vulpea--set-property-string "NAME_ORIGINAL")
      (vulpea--set-property-string "NAME_TRANSCRIPTION")
      (vulpea--set-property-string "NAME_MEANING")
      (vulpea--set-property-link "FERMENTATION"
                                 vulpea-cha--fermentation-types-parent)
      (save-buffer)
      (vulpea/pretty-entry-properties)
      (save-buffer))))

(defun vulpea-cha/new-tea ()
  "Create a new tea entry."
  (interactive)
  (let* ((tea-group (vulpea-cha--read-tea-group))
         (pressing (vulpea-cha--read-pressing))
         (name (cadr tea-group))
         (name-original
          (vulpea-brain--get-property tea-group "NAME_ORIGINAL"))
         (name-transcription
          (vulpea-brain--get-property tea-group "NAME_TRANSCRIPTION"))
         (name-meaning
          (vulpea-brain--get-property tea-group "NAME_MEANING"))
         (name (read-string "Tea name: " name))
         (id (vulpea-brain--new-child vulpea-cha--tea-parent name)))
    (org-with-point-at (org-id-find id t)
      (org-set-property "TEA_GROUP"
                        (vulpea-brain--make-link tea-group))
      (vulpea-cha/set-pressing pressing)
      (vulpea--set-property-string "TAG")
      (org-set-property "NAME" name)
      (vulpea--set-property-string "NAME_ORIGINAL" name-original)
      (vulpea--set-property-string "NAME_TRANSCRIPTION" name-transcription)
      (vulpea--set-property-string "NAME_MEANING" name-meaning)
      (vulpea--set-property-string "YEAR_GATHERED")
      (vulpea--set-property-string "YEAR_MANUFACTURED")
      (vulpea/set-place-dwim)
      (org-set-property "RATE" "n/a")
      (org-set-property "PRICE"
                        (concat vulpea-default-currency
                                (read-string "Price: ")))
      (vulpea--set-property-string "AVAILABLE")
      (org-set-property "TOTAL_IN" (org-entry-get nil "AVAILABLE"))
      (org-set-property "TOTAL_OUT" "0")
      (save-buffer)
      (vulpea-cha/pretty-tea)
      (save-buffer))))

(defun vulpea-cha/pretty ()
  "Prettify tea entries."
  (interactive)
  (let ((loc-groups (org-id-find vulpea-cha-tea-groups-parent-id))
        (loc-tea (org-id-find vulpea-cha-tea-parent-id)))

    (vulpea-with-file
     (car loc-groups)
     (org-with-point-at (cdr loc-groups)
       (org-map-entries
        (lambda ()
          (vulpea/format-entry-properties)
          (vulpea/sort-entry-properties))
        nil 'tree)))

    (vulpea-with-file
     (car loc-tea)
     (org-with-point-at (cdr loc-tea)
       (org-map-entries (lambda ()
                          (if (string-equal (org-id-get)
                                            vulpea-cha-tea-parent-id)
                              (progn (vulpea/format-entry-properties)
                                     (vulpea/sort-entry-properties))
                            (vulpea-cha/pretty-tea)))
                        nil 'tree)))))

(defun vulpea-cha/pretty-tea ()
  "Prettify tea entry at point."
  (interactive)
  (vulpea/pretty-entry-properties)
  (org-set-property
   "AVAILABLE"
   (number-to-string
    (- (string-to-number (or (org-entry-get nil "TOTAL_IN") ""))
       (string-to-number (or (org-entry-get nil "TOTAL_OUT") "")))))
  (org-edit-headline
   (vulpea--format-title vulpea-cha-tea-title-format)))

(defun vulpea-cha--read-tea-group ()
  "Read Tea Group."
  (vulpea-brain--choose-entry-by-parent
   "Tea group: "
   vulpea-cha--tea-groups-parent))

(defun vulpea-cha--read-pressing ()
  "Read Tea Group."
  (vulpea-brain--choose-entry-by-parent
   "Pressing: "
   vulpea-cha--pressing-types-parent))

(defun vulpea-cha/set-pressing (&optional pressing)
  "Set PRESSING of tea entry at point"
  (interactive)
  (unless pressing
    (setq pressing (vulpea-cha--read-pressing)))
  (org-set-property "PRESSING"
                    (vulpea-brain--make-link pressing)))



(defun vulpea--format-title (format)
  (let ((properties (org-entry-properties))
        (val-regexp "{\\([a-zA-Z0-9\\-_]+\\)")
        (prop "")
        (val "")
        (result format))
    (map-put properties "LOCATION" (vulpea--get-location))
    (map-put properties "YEAR" (vulpea--get-year))
    (while (string-match val-regexp result)
      (setq prop (match-string 1 result))
      (setq val (cdr (assoc-string prop properties)))
      (setq result (replace-regexp-in-string
                    (concat "{" prop "}")
                    val
                    result
                    t)))
    result))



(defun vulpea--get-buffer-setting (name)
  "Get a setting called NAME from buffer as a string."
  (save-excursion
    (widen)
    (goto-char (point-min))
    (when (re-search-forward (concat "^#\\+" name ": \\(.*\\)") (point-max) t)
      (buffer-substring-no-properties
       (match-beginning 1)
       (match-end 1)))))

(defun vulpea--get-buffer-settings (name &optional separators)
  "Get a setting called NAME from buffer as a list using
SEPARATORS."
  (split-string (vulpea--get-buffer-setting name)))

(defun vulpea--match-regexp (regexp val)
  "Get the 1 match from the VAL."
  (let ((s (if (stringp val)
               val
             (buffer-substring (car val) (cdr val)))))
    (string-match regexp s)
    (match-string 1 s)))

(defun vulpea--set-property-string (name &optional initial)
  (org-set-property
   name
   (read-string (concat (vulpea--prettify-prompt-string name) ": ") initial)))

(defun vulpea--set-property-link (name parent)
  (org-set-property
   name
   (vulpea-brain--make-link
    (vulpea-brain--choose-entry-by-parent
     (format "%s: " (capitalize name))
     parent))))

(defun vulpea--prettify-prompt-string (prompt)
  (capitalize (replace-regexp-in-string "_" " " prompt)))

(defun vulpea--extract-id-from-link (link)
  (vulpea--match-regexp "\\[\\[.+:\\(.+\\)\\]\\[.*\\]\\]" link))

(defmacro vulpea-with-file (file &rest body)
  `(with-current-buffer (find-file-noselect ,file)
     ,@body))

(provide 'vulpea)

;;; vulpea.el ends here
