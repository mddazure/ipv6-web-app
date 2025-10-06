param rgName string = 'ipv6-web-app-rg2'
param subscriptionId string = subscription().subscriptionId
param location1 string = 'swedencentral'
param location2 string = 'eastus2'

param vnetr1hubName string = 'vnet-hub-r1'
param vnetr1hubIPv4Range1 string = '10.1.0.0/24'
param vnetr1hubIPv6Range1 string = '2001:0db1::/56'
param vnetr1hubSubnet0Name string = 'ApplicationGatewaySubnet'
param vnetr1hubSubnet0IPv4Range string = '10.1.0.0/26'
param vnetr1hubSubnet0IPv6Range string = '2001:0db1::/64'
param vnetr1hubSubnet1Name string = 'AzureFirewallSubnet'
param vnetr1hubSubnet1IPv4Range string = '10.1.0.64/26'
param vnetr1hubSubnet1IPv6Range string = '2001:0db1:0:1::/64'
param vnetr1hubSubnet2Name string = 'AzureFirewallManagementSubnet'
param vnetr1hubSubnet2IPv4Range string = '10.1.0.128/26'
param vnetr1hubSubnet2IPv6Range string = '2001:0db1:0:2::/64'


param vnetr1spokeName string = 'vnet-spoke-r1'
param vnetr1spokeIPv4Range1 string = '10.1.1.0/24'
param vnetr1spokeIPv6Range1 string = '2001:0db8:1::/56'
param vnetr1spokeSubnet0Name string = 'Subnet0'
param vnetr1spokeSubnet0IPv4Range string = '10.1.1.0/26'
param vnetr1spokeSubnet0IPv6Range string = '2001:0db8:1::/64'
param vnetr1spokeSubnet1Name string = 'Subnet1'
param vnetr1spokeSubnet1IPv4Range string = '10.1.1.64/26'
param vnetr1spokeSubnet1IPv6Range string = '2001:0db8:1:1::/64'
param vnetr1spokeSubnet2Name string = 'Subnet2'
param vnetr1spokeSubnet2IPv4Range string = '10.1.1.128/26'
param vnetr1spokeSubnet2IPv6Range string = '2001:0db8:1:2::/64'


param vnetr2hubName string = 'vnet-hub-r2'
param vnetr2hubIPv4Range1 string = '10.2.1.0/24'
param vnetr2hubIPv6Range1 string = '2001:0db9::/56'
param vnetr2hubSubnet1Name string = 'AzureFirewallSubnet'
param vnetr2hubSubnet1IPv4Range string = '10.2.1.64/26'
param vnetr2hubSubnet1IPv6Range string = '2001:0db9:0:1::/64'
param vnetr2hubSubnet2Name string = 'AzureFirewallManagementSubnet'
param vnetr2hubSubnet2IPv4Range string = '10.2.1.128/26'
param vnetr2hubSubnet2IPv6Range string = '2001:0db9:0:2::/64'
param vnetr2hubSubnet0Name string = 'ApplicationGatewaySubnet'
param vnetr2hubSubnet0IPv4Range string = '10.2.1.0/26'
param vnetr2hubSubnet0IPv6Range string = '2001:0db9::/64'

param vnetr2spokeName string = 'vnet-spoke-r2'
param vnetr2spokeIPv4Range1 string = '10.2.2.0/24'
param vnetr2spokeIPv6Range1 string = '2001:0db9:2::/56'
param vnetr2spokeSubnet0Name string = 'Subnet0'
param vnetr2spokeSubnet0IPv4Range string = '10.2.2.0/26'
param vnetr2spokeSubnet0IPv6Range string = '2001:0db9:2:0::/64'
param vnetr2spokeSubnet1Name string = 'Subnet1'
param vnetr2spokeSubnet1IPv4Range string = '10.2.2.64/26'
param vnetr2spokeSubnet1IPv6Range string = '2001:0db9:2:1::/64'
param vnetr2spokeSubnet2Name string = 'Subnet2'
param vnetr2spokeSubnet2IPv4Range string = '10.2.2.128/26'
param vnetr2spokeSubnet2IPv6Range string = '2001:0db9:2:2::/64'

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location1
}

