provider "azurerm" {
  version = "~>2.30.0"
  features {}
}
variable "cont" {
    type    = list
    default = ["srcdir", "trgtdir", "files"]
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "adfstoracc71"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_container" "example" {
  count                = length(var.cont)
  name                 = "${element(var.cont, count.index)}"
  #name                 = "terraform-state-${element(var.component, count.index)}"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_data_factory" "example" {
  name                = "adftest71"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
resource "azurerm_sql_server" "example" {
    name                         = "mysqlsvr711"
    resource_group_name          = azurerm_resource_group.example.name
    location                     = azurerm_resource_group.example.location
    version                      = "12.0"
    administrator_login          = "srvadmin"
    administrator_login_password = "P@ss1234"
}
#Firewall creation
resource "azurerm_sql_firewall_rule" "example" {
  name                = "alllowazureServices"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.example.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
#DB creation
resource "azurerm_sql_database" "example" {
  name                             = "mysqldatabase"
  resource_group_name              = azurerm_resource_group.example.name
  location                         = azurerm_resource_group.example.location
  server_name                      = azurerm_sql_server.example.name
  edition                          = "Standard"
  requested_service_objective_name = "S1"
}
