---
layout: ../../layouts/BlogLayout.astro
title: "How to use AWS Organization 101"
author: "Peerapon Boonkaweenapanon"
date: "2025-01-18"
category: "AWS"
subcategory: "Organization"
description: "วิธีการใช้งาน AWS Organizaiton สำหรับผู้เริ่มต้น"
thumbnail: "https://prpb-web-bucket.s3.ap-southeast-1.amazonaws.com/thumbnail.png"
---

---

บทความนี้ได้รับการแปลมาจากบทความภาษาญี่ปุ่นที่มีชื่อว่า [AWS 再入門ブログリレー 2022 AWS CodeDeploy 編](https://dev.classmethod.jp/articles/re-introduction-2022-codedeploy/) โดยเจ้าของบทความนี้คือคุณ [masukawa-kentaro](https://dev.classmethod.jp/author/masukawa-kentaro/) ซึ่งเป็นชาวญี่ปุ่น และในบทความนี้จะมีการปรับสำนวนการเขียน รวมถึงมีการเรียบเรียงเนื้อหาใหม่ให้เข้าใจง่ายและมีความเหมาะสมมากยิ่งขึ้น

---

ในบทความนี้เราจะนำเหล่าสมาชิกที่โดยปกติแล้วเขียนแต่บทความเกี่ยวกับเนื้อหาล่าสุดของ AWS แบบละเอียดลงลึก กลับมาเขียนบทความอธิบายเนื้อหาพื้นฐานต่าง ๆ แบบเบสิกกันอีกครั้งครับ

โดยบทความนี้ก็ตามชื่อ สำหรับผู้ที่ตั้งใจจะเรียนเกี่ยวกับ AWS รวมถึงผู้ที่ใช้งาน AWS อยู่แล้ว แต่อยากจะติดตามเนื้อหาหรืออัปเดตใหม่ ๆ ก็อยากจะให้อ่านบทความนี้ไปจนจบเลยครับ

ถ้าอย่างนั้นเราก็มาเริ่มกันเลยครับ โดยหัวข้อในครั้งนี้ คือ「AWS CodeDeploy」

## เกี่ยวกับบทความนี้

บทความนี้จะอธิบาย:

- ในหัวข้อ [AWS CodeDeploy คืออะไร](#aws-codedeploy-%25E0%25B8%2584%25E0%25B8%25B7%25E0%25B8%25AD%25E0%25B8%25AD%25E0%25B8%25B0%25E0%25B9%2584%25E0%25B8%25A3) จะพูดถึงรายละเอียดคร่าว ๆ เกี่ยวกับ CodeDeploy รวมถึงส่วนประกอบหลัก ๆ ใน service นี้
- หัวข้อ [วิธีใช้ CodeDeploy](#%25E0%25B8%25A7%25E0%25B8%25B4%25E0%25B8%2598%25E0%25B8%25B5%25E0%25B9%2583%25E0%25B8%258A%25E0%25B9%2589-codedeploy) จะเป็นการลองสาธิตการใช้ CodeDeploy ในการ deploy application ไปยัง ECS
- หลังจากนั้นจะอธิบาย flow การทำงานของ CodeDeploy แบบคร่าว ๆ ที่หัวข้อ [Lifecycle Event](#lifecycle-event) ครับ

## AWS CodeDeploy คืออะไร

คือ managed service ที่จะช่วย deploy ไฟล์ต่าง ๆ ที่ประกอบขึ้นเป็นแอพพลิเคชันของเรา (artifact) ให้โดยอัตโนมัติครับ  
การใช้ CodeDeploy จะช่วยลด downtime ที่เกิดจากการ deploy ลงไป รวมถึงช่วยให้การทำ rollback หลังจากการ deploy ง่ายขึ้น  
เป็น service ที่ช่วยลดความยุ่งยากในการ deploy ลงไปได้ครับ

[![01](https://devio2024-media.developers.io/image/upload/v1730782505/2024/11/05/mrcle4gpuutkbhffphb2.png)](https://devio2024-media.developers.io/image/upload/v1730782505/2024/11/05/mrcle4gpuutkbhffphb2.png)

## องค์ประกอบต่าง ๆ ของ CodeDeploy

โดยหลัก ๆ แล้ว CodeDeploy จะประกอบไปด้วย 4 ส่วน คือ **Application**, **Deployment**, **Deployment Configuration**, และ **Deploy**

**Application** เป็นเหมือนหน่วยที่เอาไว้ใช้แยกเป้าหมายที่จะ deploy เฉย ๆ ครับ  
ใน **Application** ไม่ได้มีข้อมูลรายละเอียดเกี่ยวกับวิธีการ deploy เก็บบันทึกเอาไว้ จะมีก็แต่ประเภทของเป้าหมายการ deploy เท่านั้น  
ปัจจุบัน CodeDeploy รองรับเป้าหมายการ deploy (compute platform) ทั้งหมด 3 ประเภท

- EC2/On-premises
- AWS Lambda
- Amazon ECS

[![02](https://devio2024-media.developers.io/image/upload/v1730782508/2024/11/05/a4rfma4kmn691mxyay0g.png)](https://devio2024-media.developers.io/image/upload/v1730782508/2024/11/05/a4rfma4kmn691mxyay0g.png)

ภายใน **Application** เราสามารถสร้าง **Deployment Group** หลายอันได้ ซึ่งใน **Deployment Group** แต่ละอันจะมีข้อมูลของ target ที่จะ deploy เก็บไว้อยู่ นอกจากนี้ภายใน **Deployment Group** จะมีการตั้งค่าที่เรียกว่า **Deployment Configurations** ซึ่งใช้สำหรับกำหนดวิธีการสลับ traffic ในตอนที่ทำการ deploy ครับ
ทาง AWS ได้เตรียมการตั้งค่าที่ใช้กันบ่อย ๆ เอาไว้ให้แล้วก็จริง แต่ถ้าอยากปรับแต่งการตั้งค่าแบบละเอียดด้วยตัวเองก็ได้เหมือนกันครับ ภาพรวมคร่าว ๆ ก็คือใน **Deployment Group** 1 อัน เราสามารถทำการ deploy ได้หลายครั้ง โดยใช้ **Deployment Configurations** อันเดิม

ถ้าให้ลองอธิบายเป็นแผนภาพก็น่าจะประมาณด้านล่างนี้ครับ

[![03](https://devio2024-media.developers.io/image/upload/v1730782511/2024/11/05/j09qwz8mloysuxfgq2hu.png)](https://devio2024-media.developers.io/image/upload/v1730782511/2024/11/05/j09qwz8mloysuxfgq2hu.png)

แต่ว่า **Deployment Group** กับ **Deployment Configurations** นั้นจะจัดการแยกกัน ทำให้เราสามารถใช้ **Deployment Configurations** อันเดียวกับ **Deployment Group** หลาย ๆ อันได้ แต่ว่า **Deployment Configurations** จะแตกต่างกันขึ้นอยู่กับ platform ของ target ที่เราจะ deploy (EC2/Lambda/ECS) ครับ
อย่างเช่นในกรณีของ EC2 นั้น deployment type จะมีให้เลือกระหว่าง in-place กับ Blue/Green แต่ถ้าเป็น Lambda หรือ ECS จะมีแต่ Blue/Green อย่างเดียว

[![04](https://devio2024-media.developers.io/image/upload/v1730782514/2024/11/05/znjoqzphede01blggmd8.png)](https://devio2024-media.developers.io/image/upload/v1730782514/2024/11/05/znjoqzphede01blggmd8.png)

※ สำหรับ ECS ถ้าเราใช้ CodePipeline เราสามารถตั้งค่าการ deploy เป็นแบบ rolling update ได้ แต่อันนั้นจะเป็นการ deploy โดยใช้ฟังก์ชันของ ECS เอง ไม่ใช่ CodeDeploy ครับ
ถ้าสร้าง ECS Task จากหน้า console ก็ไม่มีอะไรต้องคิดมาก แต่ถ้าใช้ CloudFormation ก็จำเป็นจะต้องคิดถึงจุด ๆ นี้ไว้ด้วยครับ

## วิธีใช้ CodeDeploy

วิธีการใช้ CodeDeploy ในการ deploy resource จะแตกต่างกันอย่างมากขึ้นอยู่กับ platform ที่จะ deploy
tutorial ด้านล่างที่ AWS เตรียมเอาไว้ให้นี้ถือว่าครอบคลุมและช่วยได้มากเลยครับ

https://docs.aws.amazon.com/codedeploy/latest/userguide/tutorials.html

สำหรับในบทความนี้จะลองใช้ CodeDeploy กับ ECS ดูครับ

## ลองทำดู

สำหรับครั้งนี้เราจะใช้ CodeDeploy ทำการ deploy แบบ Blue/Green ไปยัง ECS ครับ

โดยก่อนอื่นเราจะต้องมี application ตั้งต้นก่อน
โดยเราจะเริ่มจากการสร้าง resource ที่จะเป็น คือ CodeDeploy service role, ECS cluster และ ECS service ครับ

### สร้าง Resources

#### CodeDeploy Service Role

ไปที่หน้า console ของ IAM เลือกเมนู Roles จากแถบเมนูด้านซ้าย จากนั้นคลิกที่ Create role

[![08](https://devio2024-media.developers.io/image/upload/v1730782523/2024/11/05/klbqfyeorwgkadkv2ysi.png)](https://devio2024-media.developers.io/image/upload/v1730782523/2024/11/05/klbqfyeorwgkadkv2ysi.png)

เลือก trusted entity type เป็น `AWS service` ส่วน use case เป็น `CodeDeploy` - `CodeDeploy - ECS` แล้วคลิก `Next`

[![09](https://devio2024-media.developers.io/image/upload/v1730782526/2024/11/05/y7vsi4dzq2fi3ya903qt.png)](https://devio2024-media.developers.io/image/upload/v1730782526/2024/11/05/y7vsi4dzq2fi3ya903qt.png)

ตั้งชื่อ role (ตัวอย่างเช่น codedeploy-ecs-service-role) เลื่อนลงไปด้านล่างสุดแล้วคลิก `Create role` เพื่อสร้าง role

[![10](https://devio2024-media.developers.io/image/upload/v1730782530/2024/11/05/tkkateoh4m9qwygk3aea.png)](https://devio2024-media.developers.io/image/upload/v1730782530/2024/11/05/tkkateoh4m9qwygk3aea.png)

#### ECS Task Definition

ไปที่หน้า console ของ ECS เลือกเมนู `Task definitions` จากแถบเมนูด้านซ้าย จากนั้นคลิกที่ `Create new task definition`

[![10-1](https://devio2024-media.developers.io/image/upload/v1730782533/2024/11/05/lzhq0x5m7vrd2djye4kj.png)](https://devio2024-media.developers.io/image/upload/v1730782533/2024/11/05/lzhq0x5m7vrd2djye4kj.png)

ตั้งชื่อ task definition (ตัวอย่างเช่น codedeploy-ecs-task-def) ส่วนการตั้งค่าอื่นให้ปล่อยเป็นค่า default

[![10-2](https://devio2024-media.developers.io/image/upload/v1730782536/2024/11/05/qccw2a6zm7ryz2piyvpk.png)](https://devio2024-media.developers.io/image/upload/v1730782536/2024/11/05/qccw2a6zm7ryz2piyvpk.png)

ส่วน execution role เราใช้ role `ecsTaskExecutionRole` ซึ่งเป็น default role สำหรับใช้งาน ECS ครับ โดยปกติแล้ว role นี้จะมีอยู่ใน account อยู่แล้ว แต่ถ้าหา role นี้ไม่เจอเราก็สามารถสร้างเองได้ โดย role `ecsTaskExecutionRole` มี permission ที่จำเป็นแค่สองอันคือ `AmazonECSTaskExecutionRolePolicy` กับ `CloudWatchLogsFullAccess`

[![10-3](https://devio2024-media.developers.io/image/upload/v1730782539/2024/11/05/w16lexwhefctkzlnvo4m.png)](https://devio2024-media.developers.io/image/upload/v1730782539/2024/11/05/w16lexwhefctkzlnvo4m.png)

[![10-4](https://devio2024-media.developers.io/image/upload/v1730782542/2024/11/05/xv3sldcbounrky44sniy.png)](https://devio2024-media.developers.io/image/upload/v1730782542/2024/11/05/xv3sldcbounrky44sniy.png)

ในส่วนของ container ให้ตั้งชื่อ container และเลือก image ที่จะใช้ ในครั้งนี้ผมเลือกใช้ [nginx image](https://gallery.ecr.aws/nginx/nginx) ที่ทาง AWS เตรียมไว้ให้ครับ เพราะฉะนั้นการตั้งค่าจะเป็นไปตามด้านล่างนี้

- Name: nginx
- Image URI: public.ecr.aws/nginx/nginx:stable-perl

ส่วนการตั้งค่าเหลือใช้ค่า default แล้วเลื่อนลงมาด้านล่างสุด คลิก `Create` เพื่อสร้าง task definition

[![10-5](https://devio2024-media.developers.io/image/upload/v1730782546/2024/11/05/xoi37sdomvnbyjejw3ev.png)](https://devio2024-media.developers.io/image/upload/v1730782546/2024/11/05/xoi37sdomvnbyjejw3ev.png)

#### ECS Cluster

ไปที่หน้า console ของ ECS เลือกเมนู `Clusters` จากแถบเมนูด้านซ้าย จากนั้นคลิกที่ `Create cluster`

[![11](https://devio2024-media.developers.io/image/upload/v1730782549/2024/11/05/spftm0dcmxedabmsrfx8.png)](https://devio2024-media.developers.io/image/upload/v1730782549/2024/11/05/spftm0dcmxedabmsrfx8.png)

ตั้งชื่อ cluster (ตัวอย่างเช่น codedeploy-test-cluster) เลือก infrastructure เป็น AWS Fargate (serverless) จากนั้นเลื่อนลงไปด้านล่างสุดแล้วคลิก `Create` เพื่อสร้าง cluster

[![12](https://devio2024-media.developers.io/image/upload/v1730782552/2024/11/05/cm6memwbmiszxdyyux21.png)](https://devio2024-media.developers.io/image/upload/v1730782552/2024/11/05/cm6memwbmiszxdyyux21.png)

รอซักครู่ ก็จะเห็น cluster ที่เราสร้างปรากฎขึ้นบนหน้า console

[![13](https://devio2024-media.developers.io/image/upload/v1730782556/2024/11/05/inysdzzi5pn414zobij5.png)](https://devio2024-media.developers.io/image/upload/v1730782556/2024/11/05/inysdzzi5pn414zobij5.png)

#### ECS Service

ไปที่หน้า console ของ cluster ที่เราสร้างไว้ก่อนหน้า ที่บริเวณแถบ Service ด้านล่าง คลิกที่ `Create`

[![14](https://devio2024-media.developers.io/image/upload/v1730782559/2024/11/05/q2grlohfcwzujc35njsb.png)](https://devio2024-media.developers.io/image/upload/v1730782559/2024/11/05/q2grlohfcwzujc35njsb.png)

ในส่วนของ Environment ตั้งค่าตามด้านล่างนี้

- Compute options: Launch type
- Launch type: FARGATE
- Platform version: LATEST

[![15](https://devio2024-media.developers.io/image/upload/v1730782562/2024/11/05/fb6y817qyfbn9odkohoa.png)](https://devio2024-media.developers.io/image/upload/v1730782562/2024/11/05/fb6y817qyfbn9odkohoa.png)

ในส่วนของ Deployment configuration ตั้งค่าตามด้านล่างนี้

- Application type: Service
- Task definition: เลือก task definition ที่สร้างไว้ก่อนหน้านี้
- Service name: ตั้งชื่อ service (ตัวอย่างเช่น codedeploy-ecs-test-service)
- Desired tasks: กำหนดจำนวน task
- Deployment type: Blue/Green deployment (powered by AWS CodeDeploy)
- Deployment configuration: เลือกวิธีการ deploy (อธิบายเพิ่มเติมด้านล่าง)
- Service role for CodeDeploy: เลือก service role ที่สร้างไว้ก่อนหน้านี้

[![16](https://devio2024-media.developers.io/image/upload/v1730782565/2024/11/05/vak8qm8svhr7h0fnvpbp.png)](https://devio2024-media.developers.io/image/upload/v1730782565/2024/11/05/vak8qm8svhr7h0fnvpbp.png)

deployment configuration คือการตั้งค่าที่กำหนดว่า CodeDeploy ควรจะสลับ traffic ผู้ใช้งานจาก blue environment ไปยัง green environment อย่างไรโดย AWS ได้เตรียม deployment configuration สำหรับ ECS เอาไว้ให้ตามด้านล่างนี้

CodeDeployDefault.ECSLinear10PercentEvery1Minutes
สลับ traffic ครั้งละ 10% ทุก ๆ 1 นาที จนกว่า traffic ทั้งหมดจะถูกสลับไปยัง green environment

CodeDeployDefault.ECSLinear10PercentEvery3Minutes
สลับ traffic ครั้งละ 10% ทุก ๆ 3 นาที จนกว่า traffic ทั้งหมดจะถูกสลับไปยัง green environment

CodeDeployDefault.ECSCanary10Percent5Minutes
สลับ traffic 10% แรกไปยัง green environment หลังจากผ่านไป 5 นาทีจึงสลับ traffic อีก 90% ที่เหลือตามไป

CodeDeployDefault.ECSCanary10Percent15Minutes
สลับ traffic 10% แรกไปยัง green environment หลังจากผ่านไป 15 นาทีจึงสลับ traffic อีก 90% ที่เหลือตามไป

CodeDeployDefault.ECSAllAtOnce
สลับ traffic ทั้งหมดไปยัง green environment ในคราวเดียว

นอกจากนี้เรายังสามารถสร้าง custom deployment configuration เอง เพื่อตอบโจทย์การใช้งานหนึ่ง ๆ โดยเฉพาะก็ได้เหมือนกันครับ

ในส่วนของ Networking เลือก VPC, Subnet, และ Security group ที่ต้องการ โดยมีเงื่อนไขต่อไปนี้

- subnet ทั้งหมดเป็น public subnet
- security group ต้องอนุญาต traffic จาก port 80
- เปิดใช้ Public IP

[![17](https://devio2024-media.developers.io/image/upload/v1730782570/2024/11/05/fw45isztmm0cssqj4xuq.png)](https://devio2024-media.developers.io/image/upload/v1730782570/2024/11/05/fw45isztmm0cssqj4xuq.png)

[![18](https://devio2024-media.developers.io/image/upload/v1730782573/2024/11/05/kdfasw7z9xfldwo45eo4.png)](https://devio2024-media.developers.io/image/upload/v1730782573/2024/11/05/kdfasw7z9xfldwo45eo4.png)

ในส่วนของ Load balancing ตั้งค่าตามด้านล่างนี้

- Load balancer type: Application Load Balancer
- Application Load Balancer: Create a new load balancer
- Load balancer name: ตั้งชื่อ load balancer (ตัวอย่างเช่น codedeploy-ecs-test-alb)
- Health check grace period: 30
- Listeners: เลือก Create new listener แล้วใช้ค่า default (port 80/HTTP)
- Target groups: เลือก Create new target group แล้วใช้ค่า default ทั้ง 2 target group

[![19](https://devio2024-media.developers.io/image/upload/v1730782576/2024/11/05/rese8dllqlahzxbzgccm.png)](https://devio2024-media.developers.io/image/upload/v1730782576/2024/11/05/rese8dllqlahzxbzgccm.png)

[![20](https://devio2024-media.developers.io/image/upload/v1730782580/2024/11/05/q9iev2u3h0hoihcb1z0y.png)](https://devio2024-media.developers.io/image/upload/v1730782580/2024/11/05/q9iev2u3h0hoihcb1z0y.png)

จากนั้นเลื่อนลงมาด้านล่างสุดแล้วคลิก `Create` เพื่อสร้าง service

รอซักครู่จะเห็น service ที่เราสร้างไว้ปรากฏขึ้นมาบนหน้า console ให้คลิกเข้าไปที่ service ดังกล่าว

[![21](https://devio2024-media.developers.io/image/upload/v1730782584/2024/11/05/pz1fevdfecbpxjrftble.png)](https://devio2024-media.developers.io/image/upload/v1730782584/2024/11/05/pz1fevdfecbpxjrftble.png)

จากนั้นไปที่แถบ `Configuration and networking` หา DNS names ที่บริเวณเมนู Network configuration ด้านล่าง จากนั้นลองคลิกที่ `open address` เพื่อเปิดหน้าเว็บไซต์ของเราดู

[![22](https://devio2024-media.developers.io/image/upload/v1730782587/2024/11/05/f1jfnew9qyq0j0xi1yoh.png)](https://devio2024-media.developers.io/image/upload/v1730782587/2024/11/05/f1jfnew9qyq0j0xi1yoh.png)

ถ้าทุกอย่างไม่มีปัญหา เราจะเห็นหน้าเว็บ nginx ปรากฏขึ้น

[![23](https://devio2024-media.developers.io/image/upload/v1730782590/2024/11/05/mcjljschckerhgmkjfw3.png)](https://devio2024-media.developers.io/image/upload/v1730782590/2024/11/05/mcjljschckerhgmkjfw3.png)

### เตรียมไฟล์

หลังจากที่เรามี application ตั้งต้นแล้ว ต่อมาเราจะเริ่ม deploy application เวอร์ชันใหม่เข้าไปแทนที่ application เดิมครับ

โดยในการ deploy เราจำเป็นต้องมีไฟล์ **appspec.yaml** ก่อน

ไฟล์ **appspec.yaml** คือไฟล์ที่กำหนดการตั้งค่าของการ deploy (Deployment Configuration) เอาไว้ครับ

สำหรับไฟล์ **appspec.yaml** ที่เราใช้ในครั้งนี้มีหน้าตาประมาณนี้
ซึ่ง version คือเวอร์ชันของ AppSpec
ณ ปัจจุบัน (2024/10) AppSpec มีแค่เวอร์ชันเดียวคือ 0.0 ครับ

```yaml
version: 0.0
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: <TASK_DEFINITION>
        LoadBalancerInfo:
          ContainerName: "ecs-sample-app"
          ContainerPort: 80
        PlatformVersion: LATEST
```

ตรง **<TASK_DEFINITION>** เราจะเอา ARN ของ task definition อีกอัน ซึ่งเป็น task definition ของ application เวอร์ชันใหม่มาใส่ครับ ซึ่งหมายความว่าเราจำเป็นต้องสร้าง task definition เพิ่มอีก 1 อัน

ในการใช้งานจริง การที่ต้องเข้าไปสร้าง task definition ใน console เองทุกครั้งก่อนเริ่มการ deploy คงไม่ใช่วิธีที่ดีนัก เพราะฉะนั้นครั้งนี้เราจะสร้าง task definition โดยใช้ AWS CLI และไฟล์ JSON ครับ

สำหรับท่านใดที่ไม่รู้จัก AWS CLI สามารถศึกษาเพิ่มเติมได้จากบทความนี้ครับ

https://dev.classmethod.jp/articles/what-is-aws-cli-how-to-use-aws-cli-for-beginners/

ก่อนอื่นให้สร้างไฟล์ชื่อ taskdef.json ที่มีเนื้อหาตามด้านล่างนี้ แล้ว save เก็บไว้ที่ไหนซักที่หนึ่ง

**_Note:_** &nbsp;ให้เปลี่ยน **<REGION>** และ **<ACCOUNT_ID>** ด้วย region และ AWS Account ID ที่ใช้งานอยู่ ตัวอย่างเช่น หากใช้งานใน Singapore region ให้เปลี่ยน **<REGION>** เป็น ap-southeast-1 เป็นต้น

```json
{
  "containerDefinitions": [
    {
      "name": "ecs-sample-app",
      "image": "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest",
      "cpu": 0,
      "portMappings": [
        {
          "name": "ecs-sample-app-80-tcp",
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp",
          "appProtocol": "http"
        }
      ],
      "essential": true,
      "environment": [],
      "environmentFiles": [],
      "mountPoints": [],
      "volumesFrom": [],
      "ulimits": [],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/codedeploy-test-new-task-def",
          "mode": "non-blocking",
          "awslogs-create-group": "true",
          "max-buffer-size": "25m",
          "awslogs-region": "<REGION>",
          "awslogs-stream-prefix": "ecs"
        },
        "secretOptions": []
      },
      "systemControls": []
    }
  ],
  "family": "codedeploy-test-new-task-def",
  "executionRoleArn": "arn:aws:iam::<ACCOUNT_ID>:role/ecsTaskExecutionRole",
  "networkMode": "awsvpc",
  "volumes": [],
  "placementConstraints": [],
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "3072",
  "runtimePlatform": {
    "cpuArchitecture": "X86_64",
    "operatingSystemFamily": "LINUX"
  },
  "tags": [
    {
      "key": "Name",
      "value": "codedeploy-test-new-task-def"
    }
  ]
}
```

จากนั้น run คำสั่งด้านล่างด้วย AWS CLI

**_Note:_** &nbsp;ให้เปลี่ยน **<PATH_TO_taskdef.json_FILE>** และ **<REGION>** ด้วย path ไปยังไฟล์ taskdef.json และ region ที่ใช้งานอยู่

**_Note2:_** &nbsp;เพื่อความง่าย ในครั้งนี้ผมจะใช้ policy `AmazonECS_FullAccess` ในการ run คำสั่ง CLI นี้ครับ

```bash
aws ecs register-task-definition --cli-input-json file://<PATH_TO_taskdef.json_FILE>/taskdef.json --region <REGION>
```

หลังจาก run คำสั่งแล้ว จะได้ผลลัพธ์ออกมาตามภาพด้านล่าง ให้ copy `taskDefinitionArn` ไปใส่ไว้ที่ <TASK_DEFINITION> ในไฟล์ appspec.yml

[![24](https://devio2024-media.developers.io/image/upload/v1730782593/2024/11/05/qalb7ssjmgtfriszkt9m.png)](https://devio2024-media.developers.io/image/upload/v1730782593/2024/11/05/qalb7ssjmgtfriszkt9m.png)

task definition อันใหม่นี้จะ deploy container ชื่อ ecs-sample-app ที่สร้างมาจาก [ECS sample image](https://gallery.ecr.aws/ecs-sample-image/amazon-ecs-sample) ที่ทาง AWS เตรียมไว้ให้ครับ

หลังจากเตรียมไฟล์เสร็จแล้ว ให้ไปที่หน้า console ของ CodeDeploy เลือกเมนู `Applications` จากแถบเมนูด้านซ้าย เราจะเห็นว่ามี application อันหนึ่งถูกสร้างเอาไว้อยู่แล้ว application อันนี้คือ application ที่ ECS สร้างมาให้ ตอนที่เราสร้าง ECS service และเลือก Deployment type เป็น Blue/Green deployment (powered by AWS CodeDeploy) ครับ

จริง ๆ แล้วเราจะ deploy โดยใช้ application อันนี้เลยก็ได้ แต่ในครั้งนี้ผมจะลบ application อันนี้ทิ้งแล้วสร้าง CodeDeploy Application ขึ้นมาใหม่ เพราะถ้าไม่อย่างนั้นบทความนี้จะกลายเป็นบทความเกี่ยวกับ ECS ไปแทนครับ สำหรับท่านใดที่อยากรีบ deploy เร็ว ๆ สามารถข้ามไปดูในส่วนของ [Deploy Application](#deploy-application) ได้เลยครับ

สำหรับวิธีการลบ Application นั้น มีขั้นตอนตามนี้

ไปที่หน้า console ของ CodeDeploy เลือกเมนู `Applications` จะเห็นว่ามี application ถูกสร้างเอาไว้อยู่ ซึ่งนี่คือ application ที่ ECS สร้างขึ้นมาครับ ให้คลิกเข้าไปที่ application ดังกล่าว

[![101](https://devio2024-media.developers.io/image/upload/v1731408045/2024/11/12/a9htkpv9eupathhfvffk.png)](https://devio2024-media.developers.io/image/upload/v1731408045/2024/11/12/a9htkpv9eupathhfvffk.png)

คลิกที่ `Delete applications` ที่มุมบนขวาเพื่อลบ application

[![102](https://devio2024-media.developers.io/image/upload/v1731408048/2024/11/12/zcdjpm2dhcu1hx2cewli.png)](https://devio2024-media.developers.io/image/upload/v1731408048/2024/11/12/zcdjpm2dhcu1hx2cewli.png)

### สร้าง CodeDeploy Resources

#### CodeDeploy Application

ไปที่หน้า console ของ CodeDeploy เลือกเมนู `Applications` จากแถบเมนูด้านซ้าย จากนั้นคลิกที่ `Create applications`

[![25](https://devio2024-media.developers.io/image/upload/v1730782596/2024/11/05/yynthwpdrjoyk4kqhhx0.png)](https://devio2024-media.developers.io/image/upload/v1730782596/2024/11/05/yynthwpdrjoyk4kqhhx0.png)

ตั้งชื่อ application (ตัวอย่างเช่น codedeploy-ecs-application) แล้วเลือก compute platform เป็น Amazon ECS จากนั้นคลิก `Create application` เพื่อสร้าง application

[![26](https://devio2024-media.developers.io/image/upload/v1730782598/2024/11/05/e7nzg5saesutzn1hhkr2.png)](https://devio2024-media.developers.io/image/upload/v1730782598/2024/11/05/e7nzg5saesutzn1hhkr2.png)

รอซักครู่ ก็จะเห็น application ที่เราสร้างปรากฎขึ้นบนหน้า console

[![27](https://devio2024-media.developers.io/image/upload/v1730782601/2024/11/05/jrrvzua20mygekvh5c4u.png)](https://devio2024-media.developers.io/image/upload/v1730782601/2024/11/05/jrrvzua20mygekvh5c4u.png)

[![28](https://devio2024-media.developers.io/image/upload/v1730782604/2024/11/05/gtf6fcrrshmkj6eqghsi.png)](https://devio2024-media.developers.io/image/upload/v1730782604/2024/11/05/gtf6fcrrshmkj6eqghsi.png)

#### Deployment Group

เข้าไปที่ application ที่สร้างขึ้นเมื่อครู่ แล้วคลิกที่ `Create deployment group`

[![30](https://devio2024-media.developers.io/image/upload/v1730782607/2024/11/05/ksnykdninbgsaqctgi3p.png)](https://devio2024-media.developers.io/image/upload/v1730782607/2024/11/05/ksnykdninbgsaqctgi3p.png)

ตั้งชื่อ deployment group (ตัวอย่างเช่น codedeploy-ecs-deployment-group) แล้วเลือก service role เป็น service role ของ CodeDeploy ที่สร้างไว้ก่อนหน้านี้

[![31](https://devio2024-media.developers.io/image/upload/v1730782610/2024/11/05/ndwiyenfhmyocv9bgmwm.png)](https://devio2024-media.developers.io/image/upload/v1730782610/2024/11/05/ndwiyenfhmyocv9bgmwm.png)

เลือก ECS cluster, service, load balancer, target group ทั้ง 2 อัน

[![32](https://devio2024-media.developers.io/image/upload/v1730782613/2024/11/05/c6h4zjnndatyivzeqmtk.png)](https://devio2024-media.developers.io/image/upload/v1730782613/2024/11/05/c6h4zjnndatyivzeqmtk.png)

เลือก deployment configuration จากนั้นในส่วนของ Original revision termination คือการตั้งเวลาว่าจะให้ CodeDeploy ทำการลบ origin task set หลังจาก deploy เสร็จแล้วกี่นาที/ชั่วโมง/วัน
หลังจากตั้งค่าทุกอย่างเรียบร้อยแล้วให้คลิก `Create deployment group` เพื่อสร้าง deployment group

[![33](https://devio2024-media.developers.io/image/upload/v1730782617/2024/11/05/zu7vsznhtbchxysi953w.png)](https://devio2024-media.developers.io/image/upload/v1730782617/2024/11/05/zu7vsznhtbchxysi953w.png)

### Deploy Application

ไปที่หน้า console ของ CodeDeploy เลือกเมนู `Applications` จากแถบเมนูด้านซ้าย จากนั้นเลือก application และ deployment group ที่ต้องการ จากนั้นคลิกที่ `Create deployment`

[![34](https://devio2024-media.developers.io/image/upload/v1730782621/2024/11/05/c3snwz7knnlifg9jp5hd.png)](https://devio2024-media.developers.io/image/upload/v1730782621/2024/11/05/c3snwz7knnlifg9jp5hd.png)

[![35](https://devio2024-media.developers.io/image/upload/v1730782624/2024/11/05/at1ejw6yntxoqycrmknr.png)](https://devio2024-media.developers.io/image/upload/v1730782624/2024/11/05/at1ejw6yntxoqycrmknr.png)

[![36](https://devio2024-media.developers.io/image/upload/v1730782627/2024/11/05/lxuqpkv4thstigko4i6j.png)](https://devio2024-media.developers.io/image/upload/v1730782627/2024/11/05/lxuqpkv4thstigko4i6j.png)

ที่ Revision type คือที่ที่เราจะใส่ไฟล์ **appspec.yaml** เข้าไปครับ เราสามารถให้ CodeDeploy ไปดึงไฟล์มาจาก S3 bucket ก็ได้ แต่ในครั้งนี้เราจะใส่เนื้อหาในไฟล์เข้าไปใน CodeDeploy ตรง ๆ ครับ

ให้เลือก `Use AppSpec editor` เลือก `AppSpec language` เป็น YAML จากนั้น copy เนื้อหาในไฟล์ **appspec.yaml** ใส่เข้าไป

[![37](https://devio2024-media.developers.io/image/upload/v1730782630/2024/11/05/u2xxilj2f7tdtv1wn8gf.png)](https://devio2024-media.developers.io/image/upload/v1730782630/2024/11/05/u2xxilj2f7tdtv1wn8gf.png)

จากนั้นเลื่อนไปด้านล่างสุดแล้วคลิก Create deployment เพื่อเริ่ม deploy application แล้วนั่งรอชมความสำเร็จได้เลยครับ

[![38](https://devio2024-media.developers.io/image/upload/v1730782633/2024/11/05/g0rrgmfxdwcx7anp2t0m.png)](https://devio2024-media.developers.io/image/upload/v1730782633/2024/11/05/g0rrgmfxdwcx7anp2t0m.png)

จะเห็นว่าที่ฝั่ง ECS service มีการ deploy เกิดขึ้น

[![39](https://devio2024-media.developers.io/image/upload/v1730782637/2024/11/05/v09ywbpug6qo71lmlzfg.png)](https://devio2024-media.developers.io/image/upload/v1730782637/2024/11/05/v09ywbpug6qo71lmlzfg.png)

หลังจาก deploy เสร็จแล้ว CodeDeploy จะรอ 1 ชั่วโมงตามเวลาที่เราตั้งไว้ หลังจากนั้นจึงจะลบ origin task set ทิ้ง ซึ่งถ้าเราไม่อยากรอ เราสามารถคลิกที่ `Terminate original task set` มุมบนขวา เพื่อลบ origin task set ทันที

[![40](https://devio2024-media.developers.io/image/upload/v1730782639/2024/11/05/q9jj0sapydde7mzgif6b.png)](https://devio2024-media.developers.io/image/upload/v1730782639/2024/11/05/q9jj0sapydde7mzgif6b.png)

ก่อนลบ origin task set ที่ service ของเราจะมี task ทั้งหมด 4 task (origin task set 2 และ new task set อีก 2)

[![41](https://devio2024-media.developers.io/image/upload/v1730782642/2024/11/05/tfr1icza9302zmy1ppnt.png)](https://devio2024-media.developers.io/image/upload/v1730782642/2024/11/05/tfr1icza9302zmy1ppnt.png)

หลังลบ origin task set ที่ service ของเราจะมี task แค่ 2 task ที่เป็น new task set เท่านั้น

[![42](https://devio2024-media.developers.io/image/upload/v1730782645/2024/11/05/motri0pisttvwinh9tw7.png)](https://devio2024-media.developers.io/image/upload/v1730782645/2024/11/05/motri0pisttvwinh9tw7.png)

และเมื่อเปิดลิงก์เพื่อเช็ค application ก็จะพบว่า application ของเราเปลี่ยนจาก nginx เป็น ECS sample app เรียบร้อยแล้ว

[![43](https://devio2024-media.developers.io/image/upload/v1730782648/2024/11/05/pnkwsgamirja3pop1d1e.png)](https://devio2024-media.developers.io/image/upload/v1730782648/2024/11/05/pnkwsgamirja3pop1d1e.png)

## Lifecycle Event

เมื่อ CodeDeploy เริ่มการ deploy ขึ้น lifecycle event จะถูกรันตามลำดับ
โดยในกรณีของ ECS lifecycle event จะเป็นไปตามรูปด้านล่างนี้ครับ

[![44](https://devio2024-media.developers.io/image/upload/v1730782650/2024/11/05/dwfu4dopbbr662jadsmm.png)](https://devio2024-media.developers.io/image/upload/v1730782650/2024/11/05/dwfu4dopbbr662jadsmm.png)

โดยในแต่ละ lifecycle event เราสามารถรัน Lambda function ได้
ในรูปด้านบน เราสามารถรัน Lambda function ได้เมื่อ lifecycle event เดินทางมาถึง event ในสี่เหลียมสีฟ้า ซึ่งแต่ละ event มีความหมายดังนี้

> BeforeInstall – Use to run tasks before the replacement task set is created. One target group is associated with the original task set. If an optional test listener is specified, it is associated with the original task set. A rollback is not possible at this point.<br>
> AfterInstall – Use to run tasks after the replacement task set is created and one of the target groups is associated with it. If an optional test listener is specified, it is associated with the original task set. The results of a hook function at this lifecycle event can trigger a rollback.<br>
> AfterAllowTestTraffic – Use to run tasks after the test listener serves traffic to the replacement task set. The results of a hook function at this point can trigger a rollback.<br>
> BeforeAllowTraffic – Use to run tasks after the second target group is associated with the replacement task set, but before traffic is shifted to the replacement task set. The results of a hook function at this lifecycle event can trigger a rollback.<br>
> AfterAllowTraffic – Use to run tasks after the second target group serves traffic to the replacement task set. The results of a hook function at this lifecycle event can trigger a rollback.

ซึ่ง lifecycle event ของ EC2/On-prem, Lambda, ECS จะแตกต่างกันไป แต่ฟังก์ชันการใช่งาน (เรียก Lambda hook function) จะเหมือนกันครับ
เราสามารถ hook event แล้วรัน Lambda function เพื่อรัน test หรือหยุด Auto Scaling Group ชั่วคราวก็ได้
โดยถึงแม้การใช้งานฟังก์ชันนี้มีความจำเป็นจะต้องสร้าง Lambda function แยกต่างหากก่อน แต่ก็ทำให้เราสามารถจัดการการ deploy ได้อย่างยืดหยุ่นมากขึ้น แถมวิธีการใช้งานฟังก์ชันนี้ก็ง่ายมาก แค่ใส่ ARN ของ Lambda function ที่ต้องการเรียกลงไปในไฟล์ appspec.yaml ในส่วนของ Hooks ก็เรียบร้อยครับ

```yaml
Hooks:
  - AfterAllowTestTraffic: "arn:aws:lambda:aws-region-id:aws-account-id:function:AfterAllowTestTraffic"
```

## การใช้ Auto Scaling ร่วมกับ ECS Blue/Green Deployment

การใช้ Auto Scaling ร่วมกับ ECS Blue/Green Deployment จำเป็นต้องคำนึงถึงเหตุการณ์ด้านล่างนี้ด้วยครับ

> If a service is scaling and a deployment starts, the green task set is created and CodeDeploy will wait up to an hour for the green task set to reach steady state and won't shift any traffic until it does.<br>
> If a service is in the process of a blue/green deployment and a scaling event occurs, traffic will continue to shift for 5 minutes. If the service doesn't reach steady state within 5 minutes, CodeDeploy will stop the deployment and mark it as failed.

เนื่องจากเราสามารถกำหนดให้ Auto Scaling เป็น deployment target ได้ จึงจะมีบางกรณีที่ Auto Scaling เป็นต้นเหตุทำให้การ deploy ล้มเหลวอยู่ครับ
จริง ๆ ถึงแม้ deployment จะล้มเหลว แค่ deploy ใหม่ก็พอ แต่การปิด Auto Scaling ชั่วคราวเพื่อลดโอกาสที่การ deploy จะล้มเหลวลงก็เป็นความคิดที่ดีเหมือนกันครับ
เช่นการใช้ lifecycle hook BeforeInstall เพื่อเรียก Lambda function ให้หยุด Auto Scaling แล้วใช้ BeforeInstall hook เพื่อเปิด Auto Scaling ต่อ ถือเป็นวิธีที่ทำได้จริงและง่ายด้วยครับ

## สุดท้ายนี้

สำหรับบทความ [AWS CodeDeploy คืออะไร? แนะนำฟังก์ชันของ AWS สำหรับผู้เริ่มต้นใช้งาน] ก็จบลงแต่เพียงเท่านี้ครับ
เพราะวิธีการใช้งาน service นี้จะเปลี่ยนไปมาก เมื่อเปลี่ยน deployment target ทำให้มีเรื่องต้องจำเยอะมาก ก็ได้แต่หวังว่าบทความนี้จะเป็นประโยชน์กับผู้ที่สนใจใน service นี้อยู่ไม่มากก็น้อยครับ

## อ้างอิง

1. [AWS 再入門ブログリレー 2022 AWS CodeDeploy 編](https://dev.classmethod.jp/articles/re-introduction-2022-codedeploy/) (บทความต้นฉบับ)
2. [PowerPoint Presentation](https://d1.awsstatic.com/webinars/jp/pdf/services/20210126_BlackBelt_CodeDeploy.pdf) (ภาษาญี่ปุ่น)
3. [AppSpec 'hooks' section - AWS CodeDeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html)