// --- Deployment in location1 ---
module vnetr1hub 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'vnetr1hubDeployment'
  scope: rg
    params: {
    name: vnetr1hubName
    location: location1

    addressPrefixes: [
      vnetr1hubIPv4Range1
      vnetr1hubIPv6Range1
      ]
    
    subnets: [
      {
      name: vnetr1hubSubnet0Name
      delegation: 'Microsoft.Network/applicationGateways' 
      addressPrefixes: [
          vnetr1hubSubnet0IPv4Range
          vnetr1hubSubnet0IPv6Range
          ]
        }
      {
        name: vnetr1hubSubnet1Name

          addressPrefixes: [
            vnetr1hubSubnet1IPv4Range
            //vnetr1hubSubnet1IPv6Range
          ]
        }    
    {
        name: vnetr1hubSubnet2Name
        addressPrefixes: [
            vnetr1hubSubnet2IPv4Range
            //vnetr1hubSubnet2IPv6Range
          ]
        }

    ]
  }
}
module vnetr1spoke 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'vnetr1spokeDeployment'
  scope: rg
  params: {
    name: vnetr1spokeName
    location: location1
    
      addressPrefixes: [
      vnetr1spokeIPv4Range1
      //vnetr1spokeIPv6Range1
      ]
    
    subnets: [
      {
       name: vnetr1spokeSubnet0Name
       delegation: 'Microsoft.ContainerInstance/containerGroups'
      addressPrefixes: [
          vnetr1spokeSubnet0IPv4Range
          //vnetr1spokeSubnet0IPv6Range
          ]
        }
      {
        name: vnetr1spokeSubnet1Name

          addressPrefixes: [
            vnetr1spokeSubnet1IPv4Range
            //vnetr1spokeSubnet1IPv6Range
          ]
        }    
    {
        name: vnetr1spokeSubnet2Name
        addressPrefixes: [
            vnetr1spokeSubnet2IPv4Range
            //vnetr1spokeSubnet2IPv6Range
          ]
        }

    ]
    peerings: [
      {
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'customName'
        remoteVirtualNetworkResourceId: vnetr1hub.outputs.resourceId
        useRemoteGateways: false
      }
    ]
  }
}

module azfwr1PublicIP 'br/public:avm/res/network/public-ip-address:0.7.0' = {
  name: 'azfwr1PublicIP'
  scope: rg
  params: {
    name: 'azfwr1PublicIP'
    location: location1
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}
module azfwr1 'br/public:avm/res/network/azure-firewall:0.8.0' = {
  name: 'azfwr1'
  scope: rg
  params: {
    name: 'azfwr1'
    location: location1
    azureSkuTier: 'Basic'
    virtualNetworkResourceId: vnetr1hub.outputs.resourceId
    publicIPResourceID: azfwr1PublicIP.outputs.resourceId
    networkRuleCollections: [
      {
        name: 'allow-http'
        properties: {
          priority: 100
          action: {type: 'Allow'}
          rules: [
            {
              name: 'http-rule'
              protocols: [
                'TCP'
              ] 
              sourceAddresses: [
                  '*'
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '80'
              ]
              }
          ]
        }
      }
    ]

  }
}
module appgwr1PublicIPv6 'br/public:avm/res/network/public-ip-address:0.7.0' = {
  name: 'appgwr1PublicIP'
  scope: rg
  params: {
    name: 'appgwr1PublicIPv6'
    location: location1
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv6'
  }
}
module appgwr1PublicIPv4 'br/public:avm/res/network/public-ip-address:0.7.0' = {
  name: 'appgwr1PublicIPv4'
  scope: rg
  params: {
    name: 'appgwr1PublicIPv4'
    location: location1
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}
module applicationGateway1 'br/public:avm/res/network/application-gateway:0.7.0' = {
  name: 'appgwr1Deployment'
  scope: rg
  params: {
    name: 'appgwr1'
    backendAddressPools: [
      {
        name: 'backendAddressPool1'
        properties: {
          backendAddresses: [
            {
              ipAddress: containerinstr1.outputs.iPv4Address
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings1'
        properties: {
          cookieBasedAffinity: 'Disabled'
          port: 80
          protocol: 'Http'
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfigv6'
        properties: {
          publicIPAddress: {
            id: appgwr1PublicIPv6.outputs.resourceId
          }
        }
      }
      {
        name: 'frontendIPConfigv4'
        properties: {
          publicIPAddress: {
            id: appgwr1PublicIPv4.outputs.resourceId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontendPort1'
        properties: {
          port: 80
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'publicIPConfig1'
        properties: {
          subnet: {
            id: vnetr1hub.outputs.subnetResourceIds[0]
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appgwr1', 'frontendIPConfigv6')
          }
          frontendPort: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendPorts', 'appgwr1', 'frontendPort1')
          }
          protocol: 'Http'
        }
      }
      {
        name: 'httpListener2'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appgwr1', 'frontendIPConfigv4')
          }
          frontendPort: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendPorts', 'appgwr1', 'frontendPort1')
          }
          protocol: 'Http'  
        }
      }
    ]
    location: location1
    requestRoutingRules: [
      {
        name: 'requestRoutingRule1'
        properties: {
          backendAddressPool: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendAddressPools',  'appgwr1', 'backendAddressPool1')
          }
          backendHttpSettings: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'appgwr1', 'backendHttpSettings1')
          }
          httpListener: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/httpListeners', 'appgwr1', 'httpListener1')
          }
          priority: 100
          ruleType: 'Basic'
        }
      }
      {
        name: 'requestRoutingRule2'
        properties: {
          backendAddressPool: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendAddressPools',  'appgwr1', 'backendAddressPool1')
          }
          backendHttpSettings: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'appgwr1', 'backendHttpSettings1')
          }
          httpListener: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/httpListeners', 'appgwr1', 'httpListener2')
          }
          priority: 200
          ruleType: 'Basic'
        }
      }
    ]
    sku: 'Standard_v2'
  }
}

