(define agetty-tty6
  (service
    '(agetty-tty6)
    #:start (make-forkexec-constructor
              '("agetty" "tty6" "38400" "linux"))
    #:stop (make-kill-destructor)
    #:respawn? #t))
(register-services (list agetty-tty6))
