---
layout: ../../layouts/BlogLayout.astro
title: "S3 Pre-signed URL VS CloudFront Signed URL"
author: "Peerapon Boonkaweenapanon"
date: "2025-04-08"
category: "AWS"
subcategory: ["S3", "CloudFront"]
description: "resource ใน private subnet ที่เชื่อมต่อ internet ไม่ได้ สามารถเข้าถึง DNS resolve ได้ยังไง บทความนี้มีคำตอบครับ"
thumbnail: "https://prpblog.com/assets/how-private-resources-resolve-dns/thumbnail.png"
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

## Route 53 Resolver

Route 53 Resolver ถ้าให้พูดง่าย ๆ ก็คือ DNS resolver ที่ AWS เตรียมเอาไว้ให้ resource ที่อยู่ใน VPC ใช้ครับ ซึ่ง Route 53 Resolver นี้จะอยู่ข้างนอก VPC และไม่สามารถเข้าถึงได้โดยตรง แต่ตอนที่เราสร้าง VPC ขึ้นมา AWS จะมอบ endpoint ที่เอาไว้ใช้ในการเข้าถึง Route 53 Resolver ตัวนี้ให้เราโดยอัตโนมัติ (แต่จริง ๆ เราเลือกว่าจะไม่เอาก็ได้นะ ถ้าอยากใช้ DNS resolver อันอื่นแทน)

ซึ่ง endpoint ที่ว่านี้ก็จะมี IP ของมันอยู่ โดยที่ IP ของ endpoint ก็คือ VPC+2 หรือถ้าอธิบายแบบภาษาคนหน่อยก็คือเอา IP แรกสุดของ CIDR block ของ VPC มา แล้วบวก 2 เข้าไปก็จะได้ IP ของ endpoint ของ VPC นั้น ๆ เช่น ถ้าเรามี VPC ที่มี CIDR block คือ 192.168.0.0/16 IP ของ endpoint ใน VPC นี้ก็จะเป็น 192.168.0.0 + 2 = 192.168.0.2 ครับ ซึ่งด้วยเหตุนี้ ทำให้ Route 53 Resolve มีชื่อเรียกอีกชื่อหนึงว่า ".2 Resolver" ครับ

ตอนนี้ภาพของเราก็จะกลายเป็นประมาณนี้

![03.png](https://prpblog.com/assets/how-private-resources-resolve-dns/03.png)

Flow แบบคร่าว ๆ ก็คือ

1. EC2 อยาก resolve DNS ของ RDS endpoint
2. EC2 ส่ง DNS query ไปที่ Route 53 Resolver ผ่านทาง VPC+2 endpoint
3. Route 53 Resolver ทำการ resolve DNS แล้วส่ง private IP ของ RDS กลับไปให้ EC2
4. EC2 ได้ IP ของ RDS มา EC2 happy

ตัว Route 53 Resolver นี้สามารถทำหน้าที่ได้ไม่ต่างจาก DNS resolver ทั่ว ๆ ไปเลย จึงทำให้ resource ที่อยู่ใน VPC สามารถ resolve DNS ได้โดยไม่จำเป็นต้องเชื่อมต่อ internet เพื่อสื่อสารกับ DNS resolver ที่อยู่ข้างนอก VPC และนอกจากนี้ Route 53 Resolver ยังสามารถ resolve DNS ของ resource อื่น ๆ ใน VPC ที่ไม่สามารถมองเห็นจาก network ภายนอกได้ด้วย ไม่ว่าจะเป็น

- private DNS name ของ EC2 instance หรือ resource อื่น ๆ ใน VPC ที่มี domain name ของ VPC อยู่
- record ที่อยู่ใน Route 53 Private Hosted Zone

แต่ว่า Route 53 Resolver ก็มีข้อจำกัดอยู่ นั่นคือเป็น VPC-specific service ทำให้สามารถใช้งานได้แค่ใน VPC ของตัวเองเท่านั้น ถ้า network ภายนอกต้องการ resolve DNS ของ resource ที่อยู่ใน VPC ก็จำเป็นจะต้องมีการตั้งค่าเพิ่มเติม ซึ่งเดี๋ยวจะพูดถึงในช่วงหลังของบทความนี้ครับ

ด้วยอะไรหลาย ๆ อย่าง ที่เขียนมาด้านบน ผมเลยชอบคิดซะว่าเจ้าตัว endpoint VPC+2 เป็น DNS resolver ส่วนตัวประจำ VPC ของเราไปเลย ก็ทำให้ชีวิตง่ายขึ้นมานิดหน่อยครับ

## ทดสอบดูซักหน่อย

### Private EC2 → Private RDS

ทีนี้เราจะลองมาดูของจริงเทียบกัน ผมมี VPC ที่มี CIDR เป็น 172.31.0.0/16 พร้อมกับ EC2 และ RDS อยู่ใน private subnet ตามภาพด้านบนเอาไว้ครับ

![04.png](https://prpblog.com/assets/how-private-resources-resolve-dns/04.png)

![05.png](https://prpblog.com/assets/how-private-resources-resolve-dns/05.png)

ลอง ping หา google ดูเพื่อยืนยันว่า EC2 ตัวนี้เชื่อมต่อ internet ไม่ได้

![06.png](https://prpblog.com/assets/how-private-resources-resolve-dns/06.png)

และเนื่องจาก ec2 เราเชื่อมต่อ internet ไม่ได้ ผมก็เลยลง MySQL client ไม่ได้ไปด้วยครับ 555 เพราะฉะนั้นเราจะทดสอบโดยการใช้คำสั่ง dig เพื่อ resolve หา IP ของ RDS จาก RDS endpoint แทนครับ

![07.png](https://prpblog.com/assets/how-private-resources-resolve-dns/07.png)

ก็จะเห็นว่าเราสามารถ resolve IP ของ RDS ได้ออกมาเป็น 172.31.48.77 โดย IP ของ DNS resolver ในครั้งนี้คือ 172.31.0.2 หรือก็คือ Route 53 Resolver ที่มี IP เป็น VPC+2 นั่นเองครับ

คราวนี้ผมขอทดสอบอะไรเพิ่มเติมอีกซักหน่อยครับ ตอนแรกผมบอกว่า Route 53 Resolver สามารถ resolve DNS ของ resource ใน VPC "ที่ไม่สามารถมองเห็นจาก network ภายนอกได้" แต่จริง ๆ แล้ว RDS เนี่ย ต่อให้เป็น private ก็ตาม ก็ยังสามารถมองเห็นได้จากภายนอกครับ เพราะฉะนั้นไม่ว่าจะใช้ DNS resolver ของใครก็สามารถ resolve หา IP ของ RDS ตัวนี้ได้หมด

ทดสอบง่าย ๆ ด้วยการลองรันคำสั่งเดียวกันผ่าน WSL ในคอมพิวเตอร์ของผมก็ได้ผลลัพธ์เดียวกันออกมา แต่ IP ของ DNS resolver จะเป็นของ network ของผม 172.23.32.1 แทน

![08.png](https://prpblog.com/assets/how-private-resources-resolve-dns/08.png)

### Public EC2 → Private EC2

รอบนี้ผมจะสร้าง EC2 ขึ้นมาอีกตัวเอาไว้ใน public subnet แล้ว resolve DNS หา IP ของ EC2 ที่อยู่ใน private subnet ตัวเมื่อกี้ครับ

ลอง ping หา google แล้วก็ resolve หา private IP ของ private EC2 ตัวเมื่อกี้ ได้ IP เป็น 172.31.130.80 และ IP ของ DNS resolver ในครั้งนี้คือ 172.31.0.2 เหมือนเดิม

![09.png](https://prpblog.com/assets/how-private-resources-resolve-dns/09.png)

ทีนี้ลองใช้คำสั่งเดิม แต่ระบุ DNS resolver เป็นของ google 8.8.8.8 จะพบว่าหา IP ไม่เจอ

![10.png](https://prpblog.com/assets/how-private-resources-resolve-dns/10.png)

## Cross-Network DNS resolve

อย่างที่เห็นกันไปแล้วครับว่า Route 53 Resolver ช่วยให้ resource ใน VPC สามารถ resolve ได้ทั้ง DNS ที่อยู่บน internet รวมถึง DNS ของ resource ที่อยู่ใน VPC ด้วยกันเอง ที่ DNS resolver ข้างนอก VPC ไม่สามารถ resolve ได้

แล้วถ้าเรามีความจำเป็นต้องใช้ Route 53 Resolver จาก network ภายนอกล่ะ? อันนี้จะยุ่งยากขึ้นมาอีกหน่อยครับ เพราะ network ที่อยู่นอก VPC ไม่สามารถใช้งาน Route 53 Resolver ได้ เนื่องจากตัว VPC+2 endpoint นี้มันอยู่ใน VPC แถมไม่มี public IP ให้เชื่อมด้วย นั่นทำให้เราต้องเล่นท่าอะไรบางอย่างไม่ว่าจะเป็นการใช้ Client VPN, Direct Connect, ฯลฯ เพื่อให้เราสามารถเข้ามาอยู่ใน network เดียวกันกับ VPC ได้ครับ

แต่ !! ถึงแม้เราจะเข้ามาอยู่ใน network เดียวกับ VPC ได้แล้วก็ตาม ตราบใดที่เราไม่ใช่ resource ของ AWS เจ้าตัว VPC+2 endpoint นี่มันก็จะเล่นตัว ไม่ยอมให้เรียกใช้อยู่ดีครับ

ถ้าเราอยากจะเรียกเจ้า endpoint ตัวนี้ เราจำเป็นต้องสร้างสิ่งที่เรียกว่า Route 53 Resolver Inbound Endpoint มาวางคั่นไว้ด้านหน้าอีกทีครับ

โดยตัว Inbound Endpoint นี้จะมี private IP ให้เราเชื่อมต่อได้ และจะทำหน้าที่คอย forward DNS query request ที่เข้ามาไปยัง VPC+2 endpoint ให้เรา ตอนใช้งานเราก็แค่ระบุ DNS resolver เป็น IP ของ Inbound Endpoint เท่านี้ก็พอครับ

![02.png](https://prpblog.com/assets/how-private-resources-resolve-dns/02.png)

จริง ๆ ยังมี Outbound Endpoint อีกนะครับ ตรงส่วนนี้ถ้าอธิบายละเอียดจริง ๆ เนื้อหาจะค่อนข้างเยอะถึงขนาดเขียนเป็นบทความแยกได้เลย เพราะฉะนั้นผมขอจบไว้แค่ตรงนี้ก่อน ไว้มีโอกาสจะลองเขียนบทความเกี่ยวกับ Route 53 Resolver Inbound Endpoint และ Outbound Endpoint เพิ่มเติมครับ

## อ้างอิง

- [What is Amazon Route&nbsp;53 Resolver? - Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html)
