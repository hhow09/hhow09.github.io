---
title: E-commerce website with AWS Serverless
description: E-commerce website with AWS Serverless (Lambda, DynamoDB, S3, API Gateway)
date: 2025-01-14
tags:
  - aws
  - application
layout: layouts/post.njk
---

An overview of the e-commerce website with AWS Serverless stack developed by me.

## Website
[https://www.avocadotaiwan.com/](https://www.avocadotaiwan.com/)

> It is running in production so I cannot share the source code. WIP on share the code template.

## Features
- User can order products and pay with credit card or ATM transfer.
- User can query the order status with order id on order query page.
- Owner can see the order status (`created`, `paid`, `shipped`) on admin page.
- Owner can configurable product, unitprice, website status with admin interface.
- Owner can query and manage order with admin interface.

## Tech Stack
### Backend & Admin Service
- Written in Golang 
- Hosted on [AWS Lambda](https://aws.amazon.com/lambda/) for backend business logic.
- AWS [API Gateway](https://aws.amazon.com/api-gateway/) for exposing Lambda as REST API.
- AWS [DynamoDB](https://aws.amazon.com/pm/dynamodb/) as main database.
- AWS [S3](https://aws.amazon.com/s3/) for website status and static contents
- [ECPay](https://corp.ecpay.com.tw/ecpay_en/) for payment integration supporting credit card and ATM transfer.

### Frontend
- [Next.js](https://nextjs.org/) (in Typescript) hosted on [Cloudflare pages](https://pages.cloudflare.com/) with [Cloudflare DNS](https://www.cloudflare.com/application-services/products/dns/)

### Deployment
- Environment: `staging`/ `production`
- Tool: [AWS Serverless Application Model (AWS SAM)](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) for fully automated deployment.

## Design Choice
1. Use **AWS Lambda** and **API Gateway** for API due to 
    - cost saving for **low RPS** website 
    - low maintenance effort
1. Use **AWS DynamoDB** for database 
    - choose NoSQL since there is no join between tables, only `order` table.
    - choose DynamoDB since it is serverless and easy to scale.
1. Use **AWS S3** for static contents and website status.
    - website status is for feature flag or announcement, which does not change frequently.
    - static contents rarely change.
    - Therefore leveraging [cache control](https://docs.aws.amazon.com/whitepapers/latest/build-static-websites-aws/controlling-how-long-amazon-s3-content-is-cached-by-amazon-cloudfront.html) for performance and cost saving.
1. Use **Next.js** for [Static Site Generation](https://nextjs.org/docs/pages/building-your-application/rendering/static-site-generation) 
    - since SEO is important for e-commerce website and server side rendering is an overkill for this project.

## Architecture
important steps are numbered and can be found in the diagram in next section.

{% image "./architecture.png", "Architecture Diagram" %}

## User Story

### Notes on Payment Option
1. Credit Card: ECPay will callback to backend with payment result, user immediately see the order status updated.
2. ATM Transfer: ECPay will asynchronously callback to backend with payment result.
3. Pay on Arrive: Payment is collected by logistics, owner can ship as long as order is created.

### Flow Diagram

```mermaid
sequenceDiagram
    participant FE
    participant BE
    participant DB
    participant S3
    participant PaymentGateway
    FE->>+S3: [1] GET site status and products
    S3-->>-FE: site status
    alt Site Not available
        Note Over FE: user flow END
    else Site Available
        Note Over FE: user browse products, fill in order form.
        FE->>+BE: [2] POST /order
        BE->>+DB: Save Order
        alt Payment Method: [Pay on arrive]
            BE-->>FE: Order ID
            FE-->>+BE: [6] GET /order
            BE-->>-FE: Order Result (shipment scheduled)
            Note Over FE: [Pay on arrive] END
        else Payment Method: [Online Payment (ECPay)]
            BE-->>-FE: Redirection
            Note Over FE: [4] redirect to payment gateway
            alt Ecpay [Credit Card]
                FE->>PaymentGateway: User Payment
                PaymentGateway->>+BE: [5] Notify Order Payed
                BE-->>DB: Update Order to Payed
                BE-->>-PaymentGateway: OK
            else Ecpay [ATM transfer] (part 1)
                rect rgb(191, 223, 255)
                    PaymentGateway-->>FE: Display ATM payment Info
                    Note Over FE: continue at Ecpay [ATM transfer] (part 2)
                end
            end
            PaymentGateway-->>FE: redirect result page
            Note Over FE: User redirected to show result page (with orderId)
            FE->>+BE: [6] GET /order
            BE-->>-FE: Order
            alt Ecpay [Credit Card]
                Note Over FE: Display payment result
            else Ecpay [ATM transfer] (part 1)
                Note Over FE: Wait for ATM payment
            end
            Note Over FE: user flow END
        end

        Note Over FE, PaymentGateway: ASYNC

        alt Ecpay [ATM transfer] (part 2)
            rect rgb(191, 223, 255)
                Note Over PaymentGateway: User Payed
                PaymentGateway->>+BE: Order Payed
                BE-->>DB: Update Order Payed
                BE-->>-PaymentGateway: OK
            end
            Note Over FE: Ecpay [ATM transfer] END
        end
    end
```

