#!/usr/bin/env bats

@test "evaluate metrics-server status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'metrics-server'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate kube-state-metrics status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'kube-state-metrics'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate cluster-autoscaler status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'cluster-autoscaler'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate cloudwatch-agent status" {
  run bash -c "kubectl get po -n amazon-cloudwatch -o wide | grep 'cloudwatch-agent'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate fluentd status" {
  run bash -c "kubectl get po -n amazon-cloudwatch -o wide | grep 'fluentd'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate standard namespaces" {
  run bash -c "kubectl get ns"
  [[ "${output}" =~ "lab-system" ]]
}
