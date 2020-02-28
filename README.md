
## Design

The design of this system uses API-GW integrations, Lambdas, SNS, DynamoDB.

The intent was to create a scalable, resilient service with the least amount of infrastructure possible. Lambda enables us to create a resilient application without having to configure a VPC, Subnets etc.

Out of the Box Lambda enables us to Vertically scale, while also enabling fault tolerance (Lambdas are fault tolerant by design.)

The use of API gateway was so that we could integrate these lambdas, but also provides a series of WAF Rules (Not Implemented). As well as enabling GET based Caching.

Below are some diagrams of the infrastructure

## First Attempt
![First](https://imgur.com/Cx6L0zT.png)

In the first attempt we keep it quite simple, using APIGW as described above to interact with the components.

## Second Attempt
![Second](https://imgur.com/5U1nD7n.png)

Here we start being a bit more security conscious. We introduce a Cloudfront to enable get caching in a future layer, while also apply WAF Rules to blacklist ips and throttle DDOS attempts. This also has the added benefit of Edge Routing to reduce latency.

We also introduce a custom authorizer and a login system. This means that users must be authorised to retrieve messages.

We also enable ROUTE-53.

Further considerations around structuring the data to only enable people to message certain people based on usertype can be made with this design.
