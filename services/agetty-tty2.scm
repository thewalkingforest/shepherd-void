(register-services (list
  (service
    '(agetty-tty2)
    #:requirement '(system)
    #:start (make-forkexec-constructor
              '("agetty" "tty2" "38400" "linux"))
    #:stop (make-kill-destructor)
    #:respawn? #t)))
