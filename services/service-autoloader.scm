(register-services (list
  (service
    '(service-autoloader)
    #:start (make-forkexec-constructor
              '("service-autoloader"))
    #:stop (make-kill-destructor)
    #:respawn? #t)))
