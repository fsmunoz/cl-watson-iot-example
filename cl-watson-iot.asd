;;;; cl-watson-iot.asd

(asdf:defsystem #:cl-watson-iot
  :description "Watson IoT interaction with Common Lisp"
  :author "Frederico Muñoz <frederico.munoz@pt.ibm.com>"
  :license "EPL"
  :defsystem-depends-on (:abcl-asdf)
  :depends-on (#:drakma)
  :serial t
  :components ((:mvn "org.eclipse.paho/org.eclipse.paho.client.mqttv3/1.1.1")
	       (:file "package")
               (:file "cl-watson-iot")))

