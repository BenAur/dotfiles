;;; -*- lexical-binding: t; -*-

(setq custom-file (locate-user-emacs-file "custom.el"))

;; (push '(fullscreen . maximized) default-frame-alist)

;; macOS: let the title bar take the theme background (light text/buttons).
(when (eq window-system 'ns)
  (push '(ns-transparent-titlebar . t) default-frame-alist)
  (push '(ns-appearance . light) default-frame-alist)
  (set-frame-parameter nil 'ns-transparent-titlebar t)
  (set-frame-parameter nil 'ns-appearance 'light))

;; Apply GUI-only settings to the initial frame and future emacsclient frames.
(defun aurbenoi-configure-gui-frame (frame)
  (when (display-graphic-p frame)
    (with-selected-frame frame
      (when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
      (when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
      (when (fboundp 'tooltip-mode) (tooltip-mode -1))
    )))

(add-hook 'after-make-frame-functions #'aurbenoi-configure-gui-frame)
(aurbenoi-configure-gui-frame (selected-frame))

(menu-bar-mode -1) ; disable menu bar
(setq visible-bell nil) ;; disable visible bell
(setq inhibit-startup-message t) ;; remove startup message
(setq mouse-drag-copy-region t) ;; allow to select a region by draging the mousel
(set-default-coding-systems 'utf-8) ;; default to utf-8
(desktop-save-mode 1) ;; save session
(setq tab-bar-tab-hints t) ;; display tab bar numbers
(setopt use-short-answers t) ;; use y or n for short answers
(setq compilation-save-buffers-predicate 'ignore) ;; do not ask to save buffer before compiling
(setq ring-bell-function 'ignore)

;; Reduce GC frequency and handle larger subprocess output chunks.
(setq gc-cons-threshold (* 16 1024 1024)
      read-process-output-max (* 1024 1024)
      fast-but-imprecise-scrolling t)

;; Reduce expensive editing features in files with unusually long lines.
(global-so-long-mode 1)

(add-to-list 'default-frame-alist '(alpha . 100)) ; For all new frames

;; dired unzip options
(eval-after-load "dired-aux"
   '(add-to-list 'dired-compress-file-suffixes
                 '("\\.zip\\'" ".zip" "unzip")))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)

(use-package exec-path-from-shell
  :ensure t) ;; if not using the ELPA package
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; vertical completion system (instead of being weird horizontal | vertical completion)
(use-package vertico
  :ensure t
  :config
  (vertico-mode 1))

;; add marginalia to the minibuffer completion
;; add more info to completions in the minibuffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode 1))

;; fuzzy matching for completion
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil))

(use-package magit
  :ensure t)
(setq magit-commit-show-diff nil) ;; do not show diff by default on commit

(use-package recentf
  :ensure nil
  :config
  (setq recentf-max-saved-items 200
        recentf-keep '(file-remote-p recentf-keep-default-predicate))
  (recentf-mode 1))

;; pi works well with tramp rpc
(use-package pilish
  :ensure t
  )
(defalias 'pi 'pilish)

(use-package acp
  :ensure t)

(use-package agent-shell
  :ensure t)

(setq agent-shell-mistral-authentication
      (agent-shell-mistral-make-authentication
       :api-key (lambda ()
	          (string-trim
		   (shell-command-to-string "source ~/.vibe/.env; echo $MISTRAL_API_KEY")))))

(use-package agent-shell-tramp
  :vc (:url "https://github.com/junyi-hou/agent-shell-tramp"
	    :branch "main")
  :after agent-shell
  :config
  (agent-shell-tramp-mode 1))

;; Render ANSI colors in compile/project-compile output, including over TRAMP RPC.
(use-package ansi-color
  :ensure nil
  :hook (compilation-filter . ansi-color-compilation-filter))

;; ghostty terminal
(use-package ghostel
  :ensure t)
(use-package ghostel-eshell
  :hook (eshell-load . ghostel-eshell-visual-command-mode))
(use-package ghostel-compile
  :hook (after-init . ghostel-compile-global-mode))
(use-package ghostel-shell-command
  :hook (after-init . ghostel-shell-command-global-mode))
(setq ghostel-tramp-shells
      '(("ssh" "/usr/bin/zsh")          ; auto-detect via getent
        ("sshx" login-shell)
        ("scp" login-shell)
	("rpc" "/usr/bin/zsh")
        ("docker" "/bin/sh")))

;; Auto complete
;; disabling in minibuffer to limit pressure when on ssh
(use-package company
  :ensure t
  :init
  (setq company-global-minibuffer nil))

;; Nordic theme (replaces the work machine's Kiro theme; single dark theme,
;; so the light/dark auto-dark switching is intentionally dropped).
(use-package nord-theme
  :ensure t
  :config
  (load-theme 'nord t))

(use-package markdown-mode :ensure t)

(use-package markdown-modern
  :vc (:url "https://github.com/rjprins/markdown-modern"
       :lisp-dir "lisp"
       :rev :newest)
  :mode ("\\.md\\'" . markdown-modern-mode))

;; Multiple cursors, of course
(use-package multiple-cursors
  :ensure t
  :custom (mc/always-run-for-all t))

;; Window margin
(use-package olivetti
  :ensure t
  :hook (markdown-mode . olivetti-mode)
  :custom
  (olivetti-body-width 100))   ; text column width in characters (or a fraction like 0.7)

;; Languages modes
(use-package eglot
  :ensure t)
(add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode -1)))

(setq eglot-report-progress init-file-debug ; Prevent minibuffer spam
      eglot-autoshutdown t ; Shut down after killing last managed buffer

      ;; A setting of 0 means Eglot will not block the UI at all, allowing Emacs
      ;; to remain fully responsive, although LSP features will only become
      ;; available once the connection is established in the background.
      eglot-sync-connect 0

      ;; Activate Eglot in cross-referenced non-project files
      eglot-extend-to-xref t

      ;; Disable margin indicators to prevent line-height shifts caused by emoji
      ;; font rendering issues. This disables both `left-fringe' and `margin'
      ;; indicators.
      eglot-code-action-indications '(eldoc-hint))

;; Eglot optimization
(if init-file-debug
    (setq eglot-events-buffer-config '(:size 2000000 :format full))
  ;; This reduces log clutter to improves performance.
  (with-no-warnings
    (setq eglot-events-buffer-size 0))  ; Deprecated
  (setq jsonrpc-event-hook nil
        ;; Reduce memory usage and avoid cluttering *EGLOT events* buffer
        eglot-events-buffer-config '(:size 0 :format short)))

(use-package zig-mode :ensure t)
(use-package eglot-typescript-preset :ensure t)

;; Git clone the package https://github.com/ArthurHeymans/emacs-term-sessions
;; Require zmx on each machine you want to run a term-session on.
;; Adjust the path to where the clone lives on this machine; the block is
;; skipped when the directory does not exist.
(let ((term-sessions-dir (expand-file-name "~/workplace/emacs-term-sessions")))
  (when (file-exists-p term-sessions-dir)
    (add-to-list 'load-path term-sessions-dir)
    (require 'term-sessions)
    (setq term-sessions-preferred-frontend 'ghostel)))

(use-package emrex
  :vc (:url "https://github.com/Kahnix/emrex")
  :config (emrex-mode 1))

;; Set personal keybindings
(global-set-key (kbd "M-o") #'open-line)
;; (global-set-key (kbd "C-o") #'pop-to-mark-command)
(global-set-key (kbd "C-x C-r") #'recentf-open)
(global-set-key (kbd "C-c d") #'eldoc-doc-buffer)

;; Multiple cursors
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; macOS-only (super = Cmd) keybindings.
(when (eq system-type 'darwin)
  (when (fboundp 'windmove-default-keybindings)
    (windmove-default-keybindings '(meta super)))
  (global-set-key (kbd "s-d") #'split-window-right)
  (global-set-key (kbd "s-D") #'split-window-below)
  (global-set-key (kbd "s-}") #'tab-next)
  (global-set-key (kbd "s-{") #'tab-previous)
  (global-set-key (kbd "s-t") #'tab-new)
  (global-set-key (kbd "s-T") (lambda () (interactive) (tab-last) (tab-new)))
  (global-set-key (kbd "s-w") #'delete-window)
  (global-set-key (kbd "s-W") #'tab-bar-close-tab)
  (global-set-key (kbd "s-<backspace>") (lambda () (interactive) (kill-region (point) (line-beginning-position))))
  (global-set-key (kbd "s-<up>") #'beginning-of-buffer)
  (global-set-key (kbd "s-<down>") #'end-of-buffer)
  (global-set-key (kbd "M-s-h") #'windmove-left)
  (global-set-key (kbd "M-s-j") #'windmove-down)
  (global-set-key (kbd "M-s-k") #'windmove-up)
  (global-set-key (kbd "M-s-l") #'windmove-right)
  ;; Tab switching
  (global-set-key (kbd "s-1") (lambda () (interactive) (tab-bar-select-tab '1)))
  (global-set-key (kbd "s-2") (lambda () (interactive) (tab-bar-select-tab '2)))
  (global-set-key (kbd "s-3") (lambda () (interactive) (tab-bar-select-tab '3)))
  (global-set-key (kbd "s-4") (lambda () (interactive) (tab-bar-select-tab '4)))
  (global-set-key (kbd "s-5") (lambda () (interactive) (tab-bar-select-tab '5)))
  (global-set-key (kbd "s-6") (lambda () (interactive) (tab-bar-select-tab '6)))
  (global-set-key (kbd "s-7") (lambda () (interactive) (tab-bar-select-tab '7)))
  (global-set-key (kbd "s-8") (lambda () (interactive) (tab-bar-select-tab '8)))
  (global-set-key (kbd "s-9") (lambda () (interactive) (tab-bar-select-tab '9))))

;; Set keybindings for org mode
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; Remote access via TRAMP RPC.

;; Avoid remote lock-file round trips, including Magit's temporary files.
(setq remote-file-name-inhibit-locks t)

;; Add elements to tramp path
(with-eval-after-load 'tramp
  (add-to-list 'tramp-remote-path "~/.local/share/mise/shims")
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(setq tramp-verbose 1
      remote-file-name-inhibit-cache 50
      ;; Disable lockfiles and auto-saves for remote files to eliminate lag
      remote-file-name-inhibit-locks t
      remote-file-name-inhibit-auto-save-visited t)

;; RPC backend for remote file access and processes.
(use-package tramp-rpc
  :after tramp
  :vc (:url "https://github.com/ArthurHeymans/emacs-tramp-rpc"
       :rev "v0.17.0"
       :lisp-dir "lisp"))
(add-to-list 'tramp-connection-properties
             (list "/rpc:" "remote-shell" "/usr/bin/zsh"))

;; async-shell-command (and ghostel-shell-command) read shell-file-name from
;; connection-local variables; use zsh on /rpc:clouddesk: instead of /bin/sh.
(with-eval-after-load 'tramp
  (connection-local-set-profile-variables
   'aurbenoi-clouddesk-zsh
   '((shell-file-name . "/usr/bin/zsh")
     (shell-command-switch . "-c")))
  (connection-local-set-profiles
   '(:application tramp :protocol "rpc" :machine "clouddesk")
   'aurbenoi-clouddesk-zsh))

(add-hook 'after-init-hook 'global-company-mode)
