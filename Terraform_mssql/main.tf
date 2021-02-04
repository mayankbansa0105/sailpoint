provider "azurerm" {

  subscription_id = "9d292e04-173b-408e-a41d-df684632fb07"
  client_id       = "70e80a00-c4eb-43c6-af0e-36ecc8cef976"
  client_secret   = "3hHDPF.4hNwp.1dksEUltBiuPHzd.7wg3N"
  tenant_id       = "af8cff11-c4c0-4515-8402-00bc2faad6ba"



  features {}

}

resource "azurerm_resource_group" "sp" {
  name     = "sailpoint"
  location = "southeastasia"

}

resource "azurerm_public_ip" "sp" {

  location            = azurerm_resource_group.sp.location
  name                = "sailpointdb-publicip"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.sp.name

}


resource "azurerm_virtual_network" "sp" {

  name                = "SailpointNetwork1"
  location            = azurerm_resource_group.sp.location
  resource_group_name = azurerm_resource_group.sp.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sp" {

  name                 = "sailpointsubnet"
  resource_group_name  = azurerm_resource_group.sp.name
  virtual_network_name = azurerm_virtual_network.sp.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "sp" {

  name                = "sailpoint-vnic"
  location            = azurerm_resource_group.sp.location
  resource_group_name = azurerm_resource_group.sp.name

  ip_configuration {

    name                          = "sailpoint"
    subnet_id                     = azurerm_subnet.sp.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sp.id

  }
}

resource "azurerm_network_security_group" "sp" {

  name                = "sailpoint-ng"
  location            = azurerm_resource_group.sp.location
  resource_group_name = azurerm_resource_group.sp.name
  security_rule {
    name                       = "sailpointrule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = [22,1433]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.sp.id
  network_security_group_id = azurerm_network_security_group.sp.id
}



resource "azurerm_virtual_machine" "sp" {
  name                  = "sailpoint-vm"
  location              = azurerm_resource_group.sp.location
  resource_group_name   = azurerm_resource_group.sp.name
  network_interface_ids = [azurerm_network_interface.sp.id]
  vm_size               = "Standard_DS2_v2"
  os_profile_linux_config {
    disable_password_authentication = false
  }

  os_profile {
    computer_name  = "web-vm"
    admin_username = "mayank"
    admin_password = "5Vnzur_276332"
  }

  storage_os_disk {
    name              = "mydisk1"
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

output "public_ip" {

  value = azurerm_public_ip.sp.ip_address
}

resource "azurerm_virtual_machine_extension" "sp" {
  name                 = "mssql-installer"
  virtual_machine_id   = azurerm_virtual_machine.sp.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings             = <<SETTINGS
    {
        "fileUris" : ["https://customscript1.blob.core.windows.net/script/sql.sh"],
        "commandToExecute" : "sh sql.sh"
    }
SETTINGS
 

}


