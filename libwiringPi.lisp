(define-foreign-library libwiringPi
  (:unix "libwiringPi.so"))

(use-foreign-library libwiringPi)

;;;; Core function

;; Initialization of the wiringPi
(defcfun "wiringPiSetupGpio" :int)

;; Set the mode of the GPIO pin
(defcfun "pinMode" :void (pin :int) (mode :int))

;; GPIO pin output control
(defcfun "digitalWrite" :void (pin :int) (value :int))

;; Waiting process
(defcfun "delay" :void (howlong :uint))

;; Set the state when nothing is connected to the terminal
(defcfun "pullUpDnControl" :void (pin :int) (pud :int))

;; Read the status of the GPIO pin
(defcfun "digitalRead" :int (pin :int))

;;;; I2C Library

;; Initialization of the I2C systems.
(defcfun "wiringPiI2CSetup" :int (fd :int))

;; Writes 8-bit data to the instructed device register.
(defcfun "wiringPiI2CWriteReg8" :int (fd :int) (reg :int) (data :int))

;; It reads the 16-bit value from the indicated device register.
(defcfun "wiringPiI2CReadReg16" :int (fd :int) (reg :int))

;;;; SPI library

;; Initialization of the SPI systems.
(defcfun "wiringPiSPISetup" :int (channel :int) (speed :int))

;; Execute concurrent write / read transactions on the selected SPI bus
(defcfun "wiringPiSPIDataRW" :int (channel :int) (data :pointer) (len :int))

;;;; Serial Library

;; Initialize the serial device and set the baud rate.
(defcfun "serialOpen" :int (device :string) (baud :int))

;; Close the device identified by the specified file descriptor.
(defcfun "serialClose" :void (fd :int))

;; Sends one byte to the device identified by the specified file descriptor.
(defcfun "serialPutchar" :void (fd :int) (c :unsigned-char))

;; Returns the next character available on the serial device.
;; This call blocks for up to 10 seconds if data is unavailable (when returning -1).
(defcfun "serialGetchar" :int (fd :int))
