terraform {
    required_version ">= 0.13"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        version = ">= 2.26"

    } 
}
        }
        provider "azurerm" {
            skip_provider_registration = true
            features {
            }
                }

        resource "azurerm_resource_group" "rg-CursoinfraCloudat1" {
  name     = "Aulainfra"
  location = "West Europe"
}

resource "azurerm_virtual_network" "Vnetat1" {
  name                = "Vnet_at1"
  location            = azurerm_resource_group.rg-CursoinfraCloudat1.location
  resource_group_name = azurerm_resource_group.rg-CursoinfraCloudat1.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    Disciplina = "InfraCloud"
  }
}

resource "azurerm_subnet" "Subnet_Infracloudat1" {
  name                 = "Subnet"
  resource_group_name  = aazurerm_resource_group.rg-CursoinfraCloudat1.name
  virtual_network_name = azurerm_virtual_network.Vnetat1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "ip-infracloud" {
  name                = "ip-atividade1"
  resource_group_name = azurerm_resource_group.rg-CursoinfraCloudat1.name
  location            = azurerm_resource_group.rg-CursoinfraCloudat1.location
  allocation_method   = "Static"

  tags = {
    environment = "IP Cloud"
  }
}

resource "azurerm_network_security_group" "infracloudsecurity" {
  name                = "ic-security"
  location            = azurerm_resource_group.rg-CursoinfraCloudat1.location
  resource_group_name = azurerm_resource_group.rg-CursoinfraCloudat1.name

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

   }
  security_rule {
    name                       = "web"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Cloud-Security"
  }
}

resource "azurerm_network_interface" "Nic-infracloudatv1" {
  name                = "nic-infracloud"
  location            = azurerm_resource_group.rg-CursoinfraCloudat1.location
  resource_group_name = azurerm_resource_group.rg-CursoinfraCloudat1.name

  ip_configuration {
    name                          = "ip-infracloud"
    subnet_id                     = azurerm_subnet.Subnet_Infracloudat1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip-infracloud.id
  }
}

resource "azurerm_network_interface_security_group_association" "uniaointerfacesecurity" {
  network_interface_id      = azurerm_network_interface.Nic-infracloudatv1.id
  network_security_group_id = azurerm_network_security_group.infracloudsecurity.id
}

resource "azurerm_virtual_machine" "vm-infracloudatv1" {
  name                  = "vm-indracloud"
  location              = azurerm_resource_group.rg-CursoinfraCloudat1.location
  resource_group_name   = azurerm_resource_group.rg-CursoinfraCloudat1.name
  network_interface_ids = [azurerm_network_interface.Nic-infracloudatv1.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "RedeInterna"
    admin_password = "Mudar@321!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

data "azurerm_public_ip" "Guarda-ip" {
  name = azurerm_public_ip.ip-infracloud.name
  resource_group_name = azurerm_resource_group.rg-CursoinfraCloudat1.name
}

resource "null_resource" "install-apache" {
    connection {
      type = "ssh"
    host = data.azurerm_public_ip.ip-infracloud.ip.adrress
    user = "RedeInterna"
    Passoword = "Mudar@321!"
  }

  provisioner "remote-exec" {
        inline = [
          "sudo apt update",
          "sudo apt install -y apache2",
      
    ]
  }
  depends_on = [
    azurerm_virtual_machine.vm-infracloudatv1
  ]
}

resource "null_resource" "upload-app" {
    connection {
      type = "ssh"
    host = data.azurerm_public_ip.ip-infracloud.ip.adrress
    user = "RedeInterna"
    Passoword = "Mudar@321!"
  }

  provisioner "file" {
        source = "app"
        destination = "/home/"RedeInterna"
     
    ]
  }

  depends_on = [
    azurerm_virtual_machine.vm-infracloudatv1
  ]
}