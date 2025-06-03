@Echo off

helm package ./ssok-kafka
helm package ./ssok-kafka-v2
helm package ./ssok-bank
helm package ./ssok-bank-proxy
helm package ./ssok-account-service
helm package ./ssok-bluetooth-service
helm package ./ssok-gateway-service
helm package ./ssok-notification-service
helm package ./ssok-transfer-service
helm package ./ssok-user-service
helm package ./ssok-openbanking

helm repo index .

pause