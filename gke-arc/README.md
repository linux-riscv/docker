# GKE/Autopilot setup

1. Setup an autopilot cluster

2. Install the ARC controller
```
helm install arc \
    --namespace "arc-systems" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller
```

3. Install kernel runner set
```
helm install rise-arc-runner-set-kernel \
	--namespace "arc-runners" \
	--create-namespace -f ./rise-kernel-arc.yaml \
	oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set
```

4. Install the kernel configmap
```
kubectl create configmap rise-kernel-worker-cm \
    --from-file=./worker-podspec.yaml \
    --namespace "arc-runners"

```
