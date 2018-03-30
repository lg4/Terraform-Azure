provider "azurerm" {
}

# Create Resource Group
resource "azurerm_resource_group" "WordPress" {
	name = "WordPress"
	location = "eastus"
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}

# Create Virtual Network
resource "azurerm_virtual_network" "WordPress_Network" {
	name 				= "WP-vNet"
	address_space 		= ["10.0.0.0/16"]
	location 			= "${azurerm_resource_group.WordPress.location}"
	resource_group_name = "${azurerm_resource_group.WordPress.name}"
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}

# Create Subnet
resource "azure_subnet" "WordPress_Subnet" {
	name 				 = "WP-Public"
	resource_group_name  = "${azurerm_resource_group.WordPress.name}"
	virtual_network_name = "${azurerm_virtual_network.WordPress.name}"
	address_prefix 		 = "10.0.1.0/24"
}

# Create Public IP
resource "azurerm_public_ip" "WordPress_PublicIP" {
	name 						 = "WP-PublicIP"
	location 					 = "${azurerm_resource_group.WordPress.location}"
	resource_group_name 		 = "${azurerm_resource_group.WordPress.name}"
	public_ip_address_allocation = "dynamic"
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}

# Create Network Security Group
resource "azurerm_network_security_group" "WordPress_NSG" {
	name 				= "WP-NSG"
	location 			= "${azurerm_resource_group.WordPress.location}"
	resource_group_name = "${azurerm_resource_group.WordPress.name}"
	
	security_rule {
		name 						= "SSH_Public"
		priority 					= "101"
		direction 					= "Inbound"
		access 						= "Allow"
		protocol 					= "tcp"
		source_port_range 			= "*"
		destination_port_range 		= "22"
		source_address_prefix 		= "*"
		destination_address_prefix  = "*"
	}
	tags {
		environment = "Red Hat WordPress Server"
	}
}

# Create Network Interface
resource "azurerm_network_interface" "WordPress_eth0" {
	name 				= "WP-Eth0"
	location 			= "${azurerm_resource_group.WordPress.location}"
	resource_group_name = "${azurerm_resource_group.WordPress.name}"
	
	ip_configuration {
		name 						 = "Primary"
		subnet_id 					 = "${azurerm_subnet.WordPress.id}"
		public_ip_address_allocation = "dynamic"
	}
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}

# Create Storage Account
resource "azurerm_storage_account" "WordPress_StorageAccount" {
	name 					 = "WP-Storage"
	location 				 = "${azurerm_resource_group.WordPress.location}"
	resource_group_name 	 = "${azurerm_resource_group.WordPress.name}"
	account_replication_type = "LRS"
	account_tier 			 = "Standard"
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}
# Create Virtual Machine
resource "azurerm_virtual_machine" "WordPress_VM" {
	name 				  = "WP-VM"
	location 			  = "${azurerm_resource_group.WordPress.location}"
	resource_group_name   = "${azurerm_resource_group.WordPress.name}"
	network_interface_ids = ["${azurerm_network_interface.WordPress.id}"]
	vm_size 			  = "Standard_DS1_v2"
	
	storage_os_disk {
		name 				= "WP-OSDisk"
		caching 			= "ReadWrite"
		create_option 		= "FromImage"
		managed_disk_type   = "Standard_LRS"
	}
	
	storage_image_reference {
		publisher = "RedHat"
		offer	  = "RHEL"
		sku		  = "7.4"
		version   = "latest"
	}
	
	os_profile {
		computer_name  = "WordPress"
		admin_username = "wpadmin"
	}
	
	os_profile_linux_config {
		disable_password_authentication = true
		ssh_keys {
			path	 = "/home/wpadmin/.ssh/authorized_keys"
			key_data = "ssh-rsa ABC123
		}
	}
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}
