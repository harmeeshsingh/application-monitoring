# AI-SRE (AI-Powered Site Reliability Engineering)

## 🎯 Quick Overview

The **AI-SRE** folder contains **two practical, hands-on labs and a combined file** that demonstrate how to use **AI to automate critical SRE tasks** on AWS. Each lab is completely self-contained with full implementation code, deployment instructions, and testing procedures.

---

## 📚 Learning Paths

### Path 1: Automated Incident Response 🚨
**Learn how to automatically analyze incidents and generate remediation steps**

- **File**: [AI_SRE_RCA.md](./AI_SRE_RCA.md)
- **Duration**: 2-3 hours
- **What you'll build**:
  - CloudWatch alarm monitoring
  - Lambda automation
  - Amazon Bedrock AI integration
  - Automated email notifications
- **Skills learned**:
  - Event-driven architecture
  - AI-powered analysis
  - Incident response automation
- **Best for**: Learning how to respond to incidents instantly without manual RCA

**Architecture**: EC2 → CloudWatch Alarm → SNS → Lambda → Bedrock AI → Email

---

### Path 2: Predictive Capacity Planning 📊
**Learn how to predict infrastructure needs and get scaling recommendations**

- **File**: [AI_capability_planning.md](./AI_capability_planning.md)
- **Duration**: 2-3 hours
- **What you'll build**:
  - CloudWatch metrics collection
  - Lambda-based analysis
  - Amazon Bedrock AI predictions
  - Capacity planning reports
- **Skills learned**:
  - Metrics analysis
  - Trend prediction
  - Cost-benefit analysis
  - Scaling strategies
- **Best for**: Learning how to plan infrastructure upgrades proactively

**Architecture**: EC2 → CloudWatch Metrics → Lambda → Bedrock AI → Email

---

## �️ File Structure

```
AI-SRE/
├── README.md                           (This file - Start here)
├── AI_SRE_RCA.md                      (Incident Response - Automated RCA using AI)
├── AI_capability_planning.md          (Capacity Planning - AI-driven scaling recommendations)
└── planning and RCA in one go.md      (Combined - Capacity planning & scaling in one guide)
```

---

## ✨ Key Features

✅ **Fully Automated** - No manual intervention required once deployed  
✅ **AI-Powered** - Uses Amazon Bedrock Nova models for analysis  
✅ **Production-Ready** - Complete code with error handling  
✅ **Easy to Deploy** - Terraform makes infrastructure management simple  
✅ **Self-Contained** - Each guide has everything you need  
✅ **Testable** - Includes manual testing procedures  
✅ **Cost-Effective** - Uses serverless (pay only for execution)  

---

## 🏃 Quick Start

### Lab 1: Incident Response 🚨
👉 **Start here**: [AI_SRE_RCA.md](./AI_SRE_RCA.md)
- Learn automated incident response
- CloudWatch Alarm → Lambda → Bedrock AI
- Automatic RCA report generation
- SNS email notifications

### Lab 2: Capacity Planning 📊  
👉 **Start here**: [AI_capability_planning.md](./AI_capability_planning.md)
- Learn predictive capacity planning
- EC2 metrics → Lambda → AI analysis
- Scaling recommendations with cost analysis
- Automated email reports

### Combined Guide 
👉 **Both topics**: [planning and RCA in one go.md](./planning%20and%20RCA%20in%20one%20go.md)
- Capacity planning & scaling recommendations
- Complete architecture walkthrough
- Comprehensive implementation guide

---

## 📋 Lab Comparison

| Aspect | Incident Response | Capacity Planning |
|--------|-------------------|-------------------|
| **Purpose** | Respond to incidents automatically | Predict infrastructure needs |
| **Trigger** | CloudWatch alarm fires | Manual or scheduled |
| **Time to Action** | 5 seconds | 10 seconds |
| **Output** | RCA email with fixes | Capacity plan with cost analysis |
| **Urgency** | Immediate (crisis) | Planned (proactive) |
| **Guide File** | AI-SRE-RCA_GUIDE.md | AI-Capacity-Planning_GUIDE.md |

---

## 🎓 Learning Outcomes

After completing the labs, you'll master:

- **Event-Driven Architecture** - CloudWatch → Lambda → Bedrock
- **Serverless Automation** - Lambda IAM roles, environment variables, timeouts
- **AI Integration** - Amazon Bedrock API usage, prompt engineering
- **Infrastructure-as-Code** - Terraform for AWS resource provisioning
- **Real-World SRE Patterns** - Incident response, capacity planning, alerting
- **AWS Services** - EC2, CloudWatch, Lambda, SNS, Bedrock, IAM

---

## ❓ FAQ

**Q: Which lab should I start with?**  
A: Start with Incident Response (RCA) if new to SRE, or Capacity Planning if interested in metrics analysis.

**Q: How long does it take?**  
A: ~2-3 hours per lab, or 4-5 hours for both combined.

**Q: Do I need AWS experience?**  
A: Basic AWS knowledge helps, but guides include all details. Start with the guide!

**Q: How much will this cost?**  
A: ~$5-10/month for testing (EC2 micro + Lambda + Bedrock).

**Q: Can I extend these?**  
A: Yes! Add more instances, scale Lambda, integrate Slack, add databases, etc.

---

## 🚀 Next Steps

1. **Choose a path** → Incident Response or Capacity Planning
2. **Read the guide** → Complete lab instructions included
3. **Deploy to AWS** → Terraform config provided
4. **Test thoroughly** → Testing procedures included
5. **Extend the lab** → Customize for your needs

**Ready? Pick your lab:**
- 🚨 [Incident Response](./AI-SRE-RCA_GUIDE.md)
- 📊 [Capacity Planning](./AI-Capacity-Planning_GUIDE.md)

---

## 📊 Summary

This folder contains **complete, production-ready labs** that teach AI-powered SRE automation through hands-on deployment. Each lab is **self-contained and fully documented**. Choose your learning path and get started!

**Status**: Production-Ready | **Last Updated**: Current Session
