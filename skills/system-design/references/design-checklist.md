# Design checklist

## Scale
- What is the bottleneck at ten times today's load: the database, an external API, CPU, or memory?
- Are reads cached where it helps, with a TTL and an invalidation rule?
- Are list operations paginated and every query bounded?
- Is slow or bursty work moved off the request path into a queue?
- Can the stateless parts run as several instances behind a load balancer?

## Reliability
- What happens when each dependency is slow or down? Is there a timeout, a retry with backoff, and a fallback or a clear error?
- Are retried operations idempotent?
- Where is the single point of failure, and is that acceptable?
- How is data backed up, how is a restore tested, and how much data loss is acceptable?
- Can a deploy be rolled back in minutes?

## Data
- Is each piece of data owned by exactly one component?
- Are indexes planned for every filter and sort?
- How are schema changes deployed without downtime?
- Do the consistency needs of each operation match the store chosen for it?

## Security
- Who can call each endpoint, and is ownership checked?
- Where are secrets stored, and who can read them?
- Is personal data minimized, protected, and retained only as long as needed?
- Are inputs from users and partners validated at the edge?

## Operations
- Which metrics and alerts show that the system is healthy?
- Can one request be traced through logs across components?
- Is there a runbook for the most likely incidents?
- Are environments separated, and is configuration managed the same way in all of them?

## Cost
- What are the main cost drivers, and how do they grow with load?
- Are there budgets and alerts?
- Are idle resources (minimum instances, unused databases) justified?

## Simplicity
- Could a smaller design meet the same requirements?
- Does every component exist for a requirement written in the doc?
- Can a new team member understand the design in fifteen minutes?
