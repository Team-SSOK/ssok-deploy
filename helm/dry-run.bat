@Echo off

helm template --dry-run --debug --namespace kafka ssok-kafka ./ssok-kafka >> ./dry-run/ssok-kafka-template.yaml
helm template --dry-run --debug --namespace bank ssok-bank ./ssok-bank >> ./dry-run/ssok-bank-template.yaml
helm template --dry-run --debug --namespace bank ssok-bank-proxy ./ssok-bank-proxy >> ./dry-run/ssok-bank-proxy-template.yaml
helm template --dry-run --debug --namespace ssok ssok-account-service ./ssok-account-service >> ./dry-run/ssok-account-service-template.yaml
helm template --dry-run --debug --namespace ssok ssok-bluetooth-service ./ssok-bluetooth-service >> ./dry-run/ssok-bluetooth-service-template.yaml
helm template --dry-run --debug --namespace ssok ssok-gateway-service ./ssok-gateway-service >> ./dry-run/ssok-gateway-service-template.yaml
helm template --dry-run --debug --namespace ssok ssok-notification-service ./ssok-notification-service >> ./dry-run/ssok-notification-service-template.yaml
helm template --dry-run --debug --namespace ssok ssok-transfer-service ./ssok-transfer-service >> ./dry-run/ssok-transfer-service-template.yaml
helm template --dry-run --debug --namespace ssok ssok-user-service ./ssok-user-service >> ./dry-run/ssok-user-service-template.yaml
helm template --dry-run --debug --namespace openbanking ssok-openbanking ./ssok-openbanking >> ./dry-run/ssok-openbanking-template.yaml

pause