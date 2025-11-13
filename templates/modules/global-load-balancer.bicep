param location string
param publicIpv4id string
param publicIpv6id string
param lbName string
param lbSku string = 'Standard'
param lbTier string = 'Global'
param frontendIpv4Name string = 'LoadBalancer-FrontendIPv4'
param frontendIpv6Name string = 'LoadBalancer-FrontendIPv6'
param elbr1IPv4frontendIPid string
param elbr1IPv6frontendIPid string
param elbr2IPv4frontendIPid string
param elbr2IPv6frontendIPid string

resource globalLoadBalancer 'Microsoft.Network/loadBalancers@2023-11-01' = {
  name: lbName
  location: location
  sku: {
    name: lbSku
    tier: lbTier
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendIpv4Name
        properties: {
          publicIPAddress: {
            id: publicIpv4id
          }
        }
      }
      {
        name: frontendIpv6Name
        properties: {
          publicIPAddress: {
            id: publicIpv6id
          }
        }
      }
    ]
  }
}
