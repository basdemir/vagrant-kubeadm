## !!! First do vagrant reload from host machine
## !!! After successful reload do vagrant ssh k8s-01 on host machine. Now you're inside the first vm created by vagrant


## start the master, change --apiserver-advertise-address=X.X.X.X # change X.X.X.X with your IP at eth1
```console
kubeadm config images pull #optional
export ethIp=192.168.104.51
kubeadm init --apiserver-advertise-address=$ethIp --pod-network-cidr=192.168.0.0/16 # change the with your the IP of with the IP your desired NIC

```
### If everything goes good, you'll be promted like below:

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

```
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

#### Apply one of the SDNs stated at https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/ eg: Weave
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

#### Below is just an !!!example!!!, to add k8s-nodes to k8s cluster --- Do this on your other VMs not on this master !!!
#### On host machine login to any node - eg: vagrant ssh k8s-02 type the join command you're promted on the master node
```
  kubeadm join 192.168.104.51:6443 --token XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

```

###  In case you lost the above token, print the join command for clients. do on master, apply output on nodes
```
kubeadm token create --print-join-command
```


###  After A While All the nodes will be seen as ready
```
kubectl get nodes 
```
###  Eg: apply below command and go to your browser and type http://192.168.104.51:31000 and observe kubernetes dashboard
```
kubectl apply -f /vagrant/kube-dashboard.yaml
```
### Apply Helm RBACs

```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

```
### Init Helm
```
helm init --service-account tiller  
```

## Reset Tiller & Delete Helm

```console
helm reset
rm -rf ~/.helm

cat <<EOF | kubectl delete -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

```


#### Vagrant box oluşturma-- sonrasında hosts ve /etc/default/kubeleti editle
```console
vagrant package --base <<preconfigured_vm>> --output mybox.box
vagrant box add --name="boxname" mybox.box
```
