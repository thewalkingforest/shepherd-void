(use-modules (shepherd service timer)
             (shepherd service repl)
             (ice-9 ftw))

(let ((services-dir  "/usr/etc/shepherd.d"))
  (for-each
    (lambda (file)
      (when (string-suffix? ".scm" file)
        (load (string-append services-dir "/" file))))
    (or (scandir services-dir
                 (lambda (f) (string-suffix? ".scm" f)))
        '())))

(register-services (list (repl-service)))
(start-in-the-background
  '(agetty-tty1
    agetty-tty2
    agetty-tty3
    agetty-tty4
    agetty-tty5
    agetty-tty6))
