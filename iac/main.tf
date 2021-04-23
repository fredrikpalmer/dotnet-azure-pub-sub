locals {
  location = "northeurope"
}

resource "azurerm_resource_group" "resource_group" {
  name = "az-pubsub-rg"
  location = local.location 
}

resource "azurerm_storage_account" "function_sa" {
  name = "fpfunctionsappsa"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_servicebus_namespace" "namespace" {
  name = "az-pubsub-namespace"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = local.location
  sku = "Standard"
}

resource "azurerm_servicebus_topic" "topic" {
  name = "az-pubsub-topic"
  namespace_name = azurerm_servicebus_namespace.namespace.name
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_servicebus_subscription" "subscription_1" {
  name = "az-pubsub-subscription-1"
  namespace_name = azurerm_servicebus_namespace.namespace.name
  resource_group_name = azurerm_resource_group.resource_group.name
  topic_name = azurerm_servicebus_topic.topic.name
  max_delivery_count = 10
  dead_lettering_on_message_expiration = true
}

resource "azurerm_servicebus_subscription" "subscription_2" {
  name = "az-pubsub-subscription-2"
  namespace_name = azurerm_servicebus_namespace.namespace.name
  resource_group_name = azurerm_resource_group.resource_group.name
  topic_name = azurerm_servicebus_topic.topic.name
  max_delivery_count = 10
  dead_lettering_on_message_expiration = true
}

resource "azurerm_app_service_plan" "plan" {
  name = "az-pubsub-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = local.location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_application_insights" "application_insights" {
  name = "az-pubsub-ai"
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type = "other"
  location = local.location
}

resource "azurerm_function_app" "func" {
  name = "az-pubsub-functions"
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.plan.id
  storage_account_name = azurerm_storage_account.function_sa.name
  storage_account_access_key = azurerm_storage_account.function_sa.primary_access_key
  location = local.location
  version = "~3"

  app_settings = {
    "CONNECTION_STRING" = azurerm_servicebus_namespace.namespace.default_primary_connection_string
    "FUNCTIONS_EXTENSION_VERSION" = "~3"
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_application_insights.application_insights
  ]
}

resource "azurerm_role_assignment" "publisher-ra" {
  principal_id = azurerm_function_app.func.identity[0].principal_id
  scope = "/subscriptions/${var.sub}"
  role_definition_name = "Azure Service Bus Data Sender"
}

resource "azurerm_role_assignment" "subscriber-ra" {
  principal_id = azurerm_function_app.func.identity[0].principal_id
  scope = "/subscriptions/${var.sub}"
  role_definition_name = "Azure Service Bus Data Receiver"
}