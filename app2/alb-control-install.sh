# bin/bash
# 1. Uninstall existing Helm release (clean start)
helm uninstall aws-load-balancer-controller -n kube-system

# 2. Download correct IAM policy (Commercial AWS, not GovCloud)
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.0/docs/install/iam_policy.json

# 3. Create IAM policy (skip if already exists)
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam-policy.json

# 4. Create IAM ServiceAccount with IRSA
eksctl create iamserviceaccount \
  --cluster=expense \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::946156973594:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# 5. Reinstall ALB controller with Helm
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=expense \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# 6. Verify pods are running
kubectl get pods -n kube-system | grep aws-load-balancer
