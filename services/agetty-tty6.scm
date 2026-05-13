(register-services (list
  (service
    '(agetty-tty6)
    #:requirement '(system)
    #:start (make-forkexec-constructor
              '("agetty" "tty6" "38400" "linux"))
    #:stop (make-kill-destructor)
    #:respawn? #t)))
