;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Appearance
(setq doom-theme 'doom-tokyo-night)
(setq display-line-numbers-type t)

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


(defun my-open-todo-file ()
  "Automatically open todo.org (creating it if missing) if no other files are specified."
  (let* ((todo-file (expand-file-name "~/org/todo.org"))
         (todo-dir (file-name-directory todo-file)))
    ;; Only run if the client didn't pass a specific file, and we aren't already looking at it
    (when (not (string= (buffer-file-name) todo-file))
      ;; Create the parent directory if it's completely missing
      (unless (file-directory-p todo-dir)
        (make-directory todo-dir t))
      ;; Open (and visually switch to) the todo file
      (find-file todo-file))))

;; Run this function every time an emacsclient frame is created
(add-hook 'emacs-startup-hook #'my-open-todo-file)
(add-hook 'server-after-make-frame-hook #'my-open-todo-file)

(after! persp-mode
  ;; Prevent emacsclient -c / -nw from spawning blank workspaces
  (setq persp-emacsclient-init-frame-behaviour-override "main"))
