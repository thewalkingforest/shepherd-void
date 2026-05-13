(register-services (list
  (service
    '(agetty-tty4)
    #:requirement '(system)
    #:start (make-forkexec-constructor
              '("agetty" "tty4" "38400" "linux"))
    #:stop (make-kill-destructor)
    #:respawn? #t)))
