(use-modules (shepherd service timer)
             (shepherd service repl)
             (ice-9 ftw))

;; Auto-load all service definitions from the services directory
;; Each service file should call (register-services (list service-name)) itself
(let ((services-dir  "/usr/etc/shepherd.d"))
  (for-each
    (lambda (file)
      (when (string-suffix? ".scm" file)
        (load (string-append services-dir "/" file))))
    (or (scandir services-dir
                 (lambda (f) (string-suffix? ".scm" f)))
        '())))

(define dhcpcd
  (service
    '(dhcpcd)
    #:start (make-forkexec-constructor
              '("dhcpcd" "-B" "-M"))
    #:stop (make-kill-destructor)
    #:respawn? #t))

(register-services (list (repl-service) dhcpcd))
(start-in-the-background
  '(agetty-tty1
    agetty-tty2
    agetty-tty3
    agetty-tty4
    agetty-tty5
    agetty-tty6
    dhcpcd))
