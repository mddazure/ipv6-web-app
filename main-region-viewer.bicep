param rgName string = 'ipv6-web-app-rg'
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

// demo application container image
param containerImage string = 'madedroo/azure-region-viewer:hostnet'

//port backend vm's listen on
param backendPort int = 80

//port exposed by the container
param containerPort int = 3000


// VM deployment parameters for SSH access
param adminUsername string = 'AzureAdmin'
param adminPassword string = 'ip-v6-demo-2025'

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
module nsgr1 'br/public:avm/res/network/network-security-group:0.5.2' = {
  name: 'nsgr1Deployment'
  scope: rg
  params: {
    name: 'nsgr1'
    location: location1
    securityRules: [
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
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
      vnetr1spokeIPv6Range1
      ]
    
    subnets: [
      {
      name: vnetr1spokeSubnet0Name
      addressPrefixes: [
          vnetr1spokeSubnet0IPv4Range
          vnetr1spokeSubnet0IPv6Range
          ]
      networkSecurityGroupResourceId: nsgr1.outputs.resourceId
      }
      {
        name: vnetr1spokeSubnet1Name

          addressPrefixes: [
            vnetr1spokeSubnet1IPv4Range
            vnetr1spokeSubnet1IPv6Range
          ]
        networkSecurityGroupResourceId: nsgr1.outputs.resourceId
        }    
    {
        name: vnetr1spokeSubnet2Name
        addressPrefixes: [
            vnetr1spokeSubnet2IPv4Range
            vnetr1spokeSubnet2IPv6Range
          ]
        networkSecurityGroupResourceId: nsgr1.outputs.resourceId  
        }

    ]
    peerings: [
      {
        name: 'spoke-to-hub'
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'hub-to-spoke'
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
/*module azfwr1 'br/public:avm/res/network/azure-firewall:0.8.0' = {
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
}*/
module appgwr1PublicIPv6 'modules/pubipaddress.bicep' = {
  name: 'appgwr1PublicIPv6'
  scope: rg
  params: {
    name: 'appgwr1PublicIPv6'
    location: location1
    skuName: 'Standard'
    allocationMethod: 'Static'
    version: 'IPv6'
    dnsNameLabel: 'ipv6webapp-${location1}'
  }
}
module appgwr1PublicIPv4 'modules/pubipaddress.bicep' = {
  name: 'appgwr1PublicIPv4'
  scope: rg
  params: {
    name: 'appgwr1PublicIPv4'
    location: location1
    skuName: 'Standard'
    allocationMethod: 'Static'
    version: 'IPv4'
    dnsNameLabel: 'ipv4webapp-${location1}'
  }
}
module elbr1PublicIPv6 'modules/pubipaddress.bicep' = {
  name: 'elbr1PublicIPv6'
  scope: rg
  params: {
    name: 'elbr1PublicIPv6'
    location: location1
    skuName: 'Standard'
    allocationMethod: 'Static'
    version: 'IPv6'
    dnsNameLabel: 'ipv6webapp-elb-${location1}'
  }
}

module elbr1PublicIPv4 'modules/pubipaddress.bicep' = {
  name: 'elbr1PublicIPv4'
  scope: rg
  params: {
    name: 'elbr1PublicIPv4'
    location: location1
    skuName: 'Standard'
    allocationMethod: 'Static'
    version: 'IPv4'
    dnsNameLabel: 'ipv4webapp-elb-${location1}'
  }
}

module applicationGateway1 'br/public:avm/res/network/application-gateway:0.7.0' = {
  name: 'appgwr1Deployment'
  scope: rg
  params: {
    name: 'appgwr1'
    sku: 'Standard_v2'
    capacity: 1
    backendAddressPools: [
      {
        name: 'backendAddressPool1'
        properties: {
          backendAddresses: [
            {
              fqdn: ''
              ipAddress: (vmr1.outputs != null && vmr1.outputs.nicConfigurations != null && length(vmr1.outputs.nicConfigurations) > 0 && vmr1.outputs.nicConfigurations[0].ipConfigurations != null && length(vmr1.outputs.nicConfigurations[0].ipConfigurations) > 0) ? vmr1.outputs.nicConfigurations[0].ipConfigurations[0].privateIP : ''
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
          port: backendPort
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
          priority: 101
          ruleType: 'Basic'
        }
      }
    ]
  }
}
module elbr1 'br/public:avm/res/network/load-balancer:0.6.0' = {
  name: 'elbr1Deployment'
  scope: rg
  params: {
    name: 'elbr1'
    location: location1
    frontendIPConfigurations: [
      {
        name: 'frontendIPv4'
        publicIPAddressResourceId: elbr1PublicIPv4.outputs.resourceId
      }
      {
        name: 'frontendIPv6'
        publicIPAddressResourceId: elbr1PublicIPv6.outputs.resourceId
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPoolIPv4'
      }
      {
        name: 'backendPoolIPv6'
      }
    ]
    loadBalancingRules: [
      {
        name: 'httpRulev4'
        frontendIPConfigurationName: 'frontendIPv4'
        frontendPort: 80
        backendPort: backendPort
        protocol: 'Tcp'
        backendAddressPoolName: 'backendPoolIPv4'
        probeName: 'httpProbe'
      }
      {
        name: 'httpRulev6'
        frontendIPConfigurationName: 'frontendIPv6'
        frontendPort: 80
        backendPort: backendPort
        protocol: 'Tcp'
        backendAddressPoolName: 'backendPoolIPv6'
        probeName: 'httpProbe'
      }
    ]
    probes: [
      {
        name: 'httpProbe'
        protocol: 'Http'
        port: backendPort
        requestPath: '/'
        intervalInSeconds: 15
        numberOfProbes: 4
      }
    ]
    outboundRules: [
      {
        name: 'outboundRuleIPv4'
        frontendIPConfigurationName: 'frontendIPv4'
        backendAddressPoolName: 'backendPoolIPv4'
        protocol: 'All'
        allocatedOutboundPorts: 1024
        enableTcpReset: true
        idleTimeoutInMinutes: 4
      }
    ]
  }
}
module vmr1 'br/public:avm/res/compute/virtual-machine:0.20.0' = {
  name: 'vmr1'
  scope: rg
  params: {
    name: 'vm-r1'
    location: location1
    adminUsername: adminUsername
    adminPassword: adminPassword
    availabilityZone: -1
    imageReference: {
      offer: '0001-com-ubuntu-server-jammy'
      publisher: 'Canonical'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            privateIPAddressVersion: 'IPv4'
            subnetResourceId: vnetr1spoke.outputs.subnetResourceIds[1]
            privateIPAllocationMethod: 'Dynamic'
            loadBalancerBackendAddressPools: [
              {
                id: '${elbr1.outputs.resourceId}/backendAddressPools/backendPoolIPv4'
              }
            ]
          }
          {
            name: 'ipconfig02'
            privateIPAddressVersion: 'IPv6'
            subnetResourceId: vnetr1spoke.outputs.subnetResourceIds[1]
            privateIPAllocationMethod: 'Dynamic'
            loadBalancerBackendAddressPools: [
              {
                id: '${elbr1.outputs.resourceId}/backendAddressPools/backendPoolIPv6'
              }
            ]
          }

        ]
        nicSuffix: '-nic-01'
        enableAcceleratedNetworking: false
      }
    ]
    
    osDisk: {
      diskSizeGB: 30
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    osType: 'Linux'
    vmSize: 'Standard_B1ms'
    bootDiagnostics: true
    // container image will be started via a VM extension module
  }
}
module vmr1RunContainer 'modules/vm-extension.bicep' = {
  name: 'vmr1RunContainer'
  scope: rg
  params: {
    vmName: 'vm-r1'
    location: location1
    containerImage: containerImage
    containerPort: containerPort
    exposedPort: backendPort
  }
  dependsOn: [
    vmr1
  ]

}



// --- Deployment in location2 ---
module nsgr2 'br/public:avm/res/network/network-security-group:0.5.2' = {
  name: 'nsgr2Deployment'
  scope: rg
  params: {
    name: 'nsgr2'
    location: location2
    securityRules: [
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}
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
          vnetr2hubSubnet1IPv6Range
        ]
      }    
      {
        name: vnetr2hubSubnet2Name
        addressPrefixes: [
          vnetr2hubSubnet2IPv4Range
          vnetr2hubSubnet2IPv6Range
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
      vnetr2spokeIPv6Range1
    ]
    
    subnets: [
      {
        name: vnetr2spokeSubnet0Name
        addressPrefixes: [
          vnetr2spokeSubnet0IPv4Range 
          vnetr2spokeSubnet0IPv6Range
        ]
        networkSecurityGroupResourceId: nsgr2.outputs.resourceId
      }
      {
        name: vnetr2spokeSubnet1Name
        addressPrefixes: [
          vnetr2spokeSubnet1IPv4Range
          vnetr2spokeSubnet1IPv6Range
        ]
        networkSecurityGroupResourceId: nsgr2.outputs.resourceId
      }    
      {
        name: vnetr2spokeSubnet2Name
        addressPrefixes: [
          vnetr2spokeSubnet2IPv4Range
          vnetr2spokeSubnet2IPv6Range
        ]
        networkSecurityGroupResourceId: nsgr2.outputs.resourceId  
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
/*
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
}*/
module appgwr2PublicIPv4 'modules/pubipaddress.bicep' = {
  name: 'appgwr2PublicIPv4'
  scope: rg
  params: {
    name: 'appgwr2PublicIPv4'
    location: location2
    skuName: 'Standard'
    allocationMethod: 'Static'
    version: 'IPv4'
    dnsNameLabel: 'ipv4webappr2-${location2}'
  }
}
module appgwr2PublicIPv6 'modules/pubipaddress.bicep' = {
  name: 'appgwr2PublicIPv6'
  scope: rg
  params: {
    name: 'appgwr2PublicIPv6'
    location: location2
    skuName: 'Standard'
    allocationMethod: 'Static'
    version: 'IPv6'
    dnsNameLabel: 'ipv6webappr2-${location2}'
  }
}
module elbr2PublicIPv6 'modules/pubipaddress.bicep' = {
  name: 'elbr2PublicIPv6'
  scope: rg
  params: {
    name: 'elbr2PublicIPv6'
    location: location2
    skuName: 'Standard'
    allocationMethod: 'Static'
    version: 'IPv6'
    dnsNameLabel: 'ipv6webapp-elb-${location2}'
  }
}

module elbr2PublicIPv4 'modules/pubipaddress.bicep' = {
  name: 'elbr2PublicIPv4'
  scope: rg
  params: {
    name: 'elbr2PublicIPv4'
    location: location2
    skuName: 'Standard'
    allocationMethod: 'Static'
    version: 'IPv4'
    dnsNameLabel: 'ipv4webapp-elb-${location2}'
  }
}

module elbr2 'br/public:avm/res/network/load-balancer:0.6.0' = {
  name: 'elbr2Deployment'
  scope: rg
  params: {
    name: 'elbr2'
    location: location2
    frontendIPConfigurations: [
      {
        name: 'frontendIPv4'
        publicIPAddressResourceId: elbr2PublicIPv4.outputs.resourceId
      }
      {
        name: 'frontendIPv6'
        publicIPAddressResourceId: elbr2PublicIPv6.outputs.resourceId
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPoolIPv4'
      }
      {
        name: 'backendPoolIPv6'
      }
    ]
    loadBalancingRules: [
      {
        name: 'httpRulev4'
        frontendIPConfigurationName: 'frontendIPv4'
        frontendPort: 80
        backendPort: backendPort
        protocol: 'Tcp'
        backendAddressPoolName: 'backendPoolIPv4'
        probeName: 'httpProbe'
      }
      {
        name: 'httpRulev6'
        frontendIPConfigurationName: 'frontendIPv6'
        frontendPort: 80
        backendPort: backendPort
        protocol: 'Tcp'
        backendAddressPoolName: 'backendPoolIPv6'
        probeName: 'httpProbe'
      }
    ]
    probes: [
      {
        name: 'httpProbe'
        protocol: 'Http'
        port: backendPort
        requestPath: '/'
        intervalInSeconds: 15
        numberOfProbes: 4
      }
    ]
    outboundRules: [
      {
        name: 'outboundRuleIPv4'
        frontendIPConfigurationName: 'frontendIPv4'
        backendAddressPoolName: 'backendPoolIPv4'
        protocol: 'All'
        allocatedOutboundPorts: 1024
        enableTcpReset: true
        idleTimeoutInMinutes: 4
      }
    ]
  }
}



module applicationGateway2 'br/public:avm/res/network/application-gateway:0.7.0' = {
  name: 'appgwr2Deployment'
  scope: rg
  params: {
    name: 'appgwr2'
    sku: 'Standard_v2'
    capacity: 1
    backendAddressPools: [
      {
        name: 'backendAddressPool1'
        properties: {
          backendAddresses: [
            {
              ipAddress: (vmr2.outputs != null && vmr2.outputs.nicConfigurations != null && length(vmr2.outputs.nicConfigurations) > 0 && vmr2.outputs.nicConfigurations[0].ipConfigurations != null && length(vmr2.outputs.nicConfigurations[0].ipConfigurations) > 0) ? vmr2.outputs.nicConfigurations[0].ipConfigurations[0].privateIP : ''
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
          port: backendPort
          protocol: 'Http'
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfigv6'
        properties: {
          publicIPAddress: {
            id: (appgwr2PublicIPv6.outputs != null ? appgwr2PublicIPv6.outputs.resourceId : '')
          }
        }
      }
      {
        name: 'frontendIPConfigv4'
        properties: {
          publicIPAddress: {
            id: (appgwr2PublicIPv4.outputs != null ? appgwr2PublicIPv4.outputs.resourceId : '')
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
            id: (vnetr2hub.outputs != null && vnetr2hub.outputs.subnetResourceIds != null && length(vnetr2hub.outputs.subnetResourceIds) > 0 ? vnetr2hub.outputs.subnetResourceIds[0] : '')
          }
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener1'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appgwr2', 'frontendIPConfigv6')
          }
          frontendPort: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendPorts', 'appgwr2', 'frontendPort1')
          }
          protocol: 'Http'
        }
      }
      {
        name: 'httpListener2'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendIPConfigurations', 'appgwr2', 'frontendIPConfigv4')
          }
          frontendPort: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/frontendPorts', 'appgwr2', 'frontendPort1')
          }
          protocol: 'Http'  
        }
      }
    ]
    location: location2
    requestRoutingRules: [
      {
        name: 'requestRoutingRule1'
        properties: {
          backendAddressPool: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendAddressPools',  'appgwr2', 'backendAddressPool1')
          }
          backendHttpSettings: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'appgwr2', 'backendHttpSettings1')
          }
          httpListener: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/httpListeners', 'appgwr2', 'httpListener1')
          }
          priority: 100
          ruleType: 'Basic'
        }
      }
      {
        name: 'requestRoutingRule2'
        properties: {
          backendAddressPool: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendAddressPools',  'appgwr2', 'backendAddressPool1')
          }
          backendHttpSettings: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'appgwr2', 'backendHttpSettings1')
          }
          httpListener: {
            id: resourceId(subscriptionId, rgName, 'Microsoft.Network/applicationGateways/httpListeners', 'appgwr2', 'httpListener2')
          }
          priority: 101
          ruleType: 'Basic'
        }
      }
    ]
  }
}

