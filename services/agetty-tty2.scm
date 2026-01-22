(define agetty-tty2
  (service
    '(agetty-tty2)
    #:start (make-forkexec-constructor
              '("agetty" "tty2" "38400" "linux"))
    #:stop (make-kill-destructor)
    #:respawn? #t))
(register-services (list agetty-tty2))
