(let ((bootstrap-file (concat user-emacs-directory "straight/repos/straight.el/bootstrap.el"))
      (bootstrap-version 3))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)


; ORG-MODE install hack https://github.com/raxod502/straight.el/commit/3190d95ee0556233624a4fb3bd2342e1fcb516b1#diff-04c6e90faac2675aa89e2176d2eec7d8
(require 'subr-x)
(straight-use-package 'git)

(defun org-git-version ()
  "The Git version of 'org-mode'.
Inserted by installing 'org-mode' or when a release is made."
  (require 'git)
  (let ((git-repo (expand-file-name
                   "straight/repos/org/" user-emacs-directory)))
    (string-trim
     (git-run "describe"
              "--match=release\*"
              "--abbrev=6"
              "HEAD"))))

(defun org-release ()
  "The release version of 'org-mode'.
Inserted by installing 'org-mode' or when a release is made."
  (require 'git)
  (let ((git-repo (expand-file-name
                   "straight/repos/org/" user-emacs-directory)))
    (string-trim
     (string-remove-prefix
      "release_"
      (git-run "describe"
               "--match=release\*"
               "--abbrev=0"
               "HEAD")))))

(provide 'org-version)

(straight-use-package 'org)
; ORG-MODE install hack END

(setq-default indent-tabs-mode nil)

(set-face-attribute 'default nil :family "Inconsolata"
                               :foundry "PfEd"
                               :slant 'normal
                               :height 130
                               :weight 'normal
                               :width 'normal)

; Disable GUI
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(setq mode-line-position
      '(;; %p print percent of buffer above top of window, o Top, Bot or All
        ;; (-3 "%p")
        ;; %I print the size of the buffer, with kmG etc
        ;; (size-indication-mode ("/" (-4 "%I")))
        ;; " "
        ;; %l print the current line number
        ;; %c print the current column
        (line-number-mode ("%l" (column-number-mode ":%c")))))

; With truncate-lines, do not split word
(setq visual-line-mode 1)

; Start frames maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))


; Enable saving of minibuffer history and other variables
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring)
      savehist-file "~/.emacs.d/savehist")
(savehist-mode t)

(defun shorten-directory (dir max-length)
  "Show up to `max-length' characters of a directory name `dir'."
  (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
               (output ""))
       (when (and path (equal "" (car path)))
         (setq path (cdr path)))
       (while (and path (< (length output) (- max-length 4)))
         (setq output (concat (car path) "/" output))
         (setq path (cdr path)))
       (when path
         (setq output (concat ".../" output)))
       output))

(defvar mode-line-directory
  '(:propertize
    (:eval (if (buffer-file-name) (concat " " (shorten-directory default-directory 20)) " "))
                face mode-line-directory)
  "Formats the current directory.")
(put 'mode-line-directory 'risky-local-variable t)

(setq-default mode-line-buffer-identification
  (propertized-buffer-identification "%b "))

(setq-default mode-line-format
      '("%e"
        mode-line-front-space
        ;; mode-line-mule-info -- I'm always on utf-8
        mode-line-client
        mode-line-modified
        ;; mode-line-remote -- no need to indicate this specially
        ;; mode-line-frame-identification -- this is for text-mode emacs only
        " "
        mode-line-directory
        mode-line-buffer-identification
        " "
        mode-line-position
        ;; (vc-mode vc-mode)  -- I use magit, not vc-mode
        ;; (flycheck-mode flycheck-mode-line)
        " "
        ;; mode-line-modes
        mode-line-misc-info
        mode-line-end-spaces))

; Git-grep command
(defun completing-read-simple (prompt alist)
  "Equivalent to (completing-read PROMPT ALIST nil nil (car ALIST) (quote ALIST))."
  (completing-read prompt (symbol-value alist) nil nil nil alist))

(defun call-with-prefix (prefix function)
  "Call a function interactively like if \\<keymap> PREFIX FUNCTION was given."
  (interactive)
  (let ((current-prefix-arg (list prefix)))
    (call-interactively function)))