module containerinstr1 'br/public:avm/res/container-instance/container-group:0.6.0' = {
  name: 'containerinstr1'
  scope: rg
  params: {
    name: 'containerinstr1'
    location: location1
    availabilityZone: -1
    containers: [
        {
          name: 'yadaweb-r1'
          properties: {
            image: 'erjosito/yadaweb:1.0'
            command: []
            environmentVariables:[
              {
                name: 'BRANDING'
                value: location1
              }
              {
                name: 'BACKGROUND'
                value: '#aaf1f2'
              }
            ]
            resources: {
              requests: {
                cpu: 1
                memoryInGB: '2'
              }
            }
            ports: [
              {
                port: 80
                protocol: 'Tcp'
              }
            ]
          }
        }
      ]
      osType: 'Linux'
      subnets: [
        {
          subnetResourceId: vnetr1spoke.outputs.subnetResourceIds[0]
        }
      ]
      ipAddress: {
        type: 'Private'
        ports: [
          {
            port: 80
            protocol: 'Tcp'
          }
        ]
      }
    }
}

// --- Deployment in location2 ---
module vnetr2hub 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'vnetr2hubDeployment'
  scope: rg
    params: {
    name: vnetr2hubName
    location: location2

    addressPrefixes: [
      vnetr2hubIPv4Range1
      vnetr2hubIPv6Range1
      ]
    
    subnets: [
      {
      name: vnetr2hubSubnet0Name
      delegation: 'Microsoft.Network/applicationGateways'
      addressPrefixes: [
          vnetr2hubSubnet0IPv4Range
          vnetr2hubSubnet0IPv6Range
          ]
        }
      {
        name: vnetr2hubSubnet1Name

          addressPrefixes: [
            vnetr2hubSubnet1IPv4Range
            //vnetr2hubSubnet1IPv6Range
          ]
        }    
    {
        name: vnetr2hubSubnet2Name
        addressPrefixes: [
            vnetr2hubSubnet2IPv4Range
            //vnetr2hubSubnet2IPv6Range
          ]
        }

    ]
  }
}
module vnetr2spoke 'br/public:avm/res/network/virtual-network:0.7.0' = {
  name: 'vnetr2spokeDeployment'
  scope: rg
  params: {
    name: vnetr2spokeName
    location: location2
    
      addressPrefixes: [
        vnetr2spokeIPv4Range1
        //vnetr2spokeIPv6Range1
      ]
    
    subnets: [
      {
      name: vnetr2spokeSubnet0Name
      delegation: 'Microsoft.ContainerInstance/containerGroups'
        addressPrefixes: [
          vnetr2spokeSubnet0IPv4Range
          //vnetr2spokeSubnet0IPv6Range
          ]
        }
      {
        name: vnetr2spokeSubnet1Name

          addressPrefixes: [
            vnetr2spokeSubnet1IPv4Range
            //vnetr2spokeSubnet1IPv6Range
          ]
        }    
    {
        name: vnetr2spokeSubnet2Name
        addressPrefixes: [
            vnetr2spokeSubnet2IPv4Range
            //vnetr2spokeSubnet2IPv6Range
          ]
        }

    ]
    peerings: [
      {
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'customName'
        remoteVirtualNetworkResourceId: vnetr2hub.outputs.resourceId
        useRemoteGateways: false
      }
    ]
  }
}

