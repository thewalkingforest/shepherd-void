(register-services (list
  (service
    '(service-watcher)
    #:start (make-forkexec-constructor
              '("service-watcher"))
    #:stop (make-kill-destructor)
    #:respawn? #t)))
