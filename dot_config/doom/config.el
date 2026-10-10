;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(load! "modes/char-info-mode")

;; Appearance
(setq doom-theme 'doom-tokyo-night)
(setq display-line-numbers-type t)

;; --- Font Settings ---
(let* ((font-family "Iosevka NFM")
       (default-size 12.0)
       (large-size   24.0)

       (main-spec   (font-spec :family font-family))
       (main-spec-default-size   (font-spec :family font-family :size default-size))
       (big-spec-big-size    (font-spec :family font-family :size large-size))
       )

  (setq
   doom-font                main-spec-default-size
   doom-big-font            big-spec-big-size
   )

  (after! info
    (set-face-attribute 'Info-quoted nil
                        :inherit 'variable-pitch
                        :family font-family
                        :height 'unspecified))

  (defun my-enforce-other-font-settings ()
    (dolist (script '(
                      latin
                      cyrillic
                      greek
                      braille
                      ))
      (set-fontset-font t script main-spec))
    )
  (add-hook 'after-setting-font-hook #'my-enforce-other-font-settings)
  (setq default-input-method "russian-computer")
  )

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

(map! :leader
      (:prefix-map ("f" . "file")
       :desc "Fuzzy find files (fd)" "z" #'consult-fd))


(use-package! llm-tool-collection
  :after gptel
  :config
  (mapcar (apply-partially #'apply #'gptel-make-tool)
          (llm-tool-collection-get-all))
  )

(use-package! gptel
  :ensure t
  :config

  ;; Don't need this actually
  ;; (add-hook 'gptel-post-stream-hook 'gptel-auto-scroll)
  ;; (add-hook 'gptel-post-response-functions 'gptel-end-of-response)

  (setq gptel-models
        '(
          "Qwen3.8-27B"
          "Qwen3.6-35B-A3B"
          "Gemma4-26B-A4B"
          "Gemma4-E4B"
          ))

  (setq gptel-model 'Qwen3.6-35B-A3B)
  (setq gptel-backend
        (gptel-make-openai "llama.cpp"
          :host "localhost:9931"
          :endpoint "/v1/chat/completions"
          :protocol "http"
          :stream t
          :key "sk-no-key-required"
          :models gptel-models
          ))

  ;; I don't need this actually
  ;; (setq gptel-quick-model 'Qwen3.6-35B-A3B)
  ;; (setq gptel-quick-backend
  ;;       (gptel-make-openai "llama.cpp"
  ;;         :host "localhost:9931"
  ;;         :endpoint "/v1/chat/completions"
  ;;         :protocol "http"
  ;;         :stream t
  ;;         :key "sk-no-key-required"
  ;;         :models gptel-models
  ;;         :request-params '(
  ;;                           :thinking (:type "disabled" :budget_tokens 0)
  ;;                           :chat_template_kwargs (:enable_thinking :json-false))
  ;;         ))

  (gptel-make-preset 'ro
    :description "Read-only tools."
    :tools '("view_file" "glob" "grep" "ls"
             "view_buffer" "buffer_search" "list_buffers"))

  ;; Full access preset definition
  (gptel-make-preset 'yolo
    :description "All tools including write and exec."
    :tools '("create_file" "create_directory" "view_file" "edit_file"
             "glob" "replace_file" "grep" "ls"
             "view_buffer" "edit_buffer" "replace_buffer"
             "buffer_search" "list_buffers"
             "bash" "eval_elisp"))

  ;; Apply 'ro' globally so it becomes the default
  (gptel--apply-preset 'ro)
  )

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

(after! pdf-tools
  (unless (file-executable-p pdf-info-epdfinfo-program)
    (pdf-tools-install t)))

(use-package! transpose-frame
  :bind ("C-c t" . transpose-frame)
  )
