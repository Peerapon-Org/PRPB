---
layout: ../../layouts/BlogLayout.astro
title: "resource ที่อยู่ใน private subnet สามารถ resolve DNS หากันได้ยังไง"
author: "Peerapon Boonkaweenapanon"
date: "2025-03-13"
category: "AWS"
subcategory: "VPC"
description: ""
thumbnail: "https://prpb-web-bucket.s3.ap-southeast-1.amazonaws.com/thumbnail.png"
---

ปกติแล้วเวลาเราจะเชื่อมต่อกับเว็บไซต์อะไรซักอย่างเราก็จะระบุ URL ของเว็บไซต์นั้นใช่ไหมครับ แล้วทีนี้ตัว URL ก็จะถูกแปลงเป็นเลข IP โดย DNS resolver ซึ่งโดยพื้นฐานแล้ว DNS resolver ที่เราใช้ ๆ กันก็มักจะเป็นของ ISP หรือของยอดนิยมอย่าง 8.8.8.8 (Google) หรือ 1.1.1.1 (Cloudflare) เป็นต้น

ทีนี้ลองดูภาพด้านล่างครับ

![01.png](https://prpblog.com/assets/how-private-resources-resolve-dns/01.png)

สมมติว่าเรามี EC2 กับ RDS อยู่ใน VPC เดียวกันแต่อยู่คนละ subnet แถม subnet ทั้ง 2 อันดันเป็น private subnet ทีนี้เวลา EC2 อยากเชื่อมต่อเข้าไปที่ RDS (ขอสมมติว่าเป็น MySQL) ตัวดังกล่าวก็สามารถทำได้โดยใช้คำสั่งประมาณนี้ใช่มั้ยครับ

```bash
mysql -h mysql-db-instance.cjwms4oogzwm.ap-southeast-1.rds.amazonaws.com -u admin
```

ถ้าเราตั้งค่า security group หรือ NACL ถูกต้อง เราก็จะพบว่า EC2 สามารถเชื่อมต่อไปยัง RDS ได้แบบไม่มีปัญหา
แต่ทั้ง ๆ ที่ EC2 มันอยู่ใน private subnet แล้วมันไปทำอีท่าไหนถึงสามารถ resolve DNS ของ RDS ได้?

ซึ่งผู้ที่ทำหน้าที่คอย resolve DNS ในครั้งนี้ก็คือ **Route 53 Resolver** นั่นเองครับ

Route 53 Resolver ถ้าให้พูดง่าย ๆ ก็คือ DNS resolver ที่ AWS มอบให้เราเพื่อทำหน้าที่ resolve DNS ให้กับ resource ภายใน VPC โดยในตอนที่เราสร้าง VPC ขึ้นมา AWS จะมอบ endpoint ที่เอาไว้ใช้ในการเข้าถึง Route 53 Resolver ตัวนี้ให้เราโดยอัตโนมัติ

ซึ่ง endpoint ที่ว่านี้ก็จะมี IP ของมันอยู่ โดยที่ IP ของ endpoint ก็คือ VPC+2 หรือถ้าอธิบายแบบภาษาคนหน่อยก็คือเอา IP แรกสุดของ CIDR block ของ VPC มา แล้วบวก 2 เข้าไปก็จะได้ IP ของ endpoint ของ VPC นั้น ๆ เช่น ถ้าเรามี VPC ที่มี CIDR block คือ 192.168.0.0/16 IP ของ endpoint ใน VPC นี้ก็จะเป็น 192.168.0.0 + 2 = 192.168.0.2 ครับ

## Route 53 Resolver

ตอนนี้ภาพของเราก็จะกลายเป็นประมาณนี้

![02.png](https://prpblog.com/assets/how-private-resources-resolve-dns/02.png)

Flow แบบคร่าว ๆ ก็คือ

1. EC2 อยาก resolve DNS ของ RDS endpoint
2. EC2 ส่ง DNS query ไปที่ Route 53 Resolver ผ่านทาง VPC+2 endpoint
3. Route 53 Resolver ทำการ resolve DNS แล้วส่ง private IP ของ RDS กลับไปให้ EC2
4. EC2 ได้ IP ของ RDS มา EC2 happy

ซึ่งจะเห็นได้ว่า
