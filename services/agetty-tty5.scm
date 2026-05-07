(register-services (list
  (service
    '(agetty-tty5)
    #:start (make-forkexec-constructor
              '("agetty" "tty5" "38400" "linux"))
    #:stop (make-kill-destructor)
    #:respawn? #t)))
