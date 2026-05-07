(register-services (list
  (service
    '(shutdown-tasks)
    #:start (const #t)
    #:stop (lambda ()
             (system "/sbin/shepherd-shutdown.sh")
             #f))))
