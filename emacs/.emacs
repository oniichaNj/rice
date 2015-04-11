(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/load")


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(fringe-mode 0 nil (fringe))
 '(inhibit-startup-screen t)
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil)
 '(tooltip-mode nil)
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "berry" :foundry "spectrum" :slant normal :weight normal :height 83 :width normal)))))

(defun remove-bold-from-the-premises ()
  (interactive)
  (mapc
   (lambda (face)
     (set-face-attribute face nil :weight 'normal :underline nil))
   (face-list)))
 


(require 'go-mode-load)
(add-hook 'before-save-hook 'gofmt-before-save)
(require 'erc-urlserv)
(add-hook 'erc-server-PRIVMSG-functions 'erc-urlserv-hook)

(require 'znc)

(defun cat-noise ()
  (interactive)
  (let ((l '("mew" "meow" "roar" "rawr" "rewr" "mrw" "mrow" "mrwrw")))
    (insert (nth (random (length l)) l))))


(setq erc-modules (quote (autojoin button completion fill irccontrols
				   list match menu move-to-prompt netsplit networks noncommands readonly
				   ring stamp cloud-to-butt hl-nicks)))
(tool-bar-mode -1)
(menu-bar-mode -1)
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(defun erc-my-privmsg-sound (proc parsed)
  (let* ((tgt (car (erc-response.command-args parsed)))
	 (privp (erc-current-nick-p tgt)))
    (if privp
	(beep)))
  nil)

(add-hook 'erc-server-PRIVMSG-functions 'erc-my-privmsg-sound)
(setq erc-text-matched-hook (quote (erc-beep-on-match)))
(quote (erc-beep-on-match erc-my-switch-to-buffer))
(setq erc-beep-match-types (quote (keyword current-nick)))

(defun erc-my-switch-to-highlight (proc parsed)
  (let ((msg (erc-response.contents parsed))
	(channel (car (erc-response.command-args parsed)))
	(sender (erc-response.sender parsed)))
    (when (string-match (downcase (erc-current-nick)) (downcase msg))
      (if (erc-nick-equal-p channel (erc-current-nick))
	  (pop-to-buffer (car (split-string sender "!")))
	(pop-to-buffer channel))))
  nil)
(add-hook 'erc-server-PRIVMSG-functions 'erc-my-switch-to-highlight)

(defun urgent-hint ()
  (let ((wm-hints (append (x-window-property "WM_HINTS" nil "WM_HINTS" nil nil t) nil)))
    (setcar wm-hints (logior (car wm-hints) #x00000100))
    (x-change-window-property "WM_HINTS" wm-hints nil "WM_HINTS" 32 t)))
 
(setq ring-bell-function #'urgent-hint)

;; np
(defun mpd-erc-np ()
  (interactive)
  (erc-send-message
   (concat "NP~ "
	   (let ((string (shell-command-to-string "mpc")))
	     (string-match "[^/]*$" string)
	     (match-string 0 string)))))


; Playsync
(require 'playsync)
(setq erc-playsync-allowed-nicks '("nick")
(setq erc-playsync-window-search-type "--class")
(setq erc-playsync-window-search-string "mpv")
(setq erc-playsync-switch-back nil)

;; SLIME stuff
(load (expand-file-name "~/.quicklisp/slime-helper.el"))
(setq inferior-lisp-program "sbcl")

;; Emoji
(set-fontset-font "fontset-default" 'unicode "Segoe UI Emoji")
(set-fontset-font "fontset-default" 'unicode "Symbola" nil 'append)


(remove-bold-from-the-premises) 
