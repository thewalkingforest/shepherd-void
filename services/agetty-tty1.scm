(define agetty-tty1
  (service
    '(agetty-tty1)
    #:start (make-forkexec-constructor
              '("agetty" "--noclear" "tty1" "38400" "linux"))
    #:stop (make-kill-destructor)
    #:respawn? #t))
