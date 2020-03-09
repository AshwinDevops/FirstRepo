provider "azurerm" {
  version = "2.0.0"
#  subscription_id = "323ac93c-ff0a-4d80-b2b1-01dfbfe2298f"
##  tenant_id = "2f4a9838-26b7-47ee-be60-ccc1fdec5953"
  skip_provider_registration = "true"
  features {}
}

data "azurerm_resource_group" "DevRG" {
  name = "sharedservices-rg"
}
/*
data "azurerm_virtual_network" "vnet" {
  name = "technium-dc-dev-001-vnet"
  #resource_group_name = data.azurerm_resource_group.DevRG.name
  resource_group_name = "TIPTOP-Dev-rg"
}

output "virtual_network_id" {
  value = data.azurerm_virtual_network.vnet.id
}
*/

data "azurerm_subnet" "subnet1" {
  name                 = "frontend-subnet"
  virtual_network_name = "technium-dc-dev-001-vnet"
  resource_group_name  = data.azurerm_resource_group.DevRG.name
  #virtual_network_name = data.azurerm_virtual_network.vnet.name
}

output "subnet_id" {
  value = data.azurerm_subnet.subnet1.id
}


resource "azurerm_network_interface" "nic" {
  name                = "tiptop-test-nic"
  location            = data.azurerm_resource_group.DevRG.location
  resource_group_name = data.azurerm_resource_group.DevRG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "TestVM" {
  name                = "TipTop-Test"
  resource_group_name = data.azurerm_resource_group.DevRG.name
  location            = data.azurerm_resource_group.DevRG.location
  vm_size                = "Standard_D2_v2"
  network_interface_ids = [ azurerm_network_interface.nic.id ]

  os_profile {
      computer_name  = "TipTop-TestVM"
      admin_username = "azureuser"
      admin_password = "Azureuser@12"
    }

  os_profile_linux_config {
        disable_password_authentication = false
  #      ssh_keys {
   #         path     = "/home/azureuser/.ssh/authorized_keys"
  #         key_data = "ssh-rsa AAAAB3Nz{snip}hwhqT9h"
    #    }
    }

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
