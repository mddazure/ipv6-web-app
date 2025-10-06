param loc1 string = 'swedencentral'
param loc2 string = 'uksouth'
param appgwr1PIPv4 string
param appgwr2PIPv4 string



resource trafficManager 'Microsoft.Network/trafficManagerProfiles@2024-04-01-preview' = {
  name: 'ipv6WebApp-TrafficManager'
  location: 'global'
  
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Performance'
    dnsConfig: {
      relativeName: 'dedroog'
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
      expectedStatusCodeRanges: [
        {
          min: 200
          max: 202
        }
      ]

    }
    endpoints: [
      // Example endpoint, replace with your actual public IP or FQDN
      {
        name: 'appgwr1-endpoint'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          target: appgwr1PIPv4
          endpointStatus: 'Enabled'
          endpointLocation: loc1
        }
      }
      {
        name: 'appgwr2-endpoint'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          target: appgwr2PIPv4
          endpointStatus: 'Enabled'
          endpointLocation: loc2
        }
      }
    ]
  }
}
