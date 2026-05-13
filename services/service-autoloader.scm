(register-services (list
  (service
    '(service-autoloader)
    #:requirement '(system)
    #:start (make-forkexec-constructor
              '("service-autoloader"))
    #:stop (make-kill-destructor)
    #:respawn? #t)))
