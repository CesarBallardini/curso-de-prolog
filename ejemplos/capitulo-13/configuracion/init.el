;;; init.el --- Emacs para programar en Prolog (curso de Prolog, capítulo 13)

;; Paquetes de GNU ELPA y de NonGNU ELPA, donde está sweeprolog. Emacs 28 y
;; posteriores ya incluyen NonGNU ELPA; la línea add-to-list hace falta en 27.
(require 'package)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(package-initialize)
(dolist (paquete '(sweeprolog ediprolog))
  (unless (package-installed-p paquete)
    (unless package-archive-contents (package-refresh-contents))
    (package-install paquete)))

;; sweep: SWI-Prolog dentro de Emacs. Los archivos .pl y .plt se abren en
;; sweeprolog-mode, y no en perl-mode, que Emacs asocia a .pl de fábrica.
(require 'sweeprolog)
(add-to-list 'auto-mode-alist '("\\.plt?\\'" . sweeprolog-mode))

;; ediprolog: F10 sobre una línea %?- evalúa la consulta y escribe las
;; respuestas debajo, en el mismo archivo.
(require 'ediprolog)
(global-set-key [f10] 'ediprolog-dwim)
