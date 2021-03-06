(ql:quickload "cffi")
(defpackage :cl-cffi
  (:use :cl
        :cffi))
(in-package :cl-cffi)

(load "libwiringPi.lisp" :external-format :utf-8)

(defconstant +i2c-addr+ #X3C)
(defvar *fd* (wiringPiI2CSetup +i2c-addr+))

;;; Initialize Command
(defconstant +ssd1306-disp-on+           #XAF)
(defconstant +ssd1306-disp-off+          #XAE)
(defconstant +ssd1306-set-disp-clk-div+  #XD5)
(defconstant +ssd1306-set-multiplex+     #XA8)
(defconstant +ssd1306-set-disp-offset+   #XD3)
(defconstant +ssd1306-set-start-line+    #X40)
(defconstant +ssd1306-seg-re-map+        #XA0)
(defconstant +ssd1306-com-scan-inc+      #XC0)
(defconstant +ssd1306-com-scan-dec+      #XC8)
(defconstant +ssd1306-set-com-pins+      #XDA)
(defconstant +ssd1306-set-contrast+      #X81)
(defconstant +ssd1306-disp-allon-resume+ #XA4)
(defconstant +ssd1306-normal-disp+       #XA6)
(defconstant +ssd1306-charge-pump+       #X8D)
(defconstant +ssd1306-deactivate-scroll+ #X2E)
(defconstant +ssd1306-set-mem-addr-mode+ #X20)
(defconstant +ssd1306-set-column-addr+   #X21)
(defconstant +ssd1306-set-page-addr+     #X22)

;;; Control Byte
;; Co bit = 0 (continue), D/C# = 0 (command)
(defconstant +ssd1306-command+           #X00)
;; Co bit = 0 (continue), D/C# = 1 (data)
(defconstant +ssd1306-data+              #X40)
;; Co bit = 1 (One command only), D/C# = 0 (command)
(defconstant +ssd1306-control+           #X80)

;;; OLED Info
(defconstant +ssd1306-lcd-width+         128)
(defconstant +ssd1306-lcd-height+        64)

(defconstant +dot+
  (make-array
   '(8)
   :initial-contents
   '(#B11111111
     #B00000111 
     #B11111111 
     #B00000011 
     #B00000101 
     #B00001001 
     #B00010001 
     #B00100001)))

(defun ssd1306-command (value)
  (wiringPiI2CWriteReg8 *fd* +ssd1306-command+ value))

(defun ssd1306-data (value)
  (wiringPiI2CWriteReg8 *fd* +ssd1306-data+ value))

(defun ssd1306-control (value)
  (wiringPiI2CWriteReg8 *fd* +ssd1306-control+ value))

(defun ssd1306-init ()
  ;; Display Off                         #XAE
  (ssd1306-command +ssd1306-disp-off+)
  
  ;; Set MUX Raio                        #XA8, #X3F(63)
  (ssd1306-command +ssd1306-set-multiplex+)
  (ssd1306-command (1- +ssd1306-lcd-height+))

  ;; Set Display Offset                  #XD3, #X00
  (ssd1306-command +ssd1306-set-disp-offset+)
  (ssd1306-command #X00)   ; no offset

  ;; Set Display Start Line              #X40
  (ssd1306-command +ssd1306-set-start-line+)

  ;; Set Segment re-map                  #XA0/#XA1
  (ssd1306-command +ssd1306-seg-re-map+)

  ;; Set COM Output Scan Direction       #XC0/#XC8
  (ssd1306-command +ssd1306-com-scan-inc+)

  ;; Set COM Pins hardware configuration #XDA, #X02
  (ssd1306-command +ssd1306-set-com-pins+)
  (ssd1306-command #X02)

  ;; Set Contrast Control                #X81, #X7F
  (ssd1306-command +ssd1306-set-contrast+)
  (ssd1306-command #X7F)

  ;; Disable Entire Display On           #XA4
  (ssd1306-command +ssd1306-disp-allon-resume+)

  ;; Set Normal Display                  #XA6
  (ssd1306-command +ssd1306-normal-disp+)

  ;; Set Osc Frequency                   #XD5, #X80
  (ssd1306-command +ssd1306-set-disp-clk-div+)
  (ssd1306-command #X80)   ; the suggested ratio 0x80

  ;; Deactivate scroll                   #X2E
  (ssd1306-command +ssd1306-deactivate-scroll+)

  ;; Set Memory Addressing Mode          #X20, #X10
  (ssd1306-command +ssd1306-set-mem-addr-mode+)
  (ssd1306-command #X10)   ; Page addressing Mode

  ;; Set Column Address                  #X21
  (ssd1306-command +ssd1306-set-column-addr+)
  (ssd1306-command 0)      ; Column Start Address
  (ssd1306-command 127)    ; Column Stop Address

  ;; Set Page Address                    #X22
  (ssd1306-command +ssd1306-set-page-addr+)
  (ssd1306-command 0)      ; Vertical start position
  (ssd1306-command 7)      ; Vertical end position

  ;; Enable change pump regulator        #X8D, #X14
  (ssd1306-command +ssd1306-charge-pump+)
  (ssd1306-command #X14)

  ;; Display On                          #XAF
  (ssd1306-command +ssd1306-disp-on+))

(defun display-black ()
  (dotimes (i 8)
    (ssd1306-control (logior #XB0 i))   ; set page start address
    (dotimes (j 16)
      (dotimes (k 8)
        (ssd1306-data #X00)))))

(defun display-picture ()
  (dotimes (on-off 2)
    (dotimes (i 8)
      (ssd1306-command (logior #XB0 i))           ; Set Page Start Address
      (ssd1306-command +ssd1306-set-column-addr+) ; Set Column Address
      (ssd1306-command (logior #X00 0))           ; Start column address
      (ssd1306-command #X7F)                      ; Stop column Address
      (dotimes (j 16)
        (if (= on-off 1)
            (dotimes (k 8)
              (ssd1306-data #X00))
            (dotimes (k 8)
              (ssd1306-data (aref +dot+ k))))))
    (delay 1000)))

(defun main ()
  (ssd1306-init)
  (display-black)
  (dotimes (n 10)
    (display-picture)))

(main)
