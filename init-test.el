(setq package-archives
      '(("melpa"  . "https://melpa.org/packages/")
        ("org"    . "https://orgmode.org/elpa/")
        ("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/"))
      package-enable-at-startup nil)

(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package evil
  :hook (prog-mode . evil-mode))

(use-package corfu
  :hook (prog-mode . corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 1)
  :config
  (use-package cape
    :demand
    :custom
    (completion-at-point-functions (list (cape-capf-super 'cape-file 'cape-dabbrev 'cape-abbrev 'cape-keyword)))))

(use-package web-mode
  :mode
  ("\\.\\(vue\\|xml\\|html?\\)$" . web-mode))

(defvar maple-lsp 'lsp-bridge)

(pcase maple-lsp
  ('eglot
   (use-package eglot
     :hook (web-mode . eglot-ensure)
     :config

     (defun eglot-tailwindcss-options (server)
       `(:emmetCompletions
         t
         :experimental (:configFile ,(expand-file-name "tailwind.config.js" (project-root (eglot--project server))))))

     (add-to-list 'eglot-server-programs
                  '(web-mode . ("tailwindcss-language-server" "--stdio" :initializationOptions eglot-tailwindcss-options))))

   )
  ('lsp-mode
   (use-package lsp-mode
     :hook (web-mode . lsp-deferred)
     :custom
     (lsp-completion-provider :none))

   (use-package lsp-tailwindcss
     :hook (web-mode . (lambda () (require 'lsp-tailwindcss)))
     :custom
     (lsp-tailwindcss-add-on-mode t))
   )
  ('lsp-bridge
   (use-package lsp-bridge
     :load-path "site-lisp/lsp-bridge"
     :autoload (lsp-bridge-mode)
     :hook (web-mode . (lambda()
                         (when (bound-and-true-p corfu-mode) (corfu-mode -1))
                         (lsp-bridge-mode)))
     :custom
     (acm-enable-yas nil)
     (lsp-bridge-python-command (expand-file-name "versions/lsp-bridge/bin/python3" (getenv "PYENV_ROOT")))
     (lsp-bridge-multi-lang-server-mode-list
      '(((web-mode) . "html_tailwindcss")))
     (lsp-bridge-get-language-id
      (lambda (project-path file-path server-name extension-name)
        (when (string-equal server-name "tailwindcss")
          (cond ((string-equal extension-name "html") "html")
                ((string-equal extension-name "vue") "vue")
                (t ""))))
      )
     ;; (lsp-bridge-enable-completion-in-string t)
     ;; (lsp-bridge-multi-lang-server-extension-list
     ;;  '(
     ;;    (("vue")  . "html_tailwindcss")
     ;;    (("html") . "html_tailwindcss")))

     )))

(provide 'init)
;;; init-test.el ends here