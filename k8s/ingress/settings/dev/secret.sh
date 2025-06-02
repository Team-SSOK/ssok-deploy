cat cert.pem chain.pem > fullchain.pem

kubectl create secret tls kudong-ssok-tls-secret \
  --cert=fullchain.pem \
  --key=privkey.pem \
  --namespace=ssok

kubectl create secret tls kudong-bank-tls-secret \
  --cert=fullchain.pem \
  --key=privkey.pem \
  --namespace=bank

kubectl create secret tls kudong-logging-tls-secret \
  --cert=fullchain.pem \
  --key=privkey.pem \
  --namespace=logging

kubectl create secret tls kudong-monitoring-tls-secret \
  --cert=fullchain.pem \
  --key=privkey.pem \
  --namespace=monitoring