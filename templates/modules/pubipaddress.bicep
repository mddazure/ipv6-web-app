@description('The location where the public IP address will be deployed')
param location string

@description('The name of the public IP address resource')
param name string

@description('The IP version for the public IP address')
@allowed(['IPv4', 'IPv6'])
param version string

@description('The DNS name label for the public IP address')
param dnsNameLabel string

@description('The SKU name for the public IP address')
@allowed(['Basic', 'Standard'])
param skuName string = 'Standard'

param tier string = 'Regional'

@description('The allocation method for the public IP address')
@allowed(['Static', 'Dynamic'])
param allocationMethod string = 'Static'

@description('Enable zone redundancy for the public IP address')
param zoneRedundant bool = true

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: name
  location: location
  sku: {
    name: skuName
    tier: tier
  }
  zones: zoneRedundant ? ['1', '2', '3'] : null
  properties: {
    publicIPAllocationMethod: allocationMethod
    publicIPAddressVersion: version
    dnsSettings: {
      domainNameLabel: dnsNameLabel
    }
  }
}

@description('The IP address of the public IP resource')
output ipAddress string = publicIPAddress.properties.ipAddress

@description('The resource ID of the public IP address')
output resourceId string = publicIPAddress.id

@description('The fully qualified domain name of the public IP address')
output fqdn string = publicIPAddress.properties.dnsSettings.fqdn
