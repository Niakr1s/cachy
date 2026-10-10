;;; char-info-mode.el -*- lexical-binding: t; -*-


(defun char-info-eldoc ()
  "Return a string describing the char and font at point."
  (when-let ((ch (char-after (point))))
    (let* ((font   (font-at (point)))
           (family (and font (font-get font :family))))
      (format "U+%04X %c  |  %s" ch ch (or family "?")))))

(defun char-info-eldoc-hook ()
  (eldoc-message (char-info-eldoc)))

(define-minor-mode char-info-mode
  "Show char/font info in the echo area on every cursor move."
  :global t
  :lighter " CI"
  (if char-info-mode
      (add-hook 'post-command-hook #'char-info-eldoc-hook)
    (remove-hook 'post-command-hook #'char-info-eldoc-hook)))
