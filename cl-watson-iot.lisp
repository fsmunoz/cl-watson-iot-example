;;;; cl-watson-iot.lisp
;;;; Watson IoT MQTT messaging example
;;;; 
;;;; This code was made to complement the following article
;;;; https://developer.ibm.com/recipes/tutorials/watson-iot-with-common-lisp/
;;;;
;;;; Author: Frederico Munoz <frederico.munoz@pt.ibm.com>
;;;; Date: APR 2017
;;;; License: Eclipse Public License v1.0

(require :abcl-contrib)
(require :jss)
(in-package #:cl-watson-iot)

;; Some global variables to simplify usage

;; Set *org-id* to your Org ID
(defvar *org-id*)
;; Set *password* to your own token
(defvar *password*)
;; Change if using a different Device Type name
(defparameter *device-id* "cl1" "Device ID")

(defparameter *username* "use-token-auth")
(defparameter *uri*
  (format nil "https://~A.messaging.internetofthings.ibmcloud.com:8883/api/v0002" *org-id*)
  "REST API URI")
(defparameter *device-type* "lispything" "Device Type")
(defparameter *mqtt-topic-name* "iot-2/evt/temp/fmt/json")
(defparameter *broker-url* (format nil "ssl://~A.messaging.internetofthings.ibmcloud.com:8883" *org-id*))
(defparameter *client-id* (format nil "d:~A:~A:~A" *org-id* *device-type* *device-id*))



;; REST API Example 

(defun send-data (device event property value &optional (uri *uri*) (device-type *device-type*) (username *username*) (password *password*))
  "Sends VALUE associated with KEY to DEVICE of DEVICE-TYPE in URI endpoint"
  (drakma::http-request
   (format nil "~A/device/types/~A/devices/~A/events/temp" uri device-type device event)
   :basic-authorization (list username password)
   :content-type "application/json"
   :method :post
   :content (format nil "{\"~A\":~A}" property value)))

;; MQTT Example

(defun mqtt-callback ()
  "Function called after delivery confirmation"
  (jss::jinterface-implementation "org.eclipse.paho.client.mqttv3.MqttCallback"
				  "connectionLost"
				  (lambda (cause)
				    (print cause))
				  "messageArrived"
				  (lambda (topic message) ;; not used 
				    (print (format nil "Topic: ~A" (#"getName" topic)))
				    (print (format nil "Message: ~A" (#"getPayload" message))))
				  "deliveryComplete"
				  (lambda (token)
				    (print "*** DELIVERY COMPLETE ***"))))

(defun mqtt-connect (topic broker-url client-id &optional username password)
  "Establishes a MQTT connection to TOPIC; returns the mqtt client
object. Optional arguments USERNAME and PASSWORD used for
authentication is present."
  (let ((mqtt-conn-options (jss::new 'MqttConnectOptions))
	(mqtt-client (jss::new 'MqttClient broker-url client-id))
	(ssl-context (#"getInstance" 'javax.net.ssl.SSLContext "TLSv1.2")))
    (#"setCleanSession" mqtt-conn-options jss::+true+)
    (#"setKeepAliveInterval" mqtt-conn-options 30)
    ;; When username and password are provided use them
    (when (and username password)
      (#"setUserName" mqtt-conn-options username)
      (#"setPassword" mqtt-conn-options (#"toCharArray" password)))
    ;; For Watson IoT we need to add TLS1.2
    (#"init" ssl-context jss::+null+ jss::+null+ jss::+null+)
    (#"setSocketFactory" mqtt-conn-options (#"getSocketFactory" ssl-context))
    (#"setCallback" mqtt-client (mqtt-callback))
    (#"connect" mqtt-client mqtt-conn-options)
    (print (format nil "Connected to ~A" broker-url))
    mqtt-client))2

(defun mqtt-create-message (message)
  "Creates a MQTT message from MESSAGE, a string"
  (let ((mqtt-message (jss::new 'MqttMessage (#"getBytes" message))))
    (#"setQos" mqtt-message 0)
    (#"setRetained" mqtt-message jss::+false+)
    mqtt-message))

(defun mqtt-publish (topic message)
  "Publishes MESSAGE to TOPIC"
  (print (format nil "*** PUBLISHING TO TOPIC ~A  ***" (#"toString" topic)))
  (#"waitForCompletion" (#"publish" topic message)))

(defun send-loop (&optional (times 20) (interval 2))
  "Main demo function, creates the connection and sends a message"
  (loop for c from 1 to times  do
       (let* ((client (mqtt-connect *mqtt-topic-name* *broker-url* *client-id* *username* *password*))
	      (topic (#"getTopic" client *mqtt-topic-name*)))
	 (mqtt-publish topic (mqtt-create-message (format nil "{\"temperature\":~A}" (random 50))))
	 (sleep interval)
	 (#"disconnect" client))))

;; Send some messages using the REST API
(loop for x from 10 to 21 do
     (send-data "cl1" "temp" "temperature" x)
     (sleep 0.5))


;; Send some messages using MQTT
(send-loop)


      
      
