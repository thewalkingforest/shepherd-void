(register-services (list
  (service
    '(agetty-tty3)
    #:start (make-forkexec-constructor
              '("agetty" "tty3" "38400" "linux"))
    #:stop (make-kill-destructor)
    #:respawn? #t)))
