;;;; cl-watson-iot.asd

(asdf:defsystem #:cl-watson-iot
  :description "Describe cl-watson-iot here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :defsystem-depends-on (:abcl-asdf)
  :depends-on (#:drakma)
  :serial t
  :components ((:mvn "org.eclipse.paho/org.eclipse.paho.client.mqttv3/1.1.1")
	       (:file "package")
               (:file "cl-watson-iot")))

