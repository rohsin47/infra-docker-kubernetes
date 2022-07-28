#!/bin/bash

# All objects to delete for
PROJECT=watergate-dit-infra
RESOURCE=postgres
OBJECT=pod
VALID_OBJECTS=statefulset,pvc,service,deployment,secret,configmap,pod

errorExit () {
	echo -e "\nERROR: $1\n"
	exit 1
}

usage () {
	cat << END_USAGE
Delete resource in a Kubernetes cluster for a given namespace. Ensure you are logged into openshift as auto login is not supported.
Usage: ${SCRIPT_NAME} <options>
-n | --namespace <name>					: Namespace
-r | --resource <name>					: Resource to delete
-o | --object <name>					: Objects to delete (comma separated list with valid values: statefulset,pvc,service,deployment,secret,configmap)
-h | --help						: Show this usage
Examples:
========
Delete postgres:					oc-clean.sh -n watergate-dit-infra -r postgres -o statefulset,pvc,service
END_USAGE

	exit 1
}

processOptions () {
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-n | --namespace)
				PROJECT=$2
				shift 2
			;;
			-r | --resource)
				RESOURCE=$2
				shift 2
			;;
			-o | --objects)
				OBJECT=$2
				shift 2
			;;
			-h | --help)
				usage
				exit 0
			;;
			*)
			usage
			;;
		esac
	done
}

verifyConnection () {
	echo "checking kubernetes connection..."
	oc version > /dev/null || errorExit "Connection to cluster failed"
	echo "connection succeded"
}

deleteStatefulsets () {
	stateful_sets=($(oc get statefulsets -n ${PROJECT} --no-headers=true | grep ${RESOURCE} | awk '{print $1}'))
	for i in ${stateful_sets[@]}
	do
		echo "deleting statefulset for :" $i
		out=($(oc delete statefulset $i))
		echo ${out} " for " ${RESOURCE} " is deleted succesfully"
		stateful_sets_pods=($(oc get pods -n ${PROJECT} --no-headers=true | grep ${RESOURCE} | awk '{print $1 $3}' | grep 'Terminating'))
		echo ${stateful_sets_pods}
		while [ -z "$stateful_sets_pods" ]
		do
			echo ${RESOURCE} " still deleting.."
		done
		echo ${RESOURCE} " pod deleted"
	done
}

deletePVC () {
	objtodelete=$1
	pvcs=($(oc get pvc -n ${PROJECT} --no-headers=true | grep ${RESOURCE} | awk '{print $1}'))
	for i in ${pvcs[@]}
	do
		echo "deleting pvc for :" $i
		out=($(oc delete pvc $i))
		echo ${out} " for " ${RESOURCE} " is deleted succesfully"
	done
}

deleteServices () {
	objtodelete=$1
	services=($(oc get services -n ${PROJECT} --no-headers=true | grep ${RESOURCE} | awk '{print $1}'))
	for i in ${services[@]}
	do
		echo "deleting service for :" $i
		out=($(oc delete service $i))
		echo ${out} " for " ${RESOURCE} " is deleted succesfully"
	done
}

deleteDeployments () {
	objtodelete=$1
	deployments=($(oc get deployments -n ${PROJECT} --no-headers=true | grep ${RESOURCE} | awk '{print $1}'))
	for i in ${deployments[@]}
	do
		echo "deleting deployment for :" $i
		out=($(oc delete deployment $i))
		echo ${out} " for " ${RESOURCE} " is deleted succesfully"
	done
}

deleteSecrets () {
	objtodelete=$1
	secrets=($(oc get secrets -n ${PROJECT} --no-headers=true | grep ${RESOURCE} | awk '{print $1}'))
	for i in ${secrets[@]}
	do
		echo "deleting secret for :" $i
		out=($(oc delete secret $i))
		echo ${out} " for " ${RESOURCE} " is deleted succesfully"
	done
}

deleteObjects(){
	objects=($(echo "${OBJECT}" | tr ',' '\n'))
	if [ ! -z "$objects" ]
	then
		for object in ${objects[@]}
		do
			case $object in
					'statefulset')
						deleteStatefulsets
						;;
					'pvc')
						deletePVC
						;;
					'service')
						deleteServices
						;;
					'deployment')
						deleteDeployments
						;;
					'secret')
						deleteSecrets
						;;
					*)
						echo "Object is not valid|Valid values :"${VALID_OBJECTS}
			esac
		done
	fi
}

main () {
	processOptions "$@"
	verifyConnection
	deleteObjects
}

######### Main #########

main "$@"
