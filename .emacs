(require 'package)

; manually added plugins
; https://github.com/coldnew/evil-elscreen/blob/master/evil-elscreen.el
(add-to-list 'load-path "~/.emacs.d/plugins/evil-elscreen")

; List the packages you want
(setq package-list '(
    evil
    evil-leader
    evil-nerd-commenter
    evil-easymotion
    neotree
    telephone-line
    elscreen
    color-theme
    gruvbox-theme
    modern-cpp-font-lock
    rtags
    flycheck
    auto-complete-clang-async
    company
    irony
    cmake-ide
))

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

; Activate all the packages (in particular autoloads)
(package-initialize)

; Update your local package index
(unless package-archive-contents
  (package-refresh-contents))

; Install all missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

; disable menu and toolbar
(menu-bar-mode -1)
(tool-bar-mode -1)

(global-linum-mode t)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

; shared clipboard
(setq select-enable-primary t)
(setq select-enable-clipboard t)
(setq save-interprogram-paste-before-kill t)

; disable annoying bell
(setq ring-bell-function 'ignore)

(require 'evil-leader)
(global-evil-leader-mode)
(global-unset-key ",")
(evil-leader/set-leader ",")

;; Vim key bindings
(require 'evil-nerd-commenter)
(evil-leader/set-key
  "ci" 'evilnc-comment-or-uncomment-lines
  "cl" 'evilnc-quick-comment-or-uncomment-to-the-line
  "ll" 'evilnc-quick-comment-or-uncomment-to-the-line
  "cc" 'evilnc-copy-and-comment-lines
  "cp" 'evilnc-comment-or-uncomment-paragraphs
  "cr" 'comment-or-uncomment-region
  "cv" 'evilnc-toggle-invert-comment-line-by-line
  "."  'evilnc-copy-and-comment-operator
  "\\" 'evilnc-comment-operator ; if you prefer backslash key
)

(require 'evil-easymotion)
(evilem-make-motion my-forward-word-begin  #'evil-forward-word-begin)
(evilem-make-motion my-forward-WORD-begin  #'evil-forward-WORD-begin)
(evilem-make-motion my-forward-word-end    #'evil-forward-word-end)
(evilem-make-motion my-forward-WORD-end    #'evil-forward-END-end)
(evilem-make-motion my-backward-word-begin #'evil-backward-word-begin)
(evilem-make-motion my-backward-WORD-begin #'evil-backward-WORD-begin)
(evilem-make-motion my-next-line           #'evil-next-line)
(evilem-make-motion my-previous-line       #'evil-previous-line)

(evil-leader/set-key
  "W" 'my-forward-word-begin
  "w" 'my-forward-WORD-begin
  "E" 'my-forward-word-end
  "e" 'my-forward-WORD-end
  "B" 'my-backward-word-begin
  "b" 'my-backward-WORD-begin
  "j" 'my-next-line
  "k" 'my-previous-line
)

(require 'neotree)
(global-set-key [f12] 'neotree-toggle)

(require 'telephone-line)
(setq telephone-line-primary-left-separator     'telephone-line-cubed-left
      telephone-line-secondary-left-separator   'telephone-line-cubed-left
      telephone-line-primary-right-separator    'telephone-line-cubed-right
      telephone-line-secondary-right-separator  'telephone-line-cubed-right)

(telephone-line-mode 1)

(require 'elscreen)
(elscreen-start)
(require 'evil-elscreen)
; quit closes the whole application by default
(evil-ex-define-cmd "quit" 'delete-window)
(evil-ex-define-cmd "q" "quit")

(setq w32-enable-italics t)
(set-default-font "Hack 11")

(load-theme 'gruvbox t)

(require 'evil)
(define-key evil-motion-state-map (kbd ";") 'evil-ex)

(define-key evil-normal-state-map (kbd "C-j") 'evil-elscreen/tab-previous)
(define-key evil-normal-state-map (kbd "C-k") 'evil-elscreen/tab-next)
(define-key evil-insert-state-map (kbd "C-j") 'evil-elscreen/tab-previous)
(define-key evil-insert-state-map (kbd "C-k") 'evil-elscreen/tab-next)

(global-set-key (kbd "M-j") 'windmove-down)
(global-set-key (kbd "M-k") 'windmove-up)
(global-set-key (kbd "M-h") 'windmove-left)
(global-set-key (kbd "M-l") 'windmove-right)

(evil-mode t)

(require 'flycheck)
(global-flycheck-mode)
(require 'auto-complete-clang-async)
(require 'company)
(require 'irony)

(require 'cmake-ide)
(setq cmake-ide-build-dir "build")
(setq cmake-compile-command "clang")
(cmake-ide-setup)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (## auto-complete-clang-async cmake-ide irony company company-clang auto-complete-clang flycheck rtags telephone-line powerline-evil neotree gruvbox-theme evil-nerd-commenter evil-leader evil-easymotion elscreen color-theme-modern color-theme airline-themes))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
