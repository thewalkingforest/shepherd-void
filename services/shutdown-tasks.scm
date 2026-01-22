(define shutdown-tasks
  (service
    '(shutdown-tasks)
    #:start (const #t)
    #:stop (lambda ()
             (system "/sbin/shepherd-shutdown.sh")
             #f)))
(register-services (list shutdown-tasks))
