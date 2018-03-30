provider "azurerm" {
}

resource "azurerm_resource_group" "WordPress" {
	name = "WordPress"
	location = "eastus"
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}

resource "azurerm_virtual_network" "WordPress_Network"
	name = "WP-vNet"
	address_space = ["10.0.0.0/16"]
	location = "${azurerm_resource_group.WordPress.location}"
	resource_group_name = "${azurerm_resource_group.WordPress.name}"
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}

resource "azure_subnet" "WordPress_Subnet"
	name = "WP-Public"
	resource_group_name = "${azurerm_resource_group.WordPress.name}"
	virtual_network_name = "${azurerm_virtual_network.WordPress.name}"
	address_prefix = "10.0.1.0/24"
}

resource "azurerm_public_ip" "WordPress_PublicIP" {
	name = "WP-PublicIP"
	location = "${azurerm_resource_group.WordPress.location}"
	resource_group_name = "${azurerm_resource_group.WordPress.name}"
	public_ip_address_allocation = "dynamic"
	
	tags {
		environment = "Red Hat WordPress Server"
	}
}

resource "azurerm_network_security_group" "WordPress_NSG"
	name = "WP-NSG"
	location = "${azurerm_resource_group.WordPress.location}"
	resource_group_name = "${azurerm_resource_group.WordPress.name}"
	;
	security_rule {
		name = "SSH_Public"
		priority = "101"
		direction = "Inbound"
		access = "Allow"
		protocol = "tcp"
		source_port_range = "*"
		destination_port_range = "22"
		source_address_prefix = "*"
		destination_address_prefix = "*"
	}
	tags {
		environment = "Red Hat WordPress Server"
	}
}

resource "azurerm_network_interface" "WordPress_eth0"
	name = "WP-Eth0"
	location = "${azurerm_resource_group.WordPress.location}"
	resource_group_name = "${azurerm_resource_group.WordPress.name}"
	
	ip_configuration {
		name = "Primary"
		subnet_id = "