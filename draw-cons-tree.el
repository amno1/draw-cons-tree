;;; draw-cons-tree.el Draw ascii image of a cons tree.  -*- lexical-binding: t; -*-
;; Ported from scheme to common lisp
;; http://www.t3x.org/s9fes/draw-tree.scm.html
;; It was in the public domain before so it will stay that way now.
;; Ported from common lisp to emacs lisp
;; https://github.com/cbaggers/draw-cons-tree

;; Version: 1.0

(require 'cl-lib)

;;; Entry function
(defun draw-cons-tree (n)
  (cl-labels
      ((%draw-tree (n)
                   (unless (draw-cons-tree--donep n)
                     (insert "\n")
                     (draw-cons-tree--draw-bars n)
                     (insert "\n")
                     (%draw-tree (draw-cons-tree--draw-members n)))))
    (if (not (consp n))
        (draw-cons-tree--draw-atom n)
      (%draw-tree (draw-cons-tree--mark-visited
                   (draw-cons-tree--draw-conses n))))
    (insert "\n")))

;;; Internal functions
;;; Helpers

(defconst draw-cons-tree--nothing (cons 'N nil))
(defconst draw-cons-tree--visited (cons 'V nil))

(defun draw-cons-tree--mark-visited (x)
  (cons draw-cons-tree--visited x))

(defun draw-cons-tree--members-of-x (x)
  (cdr x))

(defun draw-cons-tree--emptyp (x)
  (equal x draw-cons-tree--nothing))

(defun draw-cons-tree--visitedp (x)
  (equal (car x) draw-cons-tree--visited))

(defun draw-cons-tree--donep (x) 
  (and (consp x) (draw-cons-tree--visitedp x) (null (cdr x))))

(defun draw-cons-tree--all-verticalp (n)
  (or (not (consp n))
      (and (null (cdr n))
           (draw-cons-tree--all-verticalp (car n)))))

(defun draw-cons-tree--skip-empty (n)
  (if (and (consp n)
           (or (draw-cons-tree--emptyp (car n))
               (draw-cons-tree--donep (car n))))
      (draw-cons-tree--skip-empty (cdr n))
    n))

(defun draw-cons-tree--remove-trailing-nothing (n)
  (reverse (draw-cons-tree--skip-empty (reverse n))))

;;; Drawing

(defun draw-cons-tree--draw-fixed-string (s)
  (let* ((b (make-string 8 ?\s))
         (k (length s))
         (s (if (> k 7) (cl-subseq s 0 7) s))
         (s (if (< k 3 ) (cl-concatenate 'string " " s) s))
         (k (length s)))
    (insert (cl-concatenate 'string s (cl-subseq b 0 (- 8 k))))))

(defun draw-cons-tree--draw-atom (n)
  (draw-cons-tree--draw-fixed-string (format "%s" n)))

(defun draw-cons-tree--draw-conses (n &optional r)
  (cond ((not (consp n))
         (draw-cons-tree--draw-atom n)
         (setq r (nreverse r)))
        ((null (cdr n))
         (insert "[o|/]")
         (setq r (nreverse (cons (car n) r))))
        (t
         (insert "[o|o]---")
         (draw-cons-tree--draw-conses (cdr n) (cons (car n) r)))))

(defun draw-cons-tree--draw-bars (n)
  (cl-labels
      ((%draw-bars (n)
                   (cond ((not (consp n)))
                         ((draw-cons-tree--emptyp (car n))
                          (draw-cons-tree--draw-fixed-string "")
                          (%draw-bars (cdr n))
                          )
                         ((and (consp (car n)) (draw-cons-tree--visitedp (car n)))
                          (%draw-bars (draw-cons-tree--members-of-x (car n)))
                          (%draw-bars (cdr n)))
                         (t (draw-cons-tree--draw-fixed-string "|")
                            (%draw-bars (cdr n))))))
    (%draw-bars (draw-cons-tree--members-of-x n))))

(defun draw-cons-tree--draw-members (n)
  (cl-labels
      ((%draw-members (n r)
                      (cond ((not (consp n))
                             (draw-cons-tree--mark-visited
                              (draw-cons-tree--remove-trailing-nothing
                               (setq r (nreverse r)))))
                            ((draw-cons-tree--emptyp (car n))
                             (draw-cons-tree--draw-fixed-string "")
                             (%draw-members (cdr n) (cons draw-cons-tree--nothing r)))
                            ((not (consp (car n)))
                             (draw-cons-tree--draw-atom (car n))
                             (%draw-members (cdr n) (cons draw-cons-tree--nothing r)))
                            ((null (cdr n))
                             (%draw-members
                              (cdr n)
                              (cons (draw-cons-tree--draw-final (car n)) r)))
                            ((draw-cons-tree--all-verticalp (car n))
                             (draw-cons-tree--draw-fixed-string "[o|/]")
                             (%draw-members (cdr n) (cons (caar n) r)))
                            (t (draw-cons-tree--draw-fixed-string "|")
                               (%draw-members (cdr n) (cons (car n) r))))))
    (%draw-members (draw-cons-tree--members-of-x n) nil)))

(defun draw-cons-tree--draw-final (n)
  (cond ((not (consp n))
         (draw-cons-tree--draw-atom n)
         draw-cons-tree--nothing)
        ((draw-cons-tree--visitedp n)
         (draw-cons-tree--draw-members n))
        (t
         (draw-cons-tree--mark-visited (draw-cons-tree--draw-conses n)))))

(provide 'draw-cons-tree)
;;; draw-cons-tree.el end here
