;;; init.el --- A sane Emacs configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; This configuration prioritizes built-in functionality and clean defaults.

;;; Code:

;; --- Package Management Setup ---
(require 'package)
(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;; Install use-package if not already present
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t) ; Ensure packages are installed

;; --- Theme ---
(load-theme 'modus-vivendi t)

;; --- Default font ---
(set-face-attribute 'default nil
                    :family "Iosevka NFM"
                    :height 120)

;; --- Input method ---
(setq default-input-method "russian-computer")

;; --- Sane Defaults ---
;; Store customizations in a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

;; y/n instead of yes/no
(setopt use-short-answers t)

;; UI: Less noise
(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil)

;; Put all backup files in a temp directory
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))

;; Put all auto-save files in a temp directory
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; UI: Cleaner appearance
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

;; Editing: Spaces are generally preferred
(setq-default indent-tabs-mode nil
              tab-width 4)

;; --- Essential Quality of Life ---
;; Show line numbers in programming modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Highlight matching parentheses
(add-hook 'prog-mode-hook 'show-paren-mode)

;; Enable recentf (recent files list)
(recentf-mode 1)
(setq recentf-max-menu-items 25)

;; Save place in files between sessions
(save-place-mode 1)

;; --- Minimal Package Setup ---

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

;; better minibuffer completion with Vertico (modular, built on built-ins) [citation:6]
(use-package vertico
  :init (vertico-mode))

;; Add orderless for flexible matching in minibuffer [citation:6]
(use-package orderless
  :custom
  ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

;; Rich annotations in minibuffer [citation:6]
(use-package marginalia
  :init (marginalia-mode))

;; Enhanced search and navigation with Consult [citation:6]
(use-package consult
   :bind (
          ("C-x b" . consult-buffer)
   ("M-g g" . consult-goto-line)))

;; Which-key for discovering keybindings [citation:5]
(use-package which-key
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.5))

;; --- Programming Support (Built-in) ---
;; Use Eglot for LSP (built into Emacs 29+ and prioritized in sane configs) [citation:1]
(use-package eglot
  :hook (prog-mode . eglot-ensure))

(use-package corfu
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-popupinfo-delay 0.2)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  )

(use-package cape
  ;; Bind dedicated completion commands
  ;; Alternative prefix keys: C-c p, M-p, M-/, J
  ;; :bind ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions'
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  )

(use-package magit)
