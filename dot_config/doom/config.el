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

(defun org-babel-edit-prep:python (babel-info)
  (let ((tangle-file (assoc-default :tangle (nth 2 babel-info))))
    (when (and tangle-file (not (eq tangle-file 'no)))
      (setq-local buffer-file-name
                  (expand-file-name tangle-file)))))

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
  (add-hook 'gptel-post-stream-hook 'gptel-auto-scroll) ;; Auto scroll automatically
  (add-hook 'gptel-post-response-functions 'gptel-end-of-response) ;; Auto move cursor to the next prompt
  (setq
   gptel-model 'ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF
   gptel-backend (gptel-make-openai "llama.cpp"
                   :host "localhost:9931"
                   :endpoint "/v1/chat/completions"
                   :protocol "http"
                   :stream t
                   :key "sk-no-key-required"
                   :models '(
                             "ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF"
                             "Accio-Lab/occamy-1.0-GGUF"
                             "HauhauCS/Gemma4-26B-A4B-Uncensored-HauhauCS-Balanced"
                             "HauhauCS/Gemma-4-E4B-Uncensored-HauhauCS-Aggressive"))))

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

(use-package! evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))
