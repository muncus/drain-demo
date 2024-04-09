# Architecting for Traffic Drains

This repo contains samples for a blog post about building services that support
traffic drains. 

For further details, you can [read the blog post](http://marcdougherty.com/posts/2024-designing-for-drains/).

TL;DR- there's some terraform in these directories. it will create 2 regional GKE clusters, a deployment of the `whereami` GKE sample service, and a global loadbalancer.