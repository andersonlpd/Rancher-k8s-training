module "create-vpc" {
  source            = "./modules/gcp-network"
  vpc-name          = "vpc-lab-1"
  autocreate-subnet = false
  subnet-name       = "vpc-lab-1-nw-us-central1"
  ip_subnet         = "192.168.10.0/24"
  subnet_region     = "us-central1"
  dns_name          = "dorigas"
}

module "create-instance" {
  source            = "./modules/gcp-rancher-instance"
  name              = "vm-rancher"
  type              = "e2-medium"
  zone              = "us-central1-a"
  image             = "ubuntu-os-cloud/ubuntu-1804-lts"
  network-interface = module.create-vpc.subnet_self_link
  dns-prefix-name   = "rancher"
  domain-name       = module.create-vpc.output_dns_name
  managedzone-name  = module.create-vpc.output_managed_zone
}

module "create-instance-2" {
  source            = "./modules/gcp-k8s-instance"
  name              = "vm-k8s-1"
  type              = "e2-medium"
  zone              = "us-central1-a"
  image             = "ubuntu-os-cloud/ubuntu-1804-lts"
  network-interface = module.create-vpc.subnet_self_link
}

module "create-instance-3" {
  source            = "./modules/gcp-k8s-instance"
  name              = "vm-k8s-3"
  type              = "e2-medium"
  zone              = "us-central1-a"
  image             = "ubuntu-os-cloud/ubuntu-1804-lts"
  network-interface = module.create-vpc.subnet_self_link
}

module "create-instance-4" {
  source            = "./modules/gcp-k8s-instance"
  name              = "vm-k8s-4"
  type              = "e2-medium"
  zone              = "us-central1-a"
  image             = "ubuntu-os-cloud/ubuntu-1804-lts"
  network-interface = module.create-vpc.subnet_self_link
}

//Wildcard recordset
resource "google_dns_record_set" "wildcard" {
  name = "*.rancher.${module.create-vpc.output_dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = module.create-vpc.output_managed_zone

  rrdatas = [module.create-instance-2.output_nat_ip,
             module.create-instance-3.output_nat_ip,
             module.create-instance-4.output_nat_ip
            ]
}