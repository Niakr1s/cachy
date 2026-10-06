;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Appearance
(setq doom-theme 'doom-tokyo-night)
(setq display-line-numbers-type t)

;; --- Font Settings ---
(let* ((font-family "Iosevka NFM")
       (default-size 15)
       (large-size   24)

       (main-spec   (font-spec :family font-family :size default-size))
       (prop-spec   (font-spec :family font-family :size default-size))
       (big-spec    (font-spec :family font-family :size large-size))
       (symbol-spec (font-spec :family font-family :size default-size)))

  (setq doom-font                main-spec
        doom-variable-pitch-font prop-spec
        doom-big-font            big-spec
        doom-unicode-font        symbol-spec
        doom-serif-font          symbol-spec)

  (defun my-enforce-cyrillic-font-settings ()
    "Explicitly forces the active frame and global fontset to bind Cyrillic to Iosevka NFM.
This stops Doom's internal post-init routines from prioritizing system fallbacks."
    (set-fontset-font "fontset-default" 'cyrillic main-spec)
    (set-fontset-font t 'cyrillic main-spec)
    (set-fontset-font "fontset-default" '(#x0400 . #x04FF) main-spec nil 'prepend)
    (set-fontset-font t '(#x0400 . #x04FF) main-spec nil 'prepend))
  )
(add-hook 'after-setting-font-hook #'my-enforce-cyrillic-font-settings)

;; org mode
(setq org-directory "~/org/")

;; Autocompletion
(setq corfu-auto-prefix 1)

;; Terminal fix
(mouse-wheel-mode)
(evil-terminal-cursor-changer-activate)

(use-package! eldoc-box
  :after eldoc
  :config
  ;; Enable the minor mode that shows docs in a childframe
  ;; at the upper corner of the frame.
  (eldoc-box-hover-at-point-mode +1)
  )

(use-package! clipetty
  :config
  (global-clipetty-mode +1))

