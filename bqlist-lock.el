;;; bqlist-lock.el --- font lock for backquoted parentheses

;; Copyright (C) 2013 Takeshi Banse <takebi@laafc.net>
;; Author: Takeshi Banse <takebi@laafc.net>
;; Keywords: faces, convenience, lisp, parens, backquote

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; On Vim, backquoted parentheses are colored distinctly different from
;; normal parentheses by default lisp syntax highlighting. I want its effect
;; on Emacs, too.

;;; Installation:
;;
;; XXX: Subject to change, sorry.
;; Please load this file then execute `bqlist-lock-enable' once for each
;; buffer for example:
;;
;;   (require 'bqlist-lock)
;;   (add-hook 'emacs-lisp-mode-hook 'bqlist-lock-enable)

;;; Code:

(defgroup bqlist-lock nil
  "Font lock for backquoted parentheses."
  :prefix "bqlist-lock-"
  :group 'applications)

(defface bqlist-lock-face
  '((((class color) (min-colors 256))
     (:foreground "#5fd7ff"))
    (((class color) (min-colors 8))
     (:foreground "LightBlue"))
    (t (:inherit highlight)))
  "Face for backquoted parentheses."
  :group 'bqlist-lock-faces)

(defsubst bqlist-lock-lockable-p (pos)
  (let ((state (syntax-ppss pos)))
    (not (or (nth 3 state)
             (nth 4 state)))))

(defun bqlist-lock-jit-lock (re beg end)
  (save-excursion
    (goto-char beg)
    (while (and (< (point) end)
                (re-search-forward re end t))
      (save-excursion
        ;; XXX: 2 is appropriate here, I believe.
        (backward-char 2)
        (when (bqlist-lock-lockable-p (point))
          (pcase-let ((`(,b . ,e)
                        (cons (point)
                              (save-excursion
                                (forward-sexp)
                                (point)))))
            (with-silent-modifications
              (add-face-text-property b (+ b 2) 'bqlist-lock-face)
              (add-face-text-property (1- e) e  'bqlist-lock-face))))))))

(defun bqlist-lock-enable-aux (re)
  (jit-lock-register (apply-partially 'bqlist-lock-jit-lock re) t))

(defun bqlist-lock-enable () ; XXX: subject to change
  (interactive)
  (bqlist-lock-enable-aux (rx "`(")))

(provide 'bqlist-lock)
;;; bolist-lock ends here