module vmr2 'br/public:avm/res/compute/virtual-machine:0.20.0' = {
  name: 'vmr2'
  scope: rg
  params: {
    name: 'vm-r2'
    location: location2
    adminUsername: adminUsername
    adminPassword: adminPassword
    availabilityZone: -1
    imageReference: {
      offer: '0001-com-ubuntu-server-jammy'
      publisher: 'Canonical'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
       nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            privateIPAddressVersion: 'IPv4'
            subnetResourceId: vnetr2spoke.outputs.subnetResourceIds[1]
            privateIPAllocationMethod: 'Dynamic'
            loadBalancerBackendAddressPools: [
              {
                id: '${elbr2.outputs.resourceId}/backendAddressPools/backendPoolIPv4'
              }
            ]
          }
          {
            name: 'ipconfig02'
            privateIPAddressVersion: 'IPv6'
            subnetResourceId: vnetr2spoke.outputs.subnetResourceIds[1]
            privateIPAllocationMethod: 'Dynamic'
            loadBalancerBackendAddressPools: [
              {
                id: '${elbr2.outputs.resourceId}/backendAddressPools/backendPoolIPv6'
              }
            ]
          }

        ]
        nicSuffix: '-nic-01'
        enableAcceleratedNetworking: false
      }
    ]
    osDisk: {
      diskSizeGB: 30
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    osType: 'Linux'
    vmSize: 'Standard_B1ms'
    bootDiagnostics: true
    // container image will be started via a VM extension module
  }
}



module vmr2RunContainer 'modules/vm-extension.bicep' = {
  name: 'vmr2RunContainer'
  scope: rg
  params: {
    vmName: 'vm-r2'
    location: location2
    containerImage: containerImage
    containerPort: containerPort
    exposedPort: backendPort
  }
  dependsOn: [
    vmr2
  ]
}

// --- Traffic Manager to distribute traffic between the two regions ---
module trafficmgr 'modules/trafficmanager.bicep' = {
  name: 'trafficmgrDeployment'
  scope: rg
  params: {
    loc1: location1
    loc2: location2
    appgwr1PIPfqdn: appgwr1PublicIPv6.outputs.fqdn
    appgwr2PIPfqdn: appgwr2PublicIPv6.outputs.fqdn
  }
}