;; When saving a file that starts with `#!', make it executable.
(add-hook 'after-save-hook
	  'executable-make-buffer-file-executable-if-script-p)

(use-package evil
  :straight t
  :init
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  (global-unset-key (kbd "C-x +")) ; Set to "C-w =" with evil
  )

(use-package evil-collection
  :straight t
  :after evil
  :config
  (evil-collection-init))

(use-package mustang-theme
  :straight t)

(use-package magit-gh-pulls
  :straight t)

(use-package evil-magit
  :straight t)

(use-package magit
  :straight t
  :after magit-gh-pulls
  :init
  ;(add-hook 'magit-mode-hook 'turn-on-magit-gh-pulls)
  (setq magit-diff-refine-hunk t
	magit-diff-paint-whitespace t
	magit-diff-highlight-trailing t
	magit-process-popup-time 10
	magit-save-repository-buffers t
	magit-push-current-set-remote-if-missing t)
  :bind (("C-x g" . magit-status)))

(use-package ob-async
  :straight t)
(use-package ob-python)
(use-package ob-shell)

(use-package org
  :straight t
  :after ob-python ob-async ob-shell
  :init
  (defun my/org-mode-hook-evil ()
      (setq evil-auto-indent nil))
  (add-hook 'org-mode-hook 'my/org-mode-hook-evil)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (sql . t)
     (python . t)
     (shell . t)))
  (setq org-log-done 'time)
  :bind (("C-c j" . outline-next-heading)
         ("C-c k" . outline-previous-heading)
         ("C-c h" . outline-up-heading)
         ("C-c l" . outline-show-subtree)
         :map org-mode-map
         ("C-c o d" . org-cut-subtree)
         ("TAB" . org-cycle)))

(use-package pyenv-mode
  :straight t
  :config
  (pyenv-mode))

(setq mac-function-key-is-meta t)
(setq mac-function-modifier 'meta)

(use-package flycheck
  :straight t
  :config
  (setq flycheck-command-wrapper-function
        (lambda (command)
          (if (null (string-match "pylint" (car command)))
              command
	    (let* ((new-prefix (replace-regexp-in-string "pylint$" "python" (car command)))
		   (new-rest (append '("-m" "pylint") (cdr command)))
		   (new-command (append (list new-prefix) new-rest)))
	      new-command))))
  (global-flycheck-mode))

(use-package flycheck-popup-tip
  :straight t
  :after flycheck
  :config
  (flycheck-popup-tip-mode))

(use-package flyspell
  :config
  (progn
    (add-hook 'text-mode-hook #'turn-on-flyspell)
    (add-hook 'org-mode-hook #'turn-on-flyspell)
    (add-hook 'prog-mode-hook 'flyspell-prog-mode)))
(use-package pytest
  :straight t
  :bind (("C-c t t" . pytest-one)
	 ("C-c t m" . pytest-module)))

(use-package company-jedi
  :straight t
  :init
  (defun my/python-mode-hook-company-jedi ()
    (add-to-list 'company-backends 'company-jedi))
  (add-hook 'python-mode-hook 'my/python-mode-hook-company-jedi))

(use-package company
  :straight t
  :init
  (add-hook 'after-init-hook 'global-company-mode))

(use-package json-mode
  :straight t)

(use-package yaml-mode
  :straight t)

(use-package expand-region
  :straight t
  :bind (("C-c =" . er/expand-region)
	 ("C-c -" . (lambda () (interactive) (call-with-prefix -1 'er/expand-region)))))

(use-package htmlize
  :straight t)

(use-package git-link
  :straight t
  :config
  (defun git-link-master-branch ()
    (interactive)
    (let ((git-link-default-branch "master"))
      (call-interactively 'git-link)))
  (defun git-link-at-commit ()
    (interactive)
    (let ((git-link-use-commit t))
      (call-interactively 'git-link)))
  (defun git-link-master-branch-at-commit ()
    (interactive)
    (let ((git-link-default-branch "master")
	  (git-link-use-commit t))
      (call-interactively 'git-link))))

(use-package git-gutter-fringe+
  :straight t
  :config
  (global-git-gutter+-mode)
  (git-gutter-fr+-minimal)
  (setq git-gutter-fr+-side 'right-fringe))

(use-package groovy-mode
  :straight t)

(use-package markdown-mode
  :straight t)

(use-package exec-path-from-shell
  :straight t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package ox-hugo
  :straight t
  :after ox)

(defun use-region-or-expand-region ()
  "Use region if active or expand region at point."
  (when (not (use-region-p))
    (let ((inhibit-message t))
      (call-interactively 'er/expand-region))))

(defun eval-point-region-and-deactivate ()
  "Evaluate region or expanded region and deactivates region when done."
  (interactive)
  (use-region-or-expand-region)
  (condition-case-unless-debug err
      (call-interactively 'eval-region)
    (error (deactivate-mark)
           (signal (car err) (cdr err))))
  (deactivate-mark))


(defun get-region-or-line-content ()
  "Get region or line content."
  (if (use-region-p)
    (buffer-substring-no-properties (region-beginning) (region-end))
    (thing-at-point 'line t)))


(defun compile-region-or-line ()
  "Compile region or line content."
  (interactive)
  (compile (get-region-or-line-content) t))


(global-set-key (kbd "C-c s") 'compile-region-or-line)


(use-package elisp-mode
  :bind (("C-c C-c" . eval-point-region-and-deactivate)))

(use-package rainbow-delimiters
  :straight t
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package highlight-parentheses
  :straight t
  :config
  (global-highlight-parentheses-mode))

(use-package nameses
  :straight (nameses :type git :host nil :repo "https://gist.github.com/8960595.git")
  :init (require 'desktop)
  :bind (("C-c d d" . nameses-load)
         ("C-c d s" . nameses-save)
         ("C-c d r" . nameses-reset)))

(use-package ob-tmux
  :straight (ob-tmux :type git :host nil :repo "https://github.com/ahendriksen/ob-tmux.git")
  :config
  (setq org-babel-default-header-args:tmux
        '((:results . "silent")
          (:terminal . "iterm")))
  (setq org-babel-tmux-session-prefix "ob-"))

(use-package org-jira
  :straight t)

(use-package elm-mode
  :straight t)

(use-package flycheck-elm
  :straight t
  :after flycheck
  :init
  (add-hook 'flycheck-mode-hook #'flycheck-elm-setup))

(use-package haskell-mode
  :straight t)


(use-package ibuffer
  :straight t
  :bind (("C-x C-b" . 'ibuffer)))

(use-package ivy
  :straight t
  :after magit
  :init (global-unset-key (kbd "C-x f"))
  :bind (("C-s" . 'swiper)
         ("C-x f f" . 'counsel-git)
         ("C-x f g" . 'counsel-git-grep))
  :config
  (ivy-mode 1)
  (counsel-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-re-builders-alist
        '((t . ivy--regex-ignore-order)))
  (setq magit-completing-read-function 'ivy-completing-read))


(use-package helpful
  :straight t
  :bind (("C-h f" . #'helpful-callable)
         ("C-h v" . #'helpful-variable)
         ("C-h k" . #'helpful-key)))


(use-package graphviz-dot-mode
  :straight t)

(use-package eyebrowse
  :straight t
  :config
  (eyebrowse-mode 1))

(use-package systemd
  :straight t)

(use-package intero
  :straight t
  :config
  (intero-global-mode 1))


(defun ediff-buffer-mode-next-difference ()
  "Advance to the next difference."
  (interactive)
  (with-selected-window
      (get-buffer-window "*Ediff Control Panel*")
    (ediff-next-difference)))


(defun ediff-buffer-mode-previous-difference ()
  "Advance to the previous difference."
  (interactive)
  (with-selected-window
      (get-buffer-window "*Ediff Control Panel*")
    (ediff-previous-difference)))


(defun ediff-buffer-mode--get-current-buffer-char ()
  "Get char corresponding to current Ediff buffer."
  (let ((buff (current-buffer)))
    (with-selected-window
        (get-buffer-window "*Ediff Control Panel*")
      (cond ((eq buff ediff-buffer-A) ?a)
            ((eq buff ediff-buffer-B) ?b)
            ((eq buff ediff-buffer-C) ?c)))))


(defun ediff-buffer-mode--get-other-buffer-char (current-buffer-char)
  "For CURRENT-BUFFER-CHAR return other buffer chars."
  (remove current-buffer-char '(?a ?b ?c)))


(defun ediff-buffer-mode--prompt-other-source (current-buffer-char get-or-put)
  "For CURRENT-BUFFER-CHAR, prompt user for other buffer source with prompt adapting to GET-OR-PUT value."
  (let* ((prompt (if (string= get-or-put "get") "Select buffer to get changes from: "
                   "Select buffer to put changes to: "))
         (buffer-help (if (string= get-or-put "get") "Get from "
                        "Put to "))
         (choice
          (read-multiple-choice
           prompt
           (mapcar
            (lambda (char) (list char (concat buffer-help (string char))))
            (ediff-buffer-mode--get-other-buffer-char current-buffer-char)))))
    (car choice)))


(defun ediff-buffer-mode--validate-other-source (current-buffer-char other-buffer-char)
  "For CURRENT-BUFFER-CHAR, check OTHER-BUFFER-CHAR is an accepted char.

For example, for CURRENT-BUFFER-CHAR = ?a then the accepted chars are ?b and ?c."
  (let ((accepted-other-buffers (ediff-buffer-mode--get-other-buffer-char current-buffer-char)))
    (when (not (member other-buffer-char accepted-other-buffers))
      (error "Chosen buffer must be %s" (mapconcat (lambda (x) (string x)) accepted-other-buffers " or ")))))


(defun ediff-buffer-mode-get-changes (&optional get-src)
  "Get changes from the other window into the current window.

For 3-way jobs, the other window cannot be determined automatically.
In that case a prompt will ask the user to enter what buffer the change must come
from.  If GET-SRC is given, use that as the source and do not prompt the user."
  (interactive)
  (let ((buff-char (ediff-buffer-mode--get-current-buffer-char)))
    (with-selected-window
        (get-buffer-window "*Ediff Control Panel*")
      (if ediff-3way-job
          (progn
            (let* ((other-buff-char (ediff-buffer-mode--get-other-buffer-char buff-char))
                   (get-src (or get-src (ediff-buffer-mode--prompt-other-source buff-char "get"))))
              (ediff-buffer-mode--validate-other-source buff-char get-src)
              (cond ((and (char-equal buff-char ?a) (char-equal get-src ?b)) (ediff-copy-B-to-A nil))
                    ((and (char-equal buff-char ?a) (char-equal get-src ?c)) (ediff-copy-C-to-A nil))
                    ((and (char-equal buff-char ?b) (char-equal get-src ?a)) (ediff-copy-A-to-B nil))
                    ((and (char-equal buff-char ?b) (char-equal get-src ?c)) (ediff-copy-C-to-B nil))
                    ((and (char-equal buff-char ?c) (char-equal get-src ?a)) (ediff-copy-A-to-C nil))
                    ((and (char-equal buff-char ?c) (char-equal get-src ?b)) (ediff-copy-B-to-C nil)))))
        (progn
          (cond (char-equal buff-char ?a) (ediff-copy-B-to-A nil)
                (char-equal buff-char ?b) (ediff-copy-A-to-B nil)))))))


(defun ediff-buffer-mode-put-changes (&optional put-src)
  "Get changes from the other window into the current window.

For 3-way jobs, the other window cannot be determined automatically.
In that case a prompt will ask the user to enter what buffer the change must come
from.  If PUT-SRC is given, use that as the source and do not prompt the user."
  (interactive)
  (let ((buff-char (ediff-buffer-mode--get-current-buffer-char)))
    (with-selected-window
        (get-buffer-window "*Ediff Control Panel*")
      (if ediff-3way-job
          (progn
            (let* ((other-buff-char (ediff-buffer-mode--get-other-buffer-char buff-char))
                   (put-src (or put-src (ediff-buffer-mode--prompt-other-source buff-char "put"))))
              (ediff-buffer-mode--validate-other-source buff-char put-src)
              (cond ((and (char-equal buff-char ?a) (char-equal put-src ?b)) (ediff-copy-A-to-B nil))
                    ((and (char-equal buff-char ?a) (char-equal put-src ?c)) (ediff-copy-A-to-C nil))
                    ((and (char-equal buff-char ?b) (char-equal put-src ?a)) (ediff-copy-B-to-A nil))
                    ((and (char-equal buff-char ?b) (char-equal put-src ?c)) (ediff-copy-B-to-C nil))
                    ((and (char-equal buff-char ?c) (char-equal put-src ?a)) (ediff-copy-C-to-A nil))
                    ((and (char-equal buff-char ?c) (char-equal put-src ?b)) (ediff-copy-C-to-B nil)))))
        (progn
          (cond ((char-equal buff-char ?a) (ediff-copy-A-to-B nil))
                ((char-equal buff-char ?b) (ediff-copy-B-to-A nil))))))))


(defvar ediff-buffer-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-j") 'ediff-buffer-mode-next-difference)
    (define-key map (kbd "C-k") 'ediff-buffer-mode-previous-difference)
    (define-key map (kbd "C-c o") 'ediff-buffer-mode-get-changes)
    (define-key map (kbd "C-c p") 'ediff-buffer-mode-put-changes)
    map))


(define-minor-mode ediff-buffer-mode
  "Minor mode enabled on buffers used in Ediff."
  :init-value nil)


(defun enable-ediff-buffer-mode ()
  "Enable ediff=buffer-mode."
  (ediff-buffer-mode t))


(defun disable-all-ediff-buffer-mode ()
  "Enable ediff=buffer-mode."
  (with-selected-window
      (get-buffer-window "*Ediff Control Panel*")
    (if ediff-buffer-A
        (with-selected-window (get-buffer-window ediff-buffer-A)
          (ediff-buffer-mode -1)))
    (if ediff-buffer-B
        (with-selected-window (get-buffer-window ediff-buffer-B)
          (ediff-buffer-mode -1)))
    (if ediff-buffer-C
        (with-selected-window (get-buffer-window ediff-buffer-C)
          (ediff-buffer-mode -1)))))


(add-hook 'ediff-prepare-buffer-hook 'enable-ediff-buffer-mode)
(add-hook 'ediff-cleanup-hook 'disable-all-ediff-buffer-mode)
; Move custom-set-variables and custom-set-faces in different file
(setq custom-file "~/.emacs-custom.el")
(load custom-file)

; Prompt to save customization before quitting
(add-hook 'kill-emacs-query-functions
	  'custom-prompt-customize-unsaved-options)

(setenv "PGCONNECT_TIMEOUT" "5")
