terraform {
  required_version = "1.14.9"

  cloud {
    organization = "terransible-kj"
    workspaces {
      name = "terransible"
    }
  }
}
