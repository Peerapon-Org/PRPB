"use client";

import { useState, useEffect } from "react";

import { TagFilter } from "@/components/blogs/TagFilter";
import { BlogItem, type BlogItemProps } from "@/components/blogs/BlogItem";

export function BlogList() {
  const [blogs, setBlogs] = useState<BlogItemProps[]>([]);
  useEffect(() => {
    async function fetchBlogs() {
      const response = await fetch("https://dev.prpblog.com/api/blogs", {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });
      const { blogs } = (await response.json()) as { blogs: BlogItemProps[] };
      setBlogs(blogs);
    }
    fetchBlogs();
  }, []);
  // const blogs: BlogItemProps[] = [
  //   {
  //     category: "AWS",
  //     subcategory: "EC2",
  //     publishDate: "2023-10-25",
  //     title: "Elastic Compute Cloud for Scalable Computing",
  //     description: "Learn how to use AWS EC2 for scalable computing.",
  //     slug: "elastic-compute-cloud-for-scalable-computing",
  //     thumbnail: "https://dev.prpblog.com/assets/thumbnail.png",
  //   },
  //   {
  //     category: "DevOps",
  //     subcategory: "Jenkins",
  //     publishDate: "2023-10-24",
  //     title: "Continuous Integration and Delivery with Jenkins",
  //     slug: "continuous-integration-and-delivery-with-jenkins",
  //     thumbnail: "https://dev.prpblog.com/assets/thumbnail.png",
  //   },
  //   {
  //     category: "AWS",
  //     subcategory: "EC2",
  //     publishDate: "2023-10-25",
  //     title: "Elastic Compute Cloud for Scalable Computing",
  //     description: "Learn how to use AWS EC2 for scalable computing.",
  //     slug: "elastic-compute-cloud-for-scalable-computing",
  //     thumbnail: "https://dev.prpblog.com/assets/thumbnail.png",
  //   },
  //   {
  //     category: "DevOps",
  //     subcategory: "Jenkins",
  //     publishDate: "2023-10-24",
  //     title: "Continuous Integration and Delivery with Jenkins",
  //     slug: "continuous-integration-and-delivery-with-jenkins",
  //     thumbnail: "https://dev.prpblog.com/assets/thumbnail.png",
  //   },
  //   {
  //     category: "AWS",
  //     subcategory: "EC2",
  //     publishDate: "2023-10-25",
  //     title: "Elastic Compute Cloud for Scalable Computing",
  //     description: "Learn how to use AWS EC2 for scalable computing.",
  //     slug: "elastic-compute-cloud-for-scalable-computing",
  //     thumbnail: "https://dev.prpblog.com/assets/thumbnail.png",
  //   },
  //   {
  //     category: "DevOps",
  //     subcategory: "Jenkins",
  //     publishDate: "2023-10-24",
  //     title: "Continuous Integration and Delivery with Jenkins",
  //     slug: "continuous-integration-and-delivery-with-jenkins",
  //     thumbnail: "https://dev.prpblog.com/assets/thumbnail.png",
  //   },
  // ];
  return (
    <div className="w-full min-w-[340px] max-w-[1440px] flex flex-col items-center mt-8">
      <TagFilter />
      <div
        className="w-full mt-8 px-4 grid gap-x-6 gap-y-6 justify-center"
        style={{
          gridTemplateColumns: "repeat(auto-fill, minmax(340px, 1fr))",
        }}
      >
        {blogs.map((blog, idx) => (
          <BlogItem key={idx} {...blog} />
        ))}
      </div>
    </div>
  );
}
