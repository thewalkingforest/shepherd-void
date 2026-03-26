(use-modules (shepherd service timer)
             (shepherd service repl)
             (ice-9 ftw)
             (blackcat shepherd))

(load-services-dir "/etc/shepherd.d")

(register-services (list (repl-service)))
(start-in-the-background
  '(agetty-tty1
    agetty-tty2
    agetty-tty3
    agetty-tty4
    agetty-tty5
    agetty-tty6))
