(define seedrng
  (service
    '(seedrng)
    #:requirement '(hwclock)
    #:stop (lambda (_sig . _rst)
             (system* "seedrng")
             #f)))

(define hwclock
  (service
    '(hwclock)
    #:requirement '(udevadm)
    #:stop (lambda (_sig . _rst)
             (system* "hwclock" "--systohc")
             #f)))

; (define wtmp
;   (service
;     '(wtmp)
;     #:start (const #t)
;     #:stop (lambda (_sig . _rst)
;              (system "halt -w")
;              #f)))

(define udevadm
  (service
    '(udevadm)
    #:requirement '(pkill)
    #:stop (lambda (_sig . _rst)
             (system* "udevadm" "control" "--exit")
             #f)))

(define pkill
  (service
    '(pkill)
    #:requirement '(filesystems)
    #:stop (lambda (_sig . _rst)
             (system* "pkill" "--inverse" "-s0,1" "-TERM")
             (system* "pkill" "--inverse" "-s0,1" "-KILL")
             #f)))

(define filesystems
  (service
    '(filesystems)
    #:stop (lambda (_sig . _rst)
             (system* "swapoff" "-a")
             (system "umount" "-r" "-a" "-t" "nosysfs,noproc,nodevtmpfs,notmpfs")
             (let* ((env (cons* "LIBMOUNT_FORCE_MOUNT2=always" (environ)))
                    (pid (spawn "mount" '("mount" "-o" "remount,ro" "/") #:environment env)))
               (waitpid pid))
             #f)))

(define halt-hook
  (service
    '(halt-hook)
    #:requirement '(seedrng
                     hwclock
                     udevadm
                     pkill
                     filesystems)))

(define shutdown-services
  '(seedrng
    hwclock
    udevadm
    pkill
    filesystems
    halt-hook))

(register-services shutdown-services)
