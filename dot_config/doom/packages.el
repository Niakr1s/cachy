;;; $DOOMDIR/packages.el -*- lexical-binding: t; no-byte-compile: t -*-

;; === Dotfile Management ===
(package! chezmoi)

;; === Clipboard / Yank Management ===
(package! clipetty)

;; === Documentation & Help ===
(package! eldoc-box)

;; === Evil Mode Extensions ===
(package! evil-surround)
(package! evil-terminal-cursor-changer)

;; === Custom / Third-party Packages ===
;; (package! gptel-agent)
(package! llm-tool-collection :recipe '(:host github :repo "skissue/llm-tool-collection"))

;; === Unsorted ===
(package! transpose-frame)
