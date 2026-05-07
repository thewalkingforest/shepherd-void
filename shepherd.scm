(use-modules (shepherd service repl)
             (blackcat shepherd))

(load-services-dir "/etc/shepherd.d")

(register-services (list (repl-service)))
(start-in-the-background
  (cons*
    %core-services))
