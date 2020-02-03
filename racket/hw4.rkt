#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

(define (sequence low high stride)
  (cond [(> low high) null]
	[#t (cons low (sequence (+ low stride) high stride))]))

(define (string-append-map xs suffix)
  (map (lambda (x) (string-append x suffix)) xs))

(define (list-nth-mod xs n)
  (cond [(< n 0) (error "list-nth-mod: negative number")]
	[(null? xs) (error "list-nth-mod: empty list")]
	[#t (car (list-tail xs (remainder n (length xs))))]))

(define (stream-for-n-steps s n)
  (cond [(= n 0) null]
	[#t (let ([pr (s)])
	      (cons (car pr) (stream-for-n-steps (cdr pr) (- n 1))))]))

(define funny-number-stream
  (letrec ([f (lambda (x)
		(cons (* (if (= (remainder x 5) 0) -1 1) x) (lambda () (f (+ x 1)))))])
    (lambda () (f 1))))

(define dan-then-dog
  (letrec ([l (list "dan.jpg" "dog.jpg")]
	   [f (lambda (x)
		(cons (list-nth-mod l x) (lambda () (f (+ x 1)))))])
    (lambda () (f 0))))

(define (stream-add-zero s)
  (letrec ([f (lambda (s) (cons (cons 0 (car (s))) (lambda () (f (cdr (s))))))])
    (lambda () (f s))))

(define (cycle-lists xs ys)
  (letrec ([f (lambda (x)
		(cons (cons (list-nth-mod xs x) (list-nth-mod ys x)) (lambda () (f (+ x 1)))))])
    (lambda () (f 0))))

(define (vector-assoc v vec)
  (letrec ([len (vector-length vec)]
	   [f (lambda (ith)
		(cond [(>= ith len) #f]
		      [#t (let ([ref  (vector-ref vec ith)])
			    (if (and (pair? ref) (equal? (car ref) v)) ref (f (+ 1 ith))))]))])
    (f 0)))

(define (cached-assoc xs n)
  (letrec ([memo (make-vector n)]
	   [ith 0]
	   [f (lambda (v)
		(let ([ans (vector-assoc v memo)])
		  (cond [ans (cdr ans)]
			[#t (letrec ([new-ans (vector-assoc v xs)])
			      (begin
				(vector-set! memo ith (cons v new-ans))
				(set! ith (remainder (+ 1 ith) n))
				new-ans))])))])
    f))
