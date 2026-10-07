;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Appearance
(setq doom-theme 'doom-tokyo-night)
(setq display-line-numbers-type t)

;; --- Font Settings ---
(let* ((font-family "Iosevka NFM")
       (default-size 12.0)
       (large-size   24.0)

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
    (set-fontset-font "fontset-default" 'cyrillic main-spec)
    (set-fontset-font t 'cyrillic main-spec))
  )
(add-hook 'after-setting-font-hook #'my-enforce-cyrillic-font-settings)

(setq default-input-method "russian-computer")

;; org mode
(setq org-directory "~/org/")

;; Autocompletion
(setq corfu-auto-prefix 1)

;; Terminal fix
(mouse-wheel-mode)
(evil-terminal-cursor-changer-activate)

(use-package! clipetty
  :config
  (global-clipetty-mode +1))

(use-package! chezmoi)
(global-set-key (kbd "C-c C f")  #'chezmoi-find)
(global-set-key (kbd "C-c C s")  #'chezmoi-write)

;; LLM
(use-package! gptel
  :ensure t
  :config
  ;; Your existing default streaming backend (keep this for regular chat)
  (setq gptel-model 'lmstudio)
  (setq gptel-backend
        (gptel-make-openai "lmstudio"
          :protocol "http"
          :host "localhost:1234"
          :models '((lmstudio))
          :stream t)) ; Streaming enabled for regular chat

  ;; NEW: Define a separate, non-streaming backend for gptel-quick
  (setq gptel-quick-model 'lmstudio-quick)
  (setq gptel-quick-backend
        (gptel-make-openai "lmstudio-quick"
          :protocol "http"
          :host "localhost:1234"
          :models '((lmstudio))
          :stream nil))) ; Streaming DISABLED for quick lookups

(use-package! llm-tool-collection
  :config
  (mapcar (apply-partially #'apply #'gptel-make-tool)
          (llm-tool-collection-get-all)))

;; Magnet links in orgmode
(with-eval-after-load 'org
  (org-link-set-parameters "magnet"
    :follow (lambda (link)
              (browse-url (concat "magnet:" link)))
    :export (lambda (path desc format _)
              (cond
               ((eq format 'html)
                (format "<a href=\"magnet:%s\">%s</a>" path (or desc path)))
               ((eq format 'latex)
                (format "\\href{magnet:%s}{%s}" path (or desc path)))
               (t nil)))))
