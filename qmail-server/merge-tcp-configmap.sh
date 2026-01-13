#!/bin/bash
# Script to merge Qmail TCP ports into existing tcp-services ConfigMap

NAMESPACE="${1:-ingress-nginx}"
RELEASE_NAMESPACE="${2:-default}"
RELEASE_NAME="${3:-qmail-server}"

echo "Merging Qmail TCP ports into tcp-services ConfigMap..."
echo "Ingress namespace: $NAMESPACE"
echo "Qmail namespace: $RELEASE_NAMESPACE"
echo "Qmail release name: $RELEASE_NAME"

# Check if tcp-services ConfigMap exists
if kubectl get configmap tcp-services -n "$NAMESPACE" &>/dev/null; then
    echo "Existing tcp-services ConfigMap found. Merging..."
    
    # Get existing ConfigMap
    kubectl get configmap tcp-services -n "$NAMESPACE" -o yaml > /tmp/tcp-services-existing.yaml
    
    # Add Qmail ports
    cat >> /tmp/tcp-services-existing.yaml <<EOF
  "25": "$RELEASE_NAMESPACE/$RELEASE_NAME:25"
  "587": "$RELEASE_NAMESPACE/$RELEASE_NAME:587"
  "110": "$RELEASE_NAMESPACE/$RELEASE_NAME:110"
  "143": "$RELEASE_NAMESPACE/$RELEASE_NAME:143"
  "995": "$RELEASE_NAMESPACE/$RELEASE_NAME:995"
  "993": "$RELEASE_NAMESPACE/$RELEASE_NAME:993"
EOF
    
    # Remove the last line (---) if it exists and add data section properly
    # This is a simplified version - you may need to manually edit the YAML
    
    echo ""
    echo "⚠️  Manual step required:"
    echo "1. Edit /tmp/tcp-services-existing.yaml"
    echo "2. Add the Qmail ports to the 'data:' section:"
    echo "   \"25\": \"$RELEASE_NAMESPACE/$RELEASE_NAME:25\""
    echo "   \"587\": \"$RELEASE_NAMESPACE/$RELEASE_NAME:587\""
    echo "   \"110\": \"$RELEASE_NAMESPACE/$RELEASE_NAME:110\""
    echo "   \"143\": \"$RELEASE_NAMESPACE/$RELEASE_NAME:143\""
    echo "   \"995\": \"$RELEASE_NAMESPACE/$RELEASE_NAME:995\""
    echo "   \"993\": \"$RELEASE_NAMESPACE/$RELEASE_NAME:993\""
    echo "3. Apply: kubectl apply -f /tmp/tcp-services-existing.yaml"
    echo "4. Restart ingress: kubectl rollout restart deployment ingress-nginx-controller -n $NAMESPACE"
else
    echo "No existing tcp-services ConfigMap found. Chart will create it automatically."
fi


