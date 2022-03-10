### bootstrap.server 
  ```
  kubectl get kafka kafka-cluster -o=jsonpath='{.status.listeners[?(@.type=="external")].bootstrapServers}{"\n"}
  ```

### commands to create truststore and keystore cert and passwords for SSL cluster
  ```
  kubectl get secret kafka-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.p12}' | base64 -d > ca.p12
  kubectl get secret kafka-cluster-cluster-ca-cert -o jsonpath='{.data.ca\.password}' | base64 -d > ca.password
  kubectl get secret super-user -o jsonpath='{.data.user\.p12}' | base64 -d > user.p12
  kubectl get secret super-user -o jsonpath='{.data.user\.password}' | base64 -d > user.password
  ```
