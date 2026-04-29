Chaos Experiment - Instance Start and Stop Hands-on 
 
>>>>> Objective: 

Resiliency against an AZ failure 

 


The purpose of this experiment is to demonstrate infrastructure resiliency against an Availability Zone (AZ) failure using Chaos Engineering principles. 

Deploy two EC2 instances in separate AZs (us-east-2a and us-east-2b). 

Place an Application Load Balancer (ALB) in front of them. 

Simulate a failure by stopping one instance using AWS Fault Injection Simulator (FIS). 

Observe how traffic automatically shifts to the healthy instance in the other AZ. 

This validates that the system can tolerate AZ-level disruptions without downtime. 

 

>>>>> Architecture Overview 

Components created with Terraform: 

VPC & Subnets → Default VPC with subnets across AZs. 

Security Group → Allows SSH (22) and HTTP (80). 

EC2 Instances → 

Instance A → us-east-2a (serves “Hello from Instance A”). 

Instance B → us-east-2b (serves “Hello from Instance B”). 

Application Load Balancer (ALB) → Routes traffic across instances with health checks. 

IAM Role + Policy for FIS → Allows EC2 start/stop actions. 

FIS Experiment Template → Stops one instance to simulate AZ failure. 

 

>>>> Step-by-Step Implementation 

Step 1: Terraform Setup 

Install Terraform and AWS CLI. 

Create a working directory. 

Add the Terraform code (main.tf). 



>>>> Expected Chaos Demo Flow 

Visit ALB URL → Served by Instance B. 

Run FIS Experiment → Instance B stops. 

Refresh browser → ALB automatically shifts traffic to Instance A. 

………………………………………………………………. 

>>>> Navigate to AWS FIS (Console) 

Login to your AWS Management Console. 

In the top search bar, type “Fault Injection Simulator” or “FIS”. 

Click on Fault Injection Simulator from the search results. 

You’ll now land on the AWS FIS Dashboard. 

Left panel options: 

Experiment templates → Pre-defined chaos experiments. 

Experiments → Run and monitor chaos experiments. 

Actions → Start 

………………………………………………………………….. 

>>>> Steps to Check in Browser 

Open your Load Balancer DNS URL (example: http://<ALB-DNS>). 

You’ll see Instance A (Hello ). 

Start the FIS Experiment (10 min) 

Instance A will be stopped. 

Refresh the Browser 

Now you’ll see Instance B page (Hello). 

 

…………………………………………………………………. 

 

>>>>> Chaos Handons Summary 

Objective 

Demonstrate resilience of infrastructure by running a controlled failure experiment. 

Show how traffic seamlessly shifts between instances when one fails. 

Setup 

Two EC2 instances (Instance A in us-east-2a, Instance B in us-east-2b). 

Both registered under an Application Load Balancer (ALB). 

Only one instance runs at a time to serve traffic. 

Experiment 

Used AWS Fault Injection Simulator (FIS) to stop Instance (running one). 

Observed: 

Instance B stopped. 

ALB automatically routed traffic to Instance A, which started and served requests. 

After FIS completion, system remained available without downtime. 

Outcome 
 
Demonstrated high availability – application stayed online even when one instance failed. 
Showed automatic traffic failover using ALB health checks.Verified chaos experiment success – proved system can tolerate instance failure. 
 
Key Learning 

Chaos Engineering is not about breaking things, but about building confidence that the system can recover gracefully. 

With automation (FIS + ALB + EC2), the system becomes self-healing and resilient. 

Visual Representation (for presentations)
                ┌──────────────────────┐
                │   Application LB     │
                │  (DNS entry point)   │
                └─────────┬────────────┘
                          │
          ┌───────────────┼───────────────┐
          │                               │
 ┌────────▼─────────┐            ┌────────▼─────────┐
 │ Instance A        │            │ Instance B        │
 │ us-east-2a        │            │ us-east-2b        │
 │ "Hello from A"    │            │ "Hello from B"    │
 └────────┬─────────┘            └────────┬─────────┘
          │                               │
          │   FIS Stops Instance A        │
          │                               │
          └─────────────X─────────────────┘

 ALB automatically shifts traffic to Instance B
 → System stays online