module appgwr2PublicIPv6 'br/public:avm/res/network/public-ip-address:0.7.0' = {
  name: 'appgwr2PublicIP'
  scope: rg
  params: {
    name: 'appgwr2PublicIPv6'
    location: location2
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv6'
  }
}
module appgwr2PublicIPv4 'br/public:avm/res/network/public-ip-address:0.7.0' = {
  name: 'appgwr2PublicIPv4'
  scope: rg
  params: {
    name: 'appgwr2PublicIPv4'
    location: location2
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}
module applicationGateway2 'br/public:avm/res/network/application-gateway:0.7.0' = {
  name: 'appgwr2Deployment'
  scope: rg
  params: {
    name: 'appgwr2'
    backendAddressPools: [
      {
        name: 'backendAddressPool2'
        properties: {
          backendAddresses: [
            {
              ipAddress: containerinstr2.outputs.iPv4Address
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings2'
        properties: {
          cookieBasedAffinity: 'Disabled'
          port: 80
          protocol: 'Http'
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfigv6'
        properties: {
          publicIPAddress: {
            id: appgwr2PublicIPv6.outputs.resourceId
          }
        }
      }
      {
        name: 'frontendIPConfigv4'
        properties: {
          publicIPAddress: {
            id: appgwr2PublicIPv4.outputs.resourceId
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'frontendPort2'
        properties: {
          port: 80
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'publicIPConfig2'
        properties: {
          subnet: {
            id: vnetr2hub.outputs.subnetResourceIds[0]
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener3'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appgwr2', 'frontendIPConfigv6')
          }
          frontendPort: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendPorts', 'appgwr2', 'frontendPort2')
          }
          protocol: 'Http'
        }
      }
      {
        name: 'httpListener4'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appgwr2', 'frontendIPConfigv4')
          }
          frontendPort: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendPorts', 'appgwr2', 'frontendPort2')
          }
          protocol: 'Http'
        }
      }
    ]
    location: location2
    requestRoutingRules: [
      {
        name: 'requestRoutingRule3'
        properties: {
          backendAddressPool: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendAddressPools',  'appgwr2', 'backendAddressPool2')
          }
          backendHttpSettings: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'appgwr2', 'backendHttpSettings2')
          }
          httpListener: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/httpListeners', 'appgwr2', 'httpListener3')
          }
          priority: 100
          ruleType: 'Basic'
        }
      }
      {
        name: 'requestRoutingRule4'
        properties: {
          backendAddressPool: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendAddressPools',  'appgwr2', 'backendAddressPool2')
          }
          backendHttpSettings: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'appgwr2', 'backendHttpSettings2')
          }
          httpListener: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/httpListeners', 'appgwr2', 'httpListener4')
          }
          priority: 200
          ruleType: 'Basic'
        }
      }
    ]
    sku: 'Standard_v2'
  }
}

module containerinstr2 'br/public:avm/res/container-instance/container-group:0.6.0' = {
  name: 'containerinstr2'
  scope: rg
  params: {
    name: 'containerinstr2'
    location: location2
    availabilityZone: -1
    containers: [
        {
          name: 'yadaweb-r2'
          properties: {
            image: 'erjosito/yadaweb:1.0'
            command: []
            environmentVariables:[
              {
                name: 'BRANDING'
                value: location2
              }
              {
                name: 'BACKGROUND'
                value: '#92cb96'
              }
            ]
            resources: {
              requests: {
                cpu: 1
                memoryInGB: '2'
              }
            }
            ports: [
              {
                port: 80
                protocol: 'Tcp'
              }
            ]
          }
        }
      ]
      osType: 'Linux'
      subnets: [
        {
          subnetResourceId: vnetr2spoke.outputs.subnetResourceIds[0]
        }
      ]
      ipAddress: {
        type: 'Private'
        ports: [
          {
            port: 80
            protocol: 'Tcp'
          }
        ]
      }
    }
}

module azfwr2PublicIP 'br/public:avm/res/network/public-ip-address:0.7.0' = {
  name: 'azfwr2PublicIP'
  scope: rg
  params: {
    name: 'azfwr2PublicIP'
    location: location2
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}
module azfwr2 'br/public:avm/res/network/azure-firewall:0.8.0' = {
  name: 'azfwr2'
  scope: rg
  params: {
    name: 'azfwr2'
    location: location2
    azureSkuTier: 'Basic'
    virtualNetworkResourceId: vnetr2hub.outputs.resourceId
    publicIPResourceID: azfwr2PublicIP.outputs.resourceId
    networkRuleCollections: [
      {
        name: 'allow-http'
        properties: {
          priority: 100
          action: {type: 'Allow'}
          rules: [
            {
              name: 'http-rule'
              protocols: [
                'TCP'
              ] 
              sourceAddresses: [
                  '*'
              ]
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [
                '80'
              ]
              }
          ]
        }
      }
    ]
  }
}



module trafficmanager 'trafficmanager.bicep' = {
  name: 'trafficmanagerDeployment'
  scope: rg
  params: {
    loc1: location1
    loc2: location2
    appgwr1PIPv4: appgwr1PublicIPv4.outputs.ipAddress
    appgwr2PIPv4: appgwr2PublicIPv4.outputs.ipAddress
  }
}




