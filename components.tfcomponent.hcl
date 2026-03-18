component "network" {
  source = "./modules/network"
  providers = {
    aws = provider.aws.main
  }
  inputs = {
    name     = var.cluster_name
    vpc_cidr = var.vpc_cidr
  }
}

component "cluster" {
  source = "./modules/cluster"
  providers = {
    aws    = provider.aws.main
    random = provider.random.main
    # Map the new providers here
    time      = provider.time.main
    tls       = provider.tls.main
    cloudinit = provider.cloudinit.main
    null      = provider.null.main
  }
  inputs = {
    cluster_name        = var.cluster_name
    kubernetes_version  = var.kubernetes_version
    vpc_id              = component.network.vpc_id
    subnet_ids          = component.network.public_subnet_ids
  }
}

component "auth" {
  source = "./modules/app_auth"
  providers = {
    aws = provider.aws.main
  }
  inputs = {
    cluster_name = component.cluster.cluster_name
  }
}

component "app" {
  source = "./modules/app"
  providers = {
    kubernetes = provider.kubernetes.main
  }
}
