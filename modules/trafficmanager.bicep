param loc1 string 
param loc2 string
param appgwr1PIPfqdn string
param appgwr2PIPfqdn string



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
          target: appgwr1PIPfqdn
          endpointStatus: 'Enabled'
          endpointLocation: loc1
        }
      }
      {
        name: 'appgwr2-endpoint'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          target: appgwr2PIPfqdn
          endpointStatus: 'Enabled'
          endpointLocation: loc2
        }
      }
    ]
  }
}
