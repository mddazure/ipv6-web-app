# **Delivering web applications over IPv6**

The unallocated IPv4 address space pool has been exhausted for some time now, meaning there is no new public address space available for allocation from Internet Registries. The internet continues to run on IPv4 through technical measures such as Network Address Translation (NAT) and [Carrier Grade NAT](https://en.wikipedia.org/wiki/Carrier-grade_NAT), and reallocation of address space through [IPv4 address space trading](https://iptrading.com/). 

Despite the depletion of free IPv4 address space, adoption of IPv6 - with its almost infinitely larger address space the definitive solution to the address space depletion problem - has been slow. [Uptake of IPv6 in the European Union](https://op.europa.eu/en/publication-detail/-/publication/4fcbb7eb-b05e-11ef-acb1-01aa75ed71a1) in Q3 of 2024 stood at appr. 36% for clients (end-users) and 23% for (web) servers over all member states - although there are variations between states. Globally, [Google](https://www.google.com/intl/en/ipv6/statistics.html#tab=ipv6-adoption) reports 49% of clients connecting to its services over IPv6 globally, with France leading at 80%. 

IPv6 client access measured by Google:

![image](/images/google-ipv6-client-access.png)

Ultimately IPv6 will be the dominant network protocol on the internet, as the IPv4 life-support mechanisms used by network operators, hosting providers and ISPs will eventually reach the limits of their scalability. Mobile networks are already changing to IPv6-only APNs; reachability of IPv4-only destinations from these mobile network is through 6-4 NAT gateways, which sometimes causes problems.

Meanwhile, countries around the world are requiring IPv6 reachability for public web services. Examples are [the United States](https://www.whitehouse.gov/wp-content/uploads/2020/11/M-21-07.pdf), European Union member states among which [the Netherlands](https://www.forumstandaardisatie.nl/ipv6), [Norway](https://lovdata.no/dokument/SF/forskrift/2013-04-05-959#shareModal), [India](https://dot.gov.in/ipv6-transition-across-stakeholders), Japan.

IPv6 adoption per country measured by Google:

![image](/images/google-ipv6-country-adoption.png)

 Entities needing to comply with these mandates are looking at Azure's networking capabilities for solutions. Azure supports IPv6 for both private and public networking, and capabilities have developed and expanded over time. This article discusses strategies to build and deploy IPv6-enabled public, internet-facing applications that are reachable from IPv6(-only) clients.

---
## Azure Networking IPv6 capabilities 
Azure's private networking capabilities center on Virtual Networks (VNETs) and the components that are deployed within. Azure VNETs are [IPv4/IPv6 dual stack](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/ipv6-overview) capable: a VNET **must** always have IPv4 address space allocated, and **can** have also IPv6 address space. Virtual machines in a dual stack VNET will have both an IPv4 and an IPv6 address from the VNET range, and can be behind IPv6 capable External- and Internal Load Balancers.  VNETs can be connected through VNET peering, which effectively turns the peered VNETs into a single routing domain. It is now possible to peer only the IPv6 address spaces of VNETs, so that the IPv4 space assigned to VNETs can overlap and communication across the peering is over IPv6. The same is true for connectivity to onpremise over ExpressRoute: the Private Peering can be enabled for IPv6 only, so that VNETs in Azure do not have to have unique IPv4 address space assigned, which may be in short supply in an enterprise.

![image](/images/ipv6-private-netw.png)

Not all internal networking components are IPv6 capable yet. Most notable exceptions are VPN Gateway, Azure Firewall and Virtual WAN; IPv6 compatibility is on the roadmap for these services, but target availability dates have not been communicated.

But now let's focus on Azure's externally facing, public, network services. Azure is ready to let customers publish their web applications over IPv6.

 IPv6 capable externally facing network services include:
- [Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview#global-delivery-scale-using-microsofts-network)
- [Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/ipv6-application-gateway-portal)
- [External Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/deploy-ipv4-ipv6-dual-stack-standard-load-balancer?tabs=azurecli)
- [Public IP addresses](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#ip-address-version) and [Public IP address prefixes](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-address-prefix)
- [Azure DNS](https://learn.microsoft.com/en-us/azure/dns/dns-faq#do-azure-dns-name-servers-resolve-over-ipv6--)
- [Azure DDOS Protection](https://learn.microsoft.com/en-us/azure/ddos-protection/ddos-protection-sku-comparison#tiers)
- [Traffic Manager](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-faqs#does-traffic-manager-support-ipv6-endpoints)
- [App Service](https://azure.github.io/AppService/2024/11/08/Announcing-Inbound-IPv6-support.html) (IPv6 support is in public preview)

---
## IPv6 Application Delivery 

**IPv6 Application Delivery** refers to the architectures and services that enable your web application to be accessible via IPv6. The goal is to provide an IPv6 address and connectivity for clients, while often continuing to run your application on IPv4 internally (dual-stack). Azure’s dual-stack capabilities allow an application to be reachable on both IPv4 and IPv6 without completely re-building your network for IPv6.

Key benefits of adopting IPv6 in Azure include:

✅ **Expanded Client Reach:** *IPv4-only websites risk being unreachable to IPv6-only networks.* By enabling IPv6, you expand your reach into growing mobile and IoT markets that use IPv6 by default. Governments and enterprises increasingly mandate IPv6 support for public-facing services.

✅**Address Abundance & No NAT:** IPv6 provides a virtually unlimited address pool, mitigating IPv4 exhaustion concerns. This abundance means each service can have its own public IPv6 address, often removing the need for complex NAT schemes. End-to-end addressing can simplify connectivity and troubleshooting.

✅**Dual-Stack Compatibility:** Azure supports dual-stack deployments where services listen on both IPv4 and IPv6. This allows a single application instance or endpoint to serve both types of clients seamlessly. Dual-stack ensures you don’t lose any existing IPv4 users while adding IPv6 capability.

✅**Performance and Future Services:** Some networks and clients might experience better performance over IPv6 (due to less NAT). Also, being IPv6-ready prepares your architecture for future Azure features and services as IPv6 integration deepens across the platform.

**General Steps to Enable IPv6 Connectivity** for a web application in Azure are:
1. **Plan and Enable IPv6 Addressing in Azure**: Define an IPv6 address space in your Azure Virtual Network. Azure allows adding IPv6 address space to existing VNETs, making them dual-stack. A `/56` segment for the VNet is recommended, `/64` for subnets is required (Azure *requires* `/64` subnets). If you have existing infrastructure, you might need to create new subnets or migrate resources, especially since older [Application Gateway v1 instances cannot simply be “upgraded” to dual-stack](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-faq#does-application-gateway-support-ipv6).
2. **Deploy or Update Frontend Services with IPv6**: Choose a suitable Azure service (Application Gateway, External / Global Load Balancer, etc.) and configure it with a public IPv6 address on the frontend. This usually means selecting *Dual Stack* configuration so the service gets both an IPv4 and IPv6 public IP. For instance, when creating an Application Gateway v2, you would specify [IP address type: DualStack (IPv4 & IPv6)](https://learn.microsoft.com/en-us/azure/application-gateway/ipv6-application-gateway-portal). Azure Front Door [by default](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview) provides dual-stack capabilities with its global endpoints.
5. **Configure Backends and Routing**: Usually your backend servers or services will remain on IPv4. At the time of writing this in October 2025, neither Azure Application Gateway nor Azure Front Door not support IPv6 for backend pool addresses. This is fine because the frontend terminates the IPv6 network connection from the client, and the backend initiates an IPv4 connection to the backend pool or origin. Ensure that your load balancing rules, listener configurations, and health probes are all set up to route traffic to these backends. Both IPv4 and IPv6 frontend listeners can share the same backend pool.
6. **Update DNS Records**: Publish a DNS **AAAA record** for your application’s host name, pointing to the new IPv6 address. This step is critical so that IPv6-only clients can discover the IPv6 address of your service. If your service also has an IPv4 address (dual stack), you will have both [A (IPv4) and AAAA (IPv6) records](https://learn.microsoft.com/en-us/azure/dns/dns-zones-records#record-types) for the same host name. DNS will thus allow clients of either IP family to connect. (In multi-region scenarios using Traffic Manager or Front Door, DNS configuration might be handled through those services as discussed later.)
7. **Test IPv6 Connectivity**: Once set up, test from an IPv6-enabled network or use online tools to ensure the site is reachable via IPv6. Azure’s services like Application Gateway and Front Door will handle the dual-stack routing, but it’s good to verify that content loads on an IPv6-only connection and that SSL certificates, etc., work over IPv6 as they do for IPv4.

Next, we explore specific Azure services and architectures for IPv6 web delivery in detail.

---
### External Load Balancer - single region

Azure [External Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview) (also known as Public Load Balancer) can be deployed in a single region to provide IPv6 access to applications running on virtual machines or VM scale sets. In a single-region setup, **External Load Balancer acts as a Layer 4 entry point** for IPv6 traffic, distributing connections across backend instances. This scenario is ideal when you have stateless applications or services that don't require Layer 7 features like SSL termination or path-based routing.

**Key IPv6 Features of External Load Balancer**: 
- **Dual-Stack Frontend:** Standard Load Balancer supports both [IPv4 and IPv6 frontends](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-ipv6-overview) simultaneously. When configured as dual-stack, the load balancer gets two public IP addresses – one IPv4 and one IPv6 – and can distribute traffic from both IP families to the same backend pool.
- **Zone-Redundant by Default:** Standard Load Balancer is zone-redundant by default, providing high availability across Azure Availability Zones within a region without additional configuration.
- **IPv6 Frontend Availability:** IPv6 support in Standard Load Balancer is available in all Azure regions. Basic Load Balancer does *not* support IPv6, so you must use Standard SKU.
- **IPv6 Backend Pool Support:** While the frontend accepts IPv6 traffic, the load balancer will **not** translate IPv6 to IPv4. Backend pool members (VMs) must have private IPv6 addresses. You will need to add private IPv6 addressing to your existing VM IPv4-only infrastructure. This is in contrast to Application Gateway, discussed below, which will terminate inbound IPv6 network sessions and connect to the backend-end over IPv4.
- **Protocol Support:** Supports TCP and UDP load balancing over IPv6, making it suitable for web applications, APIs, and other TCP-based services accessed by IPv6-only clients.

![image](/images/elb-single-region.png)

**Single Region Deployment Steps:** To set up an IPv6-capable External Load Balancer in one region, follow this high-level process:

1. **Enable IPv6 on the Virtual Network:** Ensure the VNET where your backend VMs reside has an IPv6 address space. Add a dual-stack address space to the VNET (e.g., add an IPv6 space like 2001:db8:1234::/56 to complement your existing IPv4 space). Configure subnets that are dual-stack, containing both IPv4 and IPv6 prefixes (/64 for IPv6).
2. **Create Standard Load Balancer with IPv6 Frontend:** In the Azure Portal, create a new **Standard Load Balancer**. During creation, configure the frontend IP with both IPv4 and IPv6 public IP addresses. Create or select existing Standard SKU public IP resources – one for IPv4 and one for IPv6. The IPv6 public IP will be automatically zone-redundant.
3. **Configure Backend Pool:** Add your virtual machines or VM scale set instances to the backend pool. Note that your backend instances will need to have private IPv6 addresses, in addition to IPv4 addresses, to receive inbound IPv6 traffic via the load balancer.
4. **Set Up Load Balancing Rules:** Create load balancing rules that map frontend ports to backend ports. For web applications, typically map port 80 (HTTP) and 443 (HTTPS) from both the IPv4 and IPv6 frontends to the corresponding backend ports. Configure health probes to ensure only healthy instances receive traffic.
5. **Configure Network Security Groups:** Ensure an NSG is present on the backend VM's subnet, allowing inbound traffic from the internet to the port(s) of the web application. Inbound traffic is "secure by default" meaning that inbound connectivity from internet is blocked unless there is an NSG present that explicitly allows it.
6. **DNS Configuration:** Create DNS records for your application: an **A record** pointing to the IPv4 address and an **AAAA record** pointing to the IPv6 address of the load balancer frontend.

**Outcome:** In this single-region scenario, IPv6-only clients will resolve your application's hostname to an IPv6 address and connect to the External Load Balancer over IPv6. The load balancer then distributes this traffic across your backend VMs over IPv4 internally. This approach **requires no changes to your application code or VM configuration** – only the network frontend gains IPv6 capability.

**Example:** Consider a [web application](https://github.com/mddazure/azure-region-viewer) running on a VM (or a VM scale set) behind an External Load Balancer in Sweden Central. The VM runs a containerized application exposed on port 80, which displays the region the VM is deployed in and the calling client's IP address. The load balancer's front-end IPv6 address has a DNS name of `ipv6webapp-elb-swedencentral.swedencentral.cloudapp.azure.com`. When called from a client with an IPv6 address, the application shows its region and the client's address.

![image](/images/client-view-elb-single-region.png)

**Limitations & Considerations:**
- *Standard SKU Required:* Basic Load Balancer does not support IPv6. You must use Standard Load Balancer, which has different pricing and capabilities.
- *Layer 4 Only:* Unlike Application Gateway, External Load Balancer operates at Layer 4 (transport layer). It cannot perform SSL termination, cookie-based session affinity, or path-based routing. If you need these features, consider Application Gateway instead.
- *Dual stack IPv4/IPv6 Backend required:* Backend pool members must have private IPv6 addresses to receive inbound IPv6 traffic via the load balancer. The load balancer does not translate between the IPv6 frontend and an IPv4 backend.
- *Outbound Connectivity:* If your backend VMs need outbound internet access over IPv6, you need to configure an IPv6 outbound rule.

---
### Global Load Balancer - multi-region

Azure [Global Load Balancer](https://learn.microsoft.com/en-us/azure/load-balancer/cross-region-overview) (aka Cross-Region Load Balancer) provides a cloud-native global network load balancing solution for distributing traffic across multiple Azure regions. Unlike DNS-based solutions, Global Load Balancer uses anycast IP addressing to automatically route IPv6 clients to the nearest healthy regional deployment through Microsoft's global network.

**Key Features of Global Load Balancer:**
- **Static Anycast Global IP:** Global Load Balancer provides a single static public IP address (both IPv4 and IPv6 supported) that is advertised from multiple Azure regions globally. This anycast address ensures clients always connect to the nearest available Microsoft edge node without requiring DNS resolution.
- **Geo-Proximity Routing:** The geo-proximity load-balancing algorithm minimizes latency by directing traffic to the nearest region. Unlike DNS-based routing, there's no DNS lookup delay - clients connect directly to the anycast IP and are immediately routed to the best region.
- **Layer 4 Pass-Through:** Global Load Balancer operates as a Layer 4 pass-through network load balancer, preserving the original client IP address (including IPv6 addresses) for backend applications to use in their logic.
- **Regional Redundancy:** If one region fails, traffic is automatically routed to the next closest healthy regional load balancer within seconds, providing instant global failover without DNS propagation delays.

**Architecture Overview:** Global Load Balancer sits in front of multiple regional Standard Load Balancers, each deployed in different Azure regions. Each regional load balancer serves a local deployment of your application with IPv6 frontends. The global load balancer provides a single anycast IP address that clients worldwide can use to access your application, with automatic routing to the nearest healthy region.

![image](/images/glb-dual-region.png)

**Multi-Region Deployment Steps:**

1. **Deploy Regional Load Balancers**: Create Standard External Load Balancers in multiple Azure regions (e.g. Sweden Central, East US2). Configure each with dual-stack frontends (IPv4 and IPv6 public IPs) and connect them to regional VM deployments or VM scale sets running your application.

2. **Create Global Load Balancer**: Deploy the Global Load Balancer in one of the supported [home regions](https://learn.microsoft.com/en-us/azure/load-balancer/cross-region-overview#home-regions-in-azure) (such as East US, West Europe, or North Europe). The home region only affects where the global load balancer resource is deployed - it doesn't impact traffic routing.

3. **Configure Global Frontend**: Create a Global tier public IP address (IPv6 supported) for the frontend. This becomes your application's global anycast address that will be advertised from participating regions worldwide.

4. **Add Regional Backends**: Configure the backend pool of the global load balancer to include your regional Standard Load Balancers. Each regional load balancer becomes an endpoint in the global backend pool. The global load balancer automatically monitors the health of each regional endpoint.

5. **Set Up Load Balancing Rules**: Create load balancing rules mapping frontend ports to backend ports. For web applications, typically map port 80 (HTTP) and 443 (HTTPS). The backend port on the global load balancer must match the frontend port of the regional load balancers.

6. **Configure Health Probes**: Global Load Balancer automatically monitors the health of regional load balancers every 5 seconds. If a regional load balancer's availability drops to 0, it's automatically removed from rotation, and traffic is redirected to other healthy regions.

7. **DNS Configuration**: Create DNS records pointing to the global load balancer's anycast IP addresses. Create both A (IPv4) and AAAA (IPv6) records for your application's hostname pointing to the global load balancer's static IPs.

**Outcome:** IPv6 clients connecting to your application's hostname will resolve to the global load balancer's anycast IPv6 address. When they connect to this address, the Microsoft global network infrastructure automatically routes their connection to the nearest participating Azure region. The regional load balancer then distributes the traffic across local backend instances. If that region becomes unavailable, subsequent connections are automatically routed to the next nearest healthy region.

**Example:** Our web application, which displays the region it is in, and the calling client's IP address, now runs on VMs behind External Load Balancers in Sweden Central and East US2.  The External Load Balancer's front-ends are in the backend pool of a Global Load Balancer, which has a Global tier front-end IPv6 address. The front-end has an FQDN of `ipv6webapp-glb.eastus2.cloudapp.azure.com` (the region designation `eastus2` in the FQDN refers to the Global Load Balancer's "home region", into which the Global tier public IP must be deployed). When called from a client in Europe, Global Load Balancer directs the request to the instance deployed in Sweden Central.

![image](/images/client-view-glb-from-sweden.png)

When called from a client in the US, Global Load Balancer directs the request to the instance deployed in US East 2.

![image](/images/client-view-glb-from-uswest3.png)


**Features:**
- **Client IP Preservation**: The original IPv6 client address is preserved and available to backend applications, enabling IP-based logic and compliance requirements.
- **Floating IP Support**: Configure floating IP at the global level for advanced networking scenarios requiring direct server return or high availability clustering.
- **Instant Scaling**: Add or remove regional deployments behind the global endpoint without service interruption, enabling dynamic scaling for traffic events.
- **Multiple Protocol Support**: Supports both TCP and UDP traffic distribution across regions, suitable for various application types beyond web services.

**Limitations & Considerations:**
- *Home Region Requirement:* Global Load Balancer can only be deployed in specific [home regions](https://learn.microsoft.com/en-us/azure/load-balancer/cross-region-overview#home-regions-in-azure), though this doesn't affect traffic routing performance.
- *Public Frontend Only:* Global Load Balancer currently supports only public frontends - internal/private global load balancing is not available.
- *Standard Load Balancer Backends:* Backend pool can only contain Standard Load Balancers, not Basic Load Balancers or other resource types.
- *Same IP Version Requirement:* NAT64 translation isn't supported - frontend and backend must use the same IP version (IPv4 or IPv6).
- *Port Consistency:* Backend port on global load balancer must match the frontend port of regional load balancers for proper traffic flow.
- *Health Probe Dependencies:* Regional load balancers must have proper health probes configured for the global load balancer to accurately assess regional health.

**Comparison with DNS-Based Solutions:**
Unlike Traffic Manager or other DNS-based global load balancing solutions, Global Load Balancer provides:
- **Instant Failover**: No DNS TTL delays - failover happens within seconds at the network level.
- **True Anycast**: Single IP address that works globally without client-side DNS resolution.
- **Consistent Performance**: Geo-proximity routing through Microsoft's backbone network ensures optimal paths.
- **Simplified Management**: No DNS record management or TTL considerations.

This architecture delivers **global high availability and optimal performance** for IPv6 applications through anycast routing, making it a good solution for latency-sensitive applications requiring worldwide accessibility with near-instant regional failover.

---
### Application Gateway - single region

[Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview) can be deployed in a single region to provide IPv6 access to applications in that region. Application Gateway acts as the entry point for IPv6 traffic, terminating HTTP/S from IPv6 clients and forwarding to backend servers over IPv4. This scenario works well when your web application is served from one Azure region and you want to enable IPv6 connectivity for it.

**Key IPv6 Features of Application Gateway (v2 SKU)**: 
- **Dual-Stack Frontend:** Application Gateway v2 supports both [IPv4 and IPv6 frontends](https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-faq). When configured as dual-stack, the gateway gets two IP addresses – one IPv4 and one IPv6 – and can listen on both. (IPv6-only mode is not supported; IPv4 is always paired). IPv6 support requires Application Gateway v2, v1 does not support IPv6.
- **No IPv6 on Backends:** The backend pool must use IPv4 addresses. IPv6 addresses for backend servers are currently not supported. This means your web servers can remain on IPv4 internal addresses, simplifying adoption because you only enable IPv6 on the frontend.
- **WAF Support:** The Application Gateway WAF (Web Application Firewall) will inspect IPv6 client traffic just as it does IPv4. 
  
![image](images/appgw-single-region.png)

**Single Region Deployment Steps:** To set up an IPv6-capable Application Gateway in one region, consider the following high-level process:

1. **Enable IPv6 on the Virtual Network:** Ensure the region’s VNet where the Application Gateway will reside has an IPv6 address space. Configure a subnet for the Application Gateway that is dual-stack (contains both an IPv4 subnet prefix and an IPv6 /64 prefix). Azure’s dual-stack networking will assign the gateway resources addresses in both subnets.

2. **Deploy Application Gateway (v2) with Dual Stack Frontend:** ICreate a new Application Gateway using the **Standard_v2 or WAF_v2 SKU**. In networking settings, choose **IP address type: Dual Stack (IPv4 & IPv6)**. This will prompt you to either select existing or create new public IP resources – one IPv4 and one IPv6. 
Application Gateway v2 supports private IPv4 and IPv6 front-ends in addition to the public front-ends.

1.  **Populate Backend Pool:** Ensure your backend pool (the target application servers or service) contains (DNS names pointing to) IPv4 addresses of your actual web servers. IPv6 addresses are not supported for backends.

2.  **Configure Listeners and Rules:** Set up listeners on the Application Gateway for your site. Typically, you’ll have a listener that binds to *Both* the IPv4 and IPv6 frontends on a given port. When creating an HTTP(S) listener, you choose which frontend IP to use – you would create one listener for IPv4 address and one for IPv6. Both listeners can use the same domain name (hostname) and the same underlying routing rule to your backend pool.

3.   **Testing and DNS:** After the gateway is deployed and configured, note the IPv6 address of the frontend (you can find it in the Gateway’s overview or in the associated Public IP resource). Update your application’s DNS records: create an **AAAA record** pointing to this IPv6 address (and update the A record to point to the IPv4 if it changed). With DNS in place, test the application by accessing it from an IPv6-enabled client or tool.

**Outcome:** In this single-region scenario, IPv6-only clients will resolve your website’s hostname to an IPv6 address and connect to the Application Gateway over IPv6. The Application Gateway then handles the traffic and forwards it to your application over IPv4 internally. From the user perspective, the service now appears natively on IPv6. Importantly, this **does not require any changes to the web servers**, which can continue using IPv4. 

Application Gateway will include the source IPv6 address in an X-Forwarded-For header, so that the backend application has visibility of the originating client's address.

**Example:** Our web application, which displays the region it is deployed in and the calling client's IP address, now runs on a VM behind Application Gateway in Sweden Central. The front-end has an FQDN of `ipv6webapp-appgw-swedencentral.swedencentral.cloudapp.azure.com`. 
Application Gateway terminates the IPv6 connection from the client and proxies the traffic to the application over IPv4. The client's IPv6 address is passed in the X-Forwarded-For header, which is read and displayed by the application.

![image](/images/client-view-appg-single-region.png)

**Limitations & Considerations:** 
- *Application Gateway v1 SKUs are not supported for IPv6.* If you have an older deployment on v1, you’ll need to migrate to v2.
- *IPv6-only Application Gateway is not allowed.* You must have IPv4 alongside IPv6 (the service must be dual-stack). This is usually fine, as dual-stack ensures all clients are covered.
- *No IPv6 backend addresses:* The backend pool must have IPv4 addresses. 
- *Management and Monitoring:* Application Gateway logs traffic from IPv6 clients in its access logs (the client IP field will show IPv6 addresses).  Azure Monitor and Network Watcher support IPv6 in NSG flow logs and metrics similarly to IPv4. 
- *Security:* Azure’s infrastructure provides basic DDoS protection for IPv6 endpoints just as for IPv4. However, it is highly recommended to deploy Azure DDoS Protection Standard: this provides enhanced mitigation tailored to your specific deployment. 
Consider using the Web Application Firewall function for protection against application layer attacks.

---
### Application Gateway - multi-region

Mission-critical web applications should be deploy in multiple Azure regions, achieving higher availability and lower latency for users worldwide. In a multi-region scenario, you need a mechanism to direct IPv6 client traffic to the “nearest” or healthiest region. Azure Application Gateway by itself is a regional service, so to use it in multiple regions, we use **Azure Traffic Manager** for global DNS load balancing, or use Azure Front Door (covered in the next section) as an alternative. This section focuses on the **Traffic Manager + Application Gateway** approach to multi-region IPv6 delivery.

**Using Traffic Manager for Multi-Region IPv6**: [Azure Traffic Manager](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview) is a DNS-based load balancer that can distribute traffic across endpoints in different regions. It works by responding to DNS queries with the appropriate endpoint FQDN or IP, based on the routing method (Performance, Priority, Geographic) configured. Traffic Manager is agnostic to the IP version: it either returns CNAMEs, or AAAA records for IPv6 endpoints and A records for IPv4. This makes it suitable for routing IPv6 traffic globally.

**Architecture Overview:** Each region has its own dual-stack Application Gateway. Traffic Manager is configured with an endpoint entry for each region’s gateway. The application’s FQDN is now a domain name hosted by Traffic Manager such as ipv6webapp.traffimanager.net, or a CNAME that ultimately points to it.

![image](/images/appgw-dual-region.png)

DNS resolution will go through Traffic Manager, which decides which regional gateway’s FQDN to return. The client then connects directly to that Application Gateway’s IPv6 address, as follows:

1.  **DNS query**: Client asks for `ipv6webapp.trafficmanager.net`, which is  hosted in a Traffic Manager profile.
2. **Traffic Manager decision**: Traffic Manager sees an incoming DNS request (which may come with the client’s IP context) and chooses the best endpoint (say, Sweden Central) based on routing rules (e.g., geographic proximity or lowest latency).
3. **Traffic Manager response**: Traffic Manager returns the FQDN of the Sweden Central Application Gateway to the client. 
4. **DNS Resolution**: The client resolves regional FQDN and receives a AAAA response containing the IPv6 address.
5. **Client connects**: The client’s browser connects to the West Europe App Gateway IPv6 address directly. The HTTP/S session is established via IPv6 to that regional gateway, which then handles the request.
6. **Failover**: If that region becomes unavailable, Traffic Manager’s health checks will detect it and subsequent DNS queries will be answered with the FQDN of the secondary region’s gateway. 

**Deployment Steps for Multi-Region with Traffic Manager:**

1. **Set up Dual-Stack Application Gateways in each region**: Similar to the single-region case, deploy an Azure Application Gateway v2 in each desired region (e.g., one in North America, one in Europe). Configure the web application in each region, these should be parallel deployments serving the same content.

2. **Configure a Traffic Manager Profile**: In Azure Traffic Manager, create a profile and choose a [routing method](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-routing-methods) (such as Performance for nearest region routing, or Priority for primary/backup failover). Add [endpoints](https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-endpoint-types) for each region. Since our endpoints are Azure services with IPs, we can either use *Azure endpoints* (if the Application Gateways have Azure-provided DNS names) or *External endpoints* using the IP addresses. The simplest way is to use the *Public IP resource* of each Application Gateway as an Azure endpoint – ensure each App Gateway’s public IP has a DNS label (so it has a FQDN). Traffic Manager will detect those and also be aware of their IPs. Alternatively, use the IPv6 address as an External endpoint directly. Traffic Manager allows IPv6 addresses and will return AAAA records for them.

3. **DNS Setup**: Traffic Manager profiles have a FQDN (like `ipv6webapp.trafficmanager.net`). You can either use that as your service’s CNAME, or you can configure your custom domain to CNAME to the TM profile.  

4. **Health Probing**: Traffic Manager continuously checks the health of endpoints. When endpoints are Azure App Gateways, TM uses HTTP/S probes to a specified URI path, to each gateway’s address. Make sure each App Gateway has a listener on the probing endpoint (e.g., a health check page) and that health probes are enabled. TM will consider an endpoint degraded if probes fail over both IPv4 and IPv6. 

5. **Testing Failover and Distribution**: Test the setup by querying DNS from different geographical locations (to see if you get the nearest region’s IP). Also simulate a region down (stop the App Gateway or backend) and observe if Traffic Manager directs traffic to the other region. Because DNS TTLs are involved, failover isn’t instant but typically within a couple of minutes depending on TTL and probe interval.

**Considerations in this Architecture:**
- *Latency vs Failover:* Traffic Manager as a DNS load balancer directs users at connect time, but once a client has an answer (IP address), it keeps sending to that address until the DNS record TTL expires and it re-resolves. This is fine for most web apps. Ensure the TTL in the Traffic Manager profile is not too high (the default is 30 seconds).
- *IPv6 DNS and Connectivity:* Confirm that each region’s IPv6 address is correctly configured and reachable globally. Azure’s public IPv6 addresses are globally routable. Traffic Manager itself is a global service and fully supports IPv6 in its decision-making. 
- *Cost:* Using multiple Application Gateways and Traffic Manager incurs costs for each component (App Gateway is per hour + capacity unit, Traffic Manager per million DNS queries). This is a trade-off for high availability.
- *Alternative: Azure Front Door:* If your application is purely web (HTTP/S), you might consider Azure Front Door instead of the Traffic Manager + Application Gateway combination. Front Door can automatically handle global routing and failover at layer 7 without DNS-based limitations, offering potentially faster failover. Azure Front Door is discussed in the next section.

**In summary**, a multi-region IPv6 web delivery with Application Gateways uses **Traffic Manager for global DNS load balancing**. Traffic Manager will seamlessly return IPv6 addresses for IPv6 clients, ensuring that no matter where an IPv6-only client is, they get pointed to the nearest available regional deployment of your app. This design achieves **global resiliency** (withstand a regional outage) and **low latency** access, leveraging IPv6 connectivity on each regional endpoint.

**Example:** The global FQDN of our application is now `ipv6web.trafficmanager.net` and clients will use this FQDN to access the application regardless of their geographical location.
Traffic Manager will return the FQDN of one of the regional deployements, `ipv6webapp-appgw-swedencentral.swedencentral.cloudapp.azure.com` or `ipv6webappr2-appgw-eastus2.eastus2.cloudapp.azure.com` depending on the routing method configured, the health state of the regional endpoints and the client's location. Then the client resolves the regional FQDN through its local DNS server and connects to the regional instance of the application.

DNS resolution from a client in Europe:
```
Resolve-DnsName ipv6webapp.trafficmanager.net

Name                           Type   TTL   Section    NameHost
----                           ----   ---   -------    --------
ipv6webapp.trafficmanager.net  CNAME  59    Answer     ipv6webapp-appgw-swedencentral.swedencentral.cloudapp.azure.com

Name       : ipv6webapp-appgw-swedencentral.swedencentral.cloudapp.azure.com
QueryType  : AAAA
TTL        : 10
Section    : Answer
IP6Address : 2603:1020:1001:25::168
```
And from a client in the US:
```
Resolve-DnsName ipv6webapp.trafficmanager.net

Name                           Type   TTL   Section    NameHost
----                           ----   ---   -------    --------
ipv6webapp.trafficmanager.net  CNAME  60    Answer     ipv6webappr2-appgw-eastus2.eastus2.cloudapp.azure.com

Name       : ipv6webappr2-appgw-eastus2.eastus2.cloudapp.azure.com
QueryType  : AAAA
TTL        : 10
Section    : Answer
IP6Address : 2603:1030:403:17::5b0
```
---
### Azure Front Door

[Azure Front Door](https://learn.microsoft.com/en-us/azure/frontdoor/front-door-overview) is an application delivery network with built-in CDN, SSL offload, WAF, and routing capabilities. It provides a single, unified frontend distributed across Microsoft’s edge network. Azure Front Door natively supports IPv6 connectivity. 

For applications that have users worldwide, Front Door offers advantages:
- **Global Anycast Endpoint:** Provides anycast IP addresses accessible from multiple edge locations with automatic AAAA DNS record support for IPv6 clients.
- **Simplified DNS:** Custom domains can be mapped using CNAME records, with IPv6 support handled automatically.
- **Layer-7 Routing:** Supports path-based routing and automatic backend health detection.
- **Edge Security:** Includes DDoS protection and optional WAF integration.

Azure Front Door does not support IPv6 origins (i.e. backends) at the time of this writing in October 2025. While Front Door itself is dual-stack and accepts client traffic over IPv4 and IPv6, the origin must be publicly accessible via IPv4, or be reachable over Private Link integration. Front Door preserves the client's source IP address in the X-Forwarded-For, 



#### Private Link Integration

Azure Front Door Premium introduces **Private Link integration**, enabling secure, private connectivity between Front Door and your backend resources without exposing them to the public internet. 

When Private Link is enabled, Azure Front Door establishes a private endpoint within a Microsoft-managed virtual network. This endpoint acts as a secure bridge between Front Door’s global edge network and your origin resources, such as Azure App Service, Azure Storage, Application Gateway, or workloads behind an internal load balancer.
Traffic from end users still enters through Front Door’s globally distributed POPs, benefiting from features like SSL offload, caching, and WAF protection. However, instead of routing to your origin over public, internet-facing, endpoints, Front Door uses the private Microsoft backbone to reach the private endpoint. This ensures that all traffic between Front Door and your origin remains isolated from external networks.

The private endpoint connection requires approval from the origin resource owner, adding an extra layer of control. Once approved, the origin can restrict public access entirely, enforcing that all traffic flows through Private Link.

![image](/images/tm-dual-region.png)

#### Benefits of Private Link with Front Door

- **Enhanced Security:** By removing public exposure of backend services, Private Link significantly reduces the risk of DDoS attacks, data exfiltration, and unauthorized access.
- **Compliance and Governance:** Many regulatory frameworks mandate private connectivity for sensitive workloads. Private Link helps meet these requirements without sacrificing global availability.
- **Performance and Reliability:** Traffic between Front Door and your origin travels over Microsoft’s high-speed backbone network, delivering low latency and consistent performance compared to public internet paths.
- **Defense in Depth:** Combined with Web Application Firewall (WAF), TLS encryption, and DDoS protection, Private Link strengthens your security posture across multiple layers.
- **Isolation and Control:** Resource owners maintain control over connection approvals, ensuring that only authorized Front Door profiles can access the origin.
Integration with Hybrid Architectures: For scenarios involving AKS clusters, custom APIs, or workloads behind internal load balancers, Private Link enables secure connectivity without requiring public IPs or complex VPN setups.

Private Link transforms Azure Front Door from a global entry point into a fully private delivery mechanism for your applications, aligning with modern security principles and enterprise compliance needs.

#### Configuration Steps for Azure Front Door

1. **Create a Front Door profile:** Create a new **Front Door Standard or Premium tier** profile. Standard provides connectivity and routing functionality,Premium adds security features such as WAF and Private Link origin integration. 

2. **Add Backend Pools:** Configure one or more backend pools in Front Door. Backends can be anything: Azure Web Apps, Application Gateways, VMs with Public IPs, etc.  Front Door will forward to the backend's IPv4 address. If your backend *does* have an IPv6 address (like a dual-stack App Gateway or VM with IPv6), you could specify it, but that's optional. Assign a name and configure health probe and load balancing settings for the pool.

3. **Configure Routes:** Set up a routing rule mapping the Front Door frontend to the backend pool. For example, route `/*` (all paths) on your Front Door domain to Backend Pool A. Enable protocols (Front Door supports HTTP/2 and web sockets with IPv6 too). If you have multiple regions, you might have multiple backend endpoints in the pool; Front Door will balance between them (you can do priority-based or weighted to prefer one region and fail to another).

4. **Front Door Frontend Host and Custom Domain:** Once deployed, test using the default front door hostname (e.g. `ipv6webapp-d4f4euhnb8fge4ce.b01.azurefd.net`). It should be reachable via IPv6. Then optionally map a custom domain: create a CNAME from `ipv6webapp.contoso.com` to `ipv6webapp-d4f4euhnb8fge4ce.b01.azurefd.net`. Azure Front Door will automatically serve traffic for that custom domain once you validate it.

5. **Web Application Firewall (optional):** If [Web Application Firewall](https://learn.microsoft.com/en-us/azure/frontdoor/web-application-firewall) is enabled, configure a policy. The Azure-managed Default Rule Set is enabled by default and provides protection against common threats. Add optional custom rules as needed. Azure Front Door provides built-in protection against network-layer DDoS attacks.

**Note:** Front Door provides managed IPv6 addresses that are not customer-owned resources. Custom domains should use CNAME records pointing to the Front Door hostname rather than direct IP address references.
---
## Conclusion

IPv6 adoption for web applications is no longer optional. It is essential as public IPv4 address space is depleted, mobile networks increasingly use IPv6 only and governments mandate IPv6 reachability for public services. Azure's comprehensive dual-stack networking capabilities provide a clear path forward, enabling organizations to leverage IPv6 externally without sacrificing IPv4 compatibility or requiring complete infrastructure overhauls.

Azure's externally facing services — including Application Gateway, External Load Balancer, Global Load Balancer, and Front Door — support IPv6 frontends, while Application Gateway and Front Door maintain IPv4 backend connectivity. This architecture allows applications to remain unchanged while instantly becoming accessible to IPv6-only clients.

For single-region deployments, Application Gateway offers layer-7 features like SSL termination and WAF protection. External Load Balancer provides high-performance layer-4 distribution. Multi-region scenarios benefit from Traffic Manager's DNS-based routing combined with regional Application Gateways, or the superior performance and failover capabilities of Global Load Balancer's anycast addressing.

Azure Front Door provides global IPv6 delivery with edge optimization, built-in security, and seamless failover across Microsoft's network. Private Link integration allows secure global IPv6 distribution while maintaining backend isolation.

The transition to IPv6 application delivery on Azure is straightforward: enable dual-stack addressing on virtual networks, configure IPv6 frontends on load balancing services, and update DNS records. With Application Gateway or Front Door, backend applications require no modifications. These Azure services handle the IPv4-to-IPv6 translation seamlessly. This approach ensures both immediate IPv6 accessibility and long-term architectural flexibility as IPv6 adoption accelerates globally.

---
## Lab
This lab deploys the environment shown in the diagrams above. This was used to validate the concepts described and generate the screenshots. The lab includes teh hub and spoke VNETs in US East 2 and Sweden Central, Application Gateways, External Load Balancers and VMs in both regions, Global Load Balancer and Traffic Manager. It does not include Azure Front Door.

The VMs run the [Azure Region and Client IP Viewer](https://github.com/mddazure/azure-region-viewer) application. This displays the region the VM is deployed in and the calling client's IP address on a web page, when called at the root endpoint (/). The /api/region endpoint provides debugging information in json format.
If an X-Forwarded-For header containing the orginal client IP address is present, the application will display this.If not, it will display the source IP address of the request.


### Deploy
Log in to Azure Cloud Shell at https://shell.azure.com/ and select Bash.

Ensure Azure CLI and extensions are up to date:
  
    az upgrade --yes
  
If necessary select your target subscription:
  
    az account set --subscription <Name or ID of subscription>
  
Clone the  GitHub repository:

    git clone https://github.com/mddazure/ipv6-web-app

Change directory:
  
      cd ./ipv6-web-app

Deploy the Bicep template:

      az deployment sub create --location swedencentral --template-file main-region-viewer.bicep

Verify that all components have been deployed to the resourcegroup `ipv6-web-app-rg` and are healthy.

### Observe
The lab exposes the following public endpoints:

| Type | Region | URL |
|------|--------|-----|
| External Load Balancer | Sweden Central | ipv6webapp-elb-swedencentral.swedencentral.cloudapp.azure.com |
| External Load Balancer | East US 2 | ipv6webapp-elb-eastus2.eastus2.cloudapp.azure.com |
| Application Gateway | Sweden Central | ipv6webapp-appgw-swedencentral.swedencentral.cloudapp.azure.com |
| Application Gateway | East US 2 | ipv6webapp-appgw-eastus2.eastus2.cloudapp.azure.com |
| Global Load Balancer | Global | ipv6webapp-glb.eastus2.cloudapp.azure.com |

Call each URL from a web browser from machines in different regions and observe the outcomes.
