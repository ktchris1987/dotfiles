;; Magic .emacs file, hacked together by gergely.erdelyi@gmail.com
;; Bits and pieces of this file come from all over the 'Net.

;; Time how long loading this file takes
(require 'cl) ; a rare necessary use of REQUIRE
(defvar *emacs-load-start* (current-time))

;; Get the installed packages ready to roll right away
(require 'package)
(package-initialize)

;; Set up package sources
(setq package-archives '(("melpa" . "http://melpa.milkbox.net/packages/")
			 ("gnu" . "http://elpa.gnu.org/packages/")))

(defvar survival-kit
  '(auto-complete clojure-mode css-mode exec-path-from-shell js2-mode melpa solarized-theme)
  "A list of packages needed for this setup to work")

(defun survival-kit-is-complete-p ()
  (loop for p in survival-kit
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

(defun survival-kit-install ()
  (interactive)
  (unless (survival-kit-is-complete-p)
    (message "The survival kit is not complete! Installing the missing bits ...")
    (package-refresh-contents)
    (dolist (p survival-kit)
      (when (not (package-installed-p p))
	(message "Installing %s" p)
	(package-install p)))))

;; Make sure all my favourite packages are installed
(survival-kit-install)

(add-to-list 'load-path (expand-file-name "~/.elisp"))

;; Pull in some env vars for the Mac GUI version of Emacs
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "PATH")
  (exec-path-from-shell-copy-env "PYTHONPATH")
  (exec-path-from-shell-copy-env "PYMACS_PYTHON"))

;; UTF-8 is great(tm)
(set-language-environment "utf-8")

;; Highlight trailing whitespace
(setq-default show-trailing-whitespace t)

(defun backward-symbol (&optional arg)
  "Move backward until encountering the beginning of a symbol.
   With argument, do this that many times."
  (interactive "p")
  (forward-symbol (- (or arg 1))))

;; Crazy keyboard shortcut settings
(global-set-key (kbd "C-{") 'other-window)
(global-set-key (kbd "C-}") 'other-window-previous)
(global-set-key (kbd "C-`") 'other-frame)

(defun other-window-previous ()
  (interactive)
  (other-window -1))

(global-set-key '[M-left]  'backward-symbol)
(global-set-key '[M-right] 'forward-symbol)

(global-set-key "\M- " 'hippie-expand)

;; Disable ~ backups, that's what git is for ;)
(setq make-backup-files nil)

;; Set a decently sized font
(set-default-font "Inconsolata-20")

;; Enable column numbers
(column-number-mode)

;; Show matching parentheses
(show-paren-mode)

;; y will suffice for yes
(defalias 'yes-or-no-p 'y-or-n-p)

;; Fix indentation, the way I like it
(setq c-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 4)
		(setq c-default-style "bsd")
		(setq c-basic-offset 4))))
(setq c++-mode-hook
    (function (lambda ()
                (setq indent-tabs-mode nil)
                (setq c-indent-level 4)
		(setq c-default-style "bsd")
		(setq c-basic-offset 4))))

;; Indent JS with spaces
(setq js2-mode-hook
  '(lambda () (progn
    (set-variable 'indent-tabs-mode nil))))

;; Turn Command key into a Control. Emacs Pinky Problem be gone!
(setq mac-command-modifier 'control)

;; Turn off the toolbar
(tool-bar-mode 0)

;; Turn off scrollbars
(scroll-bar-mode 0)

;; Integrate with Mac clipboard
(setq x-select-enable-clipboard t)

;; Custom Anything source to find all files in my work directory
(defun my-get-source-directory (path)
  (expand-file-name "~/work/"))

(defvar my-anything-c-source-file-search
  '((name . "File Search")
    (init . (lambda ()
              (setq anything-default-directory
                    default-directory)))
    (candidates . (lambda ()
                    (let ((args
                           (format "'%s' \\( -path \\*/.svn \\) -prune -o -iregex '.*%s.*' -print"
                                   (my-get-source-directory anything-default-directory)
                                   anything-pattern)))
		      (start-process-shell-command "file-search-process" nil
						   "find" args))))
    (type . file)
    (requires-pattern . 4)
    (delayed))
  "Source for searching matching files recursively.")

;; Activate anything .. or something
(require 'anything-config)

(defun my-anything ()
   (interactive)
   (anything-other-buffer
    '(anything-c-source-buffers
      anything-c-source-file-name-history
      anything-c-source-files-in-current-dir
      my-anything-c-source-file-search)
    " *my-anything*"))

(global-set-key [f1] 'my-anything)

;; Enable auto-complete globally
(require 'auto-complete)
(global-auto-complete-mode t)

;;; bind RET to py-newline-and-indent
(add-hook 'python-mode-hook '(lambda ()
     (define-key python-mode-map "\C-m" 'newline-and-indent)))

;; Load up Pymacs and configure pylint for flymake
(autoload 'pymacs-load "pymacs" "pymacs" t)
(add-hook 'python-mode-hook
	  (lambda ()
	    (load-file "~/.elisp/pylint.el"))
	  (when (load "flymake" t)
	    (defun flymake-pylint-init ()
	      (let* ((temp-file (flymake-init-create-temp-buffer-copy
				 'flymake-create-temp-inplace))
		     (local-file (file-relative-name
				  temp-file
				  (file-name-directory buffer-file-name))))
		(list "~/.elisp/epylint.py" (list local-file))))
	    (add-to-list 'flymake-allowed-file-name-masks
			 '("\\.py\\'" flymake-pylint-init))))
(add-hook 'python-mode-hook
	  (lambda ()
	    (flymake-mode 1)
	    (setq indent-tabs-mode nil)))

(defun rope ()
   (interactive)
   (pymacs-load "ropemacs" "rope-")
   (setq ropemacs-enable-autoimport t)
   (ropemacs-mode))

;; Activate html-mode for HTML files
(setq auto-mode-alist (cons '("\\.html$" . html-mode) auto-mode-alist))

;; Make Cmd-Left/Right jump between tags
(add-hook 'html-mode-hook
	  (lambda ()
	    (define-key html-mode-map (kbd "<C-left>") 'sgml-skip-tag-backward)
	    (define-key html-mode-map (kbd "<C-right>") 'sgml-skip-tag-forward)))

;; Setup Emacs to run bash as its primary shell.
(setq shell-file-name "bash")
(setq shell-command-switch "-c")
(setq explicit-shell-file-name shell-file-name)
(setenv "SHELL" shell-file-name)
(setq explicit-sh-args '("-login" "-i"))

;; Use Spotlight for locate
(setq locate-command "mdfind")

;; Set up bookmarks (to be used w/ C-x r {m|b|l})
(setq
 bookmark-default-file "~/.elisp/bookmarks"
 bookmark-save-flag 1)

;; Insert a standard date
(defun insert-date ()
  (interactive
   (insert (format-time-string "%a, %d %b %Y %T %z"))))

;; Erlang mode set up for the MacPorts version
(setq load-path (cons "/opt/local/lib/erlang/lib/tools-2.6.6.5/emacs/"
		      load-path))
(setq erlang-root-dir "/usr/local/lib/erlang")
(setq exec-path (cons "/usr/local/lib/erlang/bin" exec-path))
(autoload 'erlang-mode "erlang-start" "Erlang mode" t)
(add-to-list 'auto-mode-alist '("\\.erl\\'" . erlang-mode))

;; Set up Slime for Clozure
(add-to-list 'load-path "/opt/local/share/emacs/site-lisp/slime")
(setq inferior-lisp-program "/opt/local/bin/ccl64 -K utf-8")
;; (autoload 'slime "slime" "SLIME" t)
(add-to-list 'auto-mode-alist '("\\.lisp\\'" .
				(lambda ()
				  (require 'slime)
				  (setq slime-net-coding-system 'utf-8-unix)
				  (slime-setup  '(slime-repl slime-asdf slime-fancy slime-banner)))))

;; Tweak the standard theme to be a bit less intrusive
;;  - Change the flymake faces to underlines
;;  - Make the mode line lighter (same is used for anything's header)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flymake-errline ((t (:underline "orange"))))
 '(flymake-warnline ((t (:underline "violet"))))
 '(header-line ((t (:inherit mode-line :background "#e9e2cb" :foreground "#465a61" :box nil :weight bold)))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("d2622a2a2966905a5237b54f35996ca6fda2f79a9253d44793cfe31079e3c92b" default)))
 '(custom-enabled-themes (quote (solarized-light)))
)

;; Print the time info
(message "My .emacs loaded in %ds" (destructuring-bind (hi lo ms) (current-time)
				     (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))
