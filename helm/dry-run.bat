@Echo off

helm template --dry-run --debug ssok-kafka ./ssok-kafka >> ./dry-run/ssok-kafka-template.yaml
helm template --dry-run --debug ssok-bank ./ssok-bank >> ./dry-run/ssok-bank-template.yaml
helm template --dry-run --debug ssok-bank-proxy ./ssok-bank-proxy >> ./dry-run/ssok-bank-proxy-template.yaml
helm template --dry-run --debug ssok-account-service ./ssok-account-service >> ./dry-run/ssok-account-service-template.yaml
helm template --dry-run --debug ssok-bluetooth-service ./ssok-bluetooth-service >> ./dry-run/ssok-bluetooth-service-template.yaml
helm template --dry-run --debug ssok-gateway-service ./ssok-gateway-service >> ./dry-run/ssok-gateway-service-template.yaml
helm template --dry-run --debug ssok-notification-service ./ssok-notification-service >> ./dry-run/ssok-notification-service-template.yaml
helm template --dry-run --debug ssok-transfer-service ./ssok-transfer-service >> ./dry-run/ssok-transfer-service-template.yaml
helm template --dry-run --debug ssok-user-service ./ssok-user-service >> ./dry-run/ssok-user-service-template.yaml
helm template --dry-run --debug ssok-openbanking ./ssok-openbanking >> ./dry-run/ssok-openbanking-template.yaml

pause