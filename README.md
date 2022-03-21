# kafka-docker-kubernetes
configuration for running kafka in docker and kubernetes

## Best practices for creating stateful applications
1. Create a separate namespace for databases.
2. Place all the needed components for stateful applications, such as ConfigMaps, Secrets, and Services, in the particular namespace.
3. Put your custom scripts in the ConfigMaps.
4. Use headless service instead of load balancer service while creating Service objects.
5. Use the HashiCorp Vault for storing your Secrets.
6. Use the persistent volume storage for storing the data. Then your data won’t be deleted even if the Pod dies or crashes.
