"use client";

import { useState, useEffect } from "react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const FormSchema = z.object({
  category: z.string(),
  subCategory: z.string(),
});

type Categories = string[];
type SubCategories = {
  [K in Categories[number]]: string[];
};

export type Tags = {
  category: Categories;
  subCategory: SubCategories;
};

export type Blog = {
  category: Categories[number];
  subCategory: SubCategories[Categories[number]];
  publishDate: string;
  slug: string;
};

export function SelectForm() {
  const [tags, setTags] = useState<Tags>();
  const [category, setCategory] = useState<Categories[number] | null>(null);
  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
  });

  async function onSubmit(data: z.infer<typeof FormSchema>) {
    console.log(data);
  }

  useEffect(() => {
    async function fetchTags() {
      const response = await fetch("https://dev.prpblog.com/api/tags", {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
        },
      });
      const { category, subCategory } = (await response.json()) as Tags;
      setTags({ category, subCategory });
    }
    fetchTags();
  }, []);

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="w-full flex flex-col sm:flex-row justify-center items-center"
      >
        <FormField
          control={form.control}
          name="category"
          render={({ field }) => (
            <FormItem className="w-5/6 mb-4 sm:w-1/3 sm:mb-0 sm:mr-4">
              {/* <FormLabel>Email</FormLabel> */}
              <Select
                onValueChange={(value) => {
                  field.onChange(value);
                  setCategory(value);
                }}
                defaultValue={field.value}
              >
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Category" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  {tags?.category.map((category) => (
                    <SelectItem key={category} value={category}>
                      {category}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              {/* <FormDescription>
                You can manage email addresses in your{" "}
                <Link href="/examples/forms">email settings</Link>.
              </FormDescription> */}
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="subCategory"
          render={({ field }) => (
            <FormItem className="w-5/6 mb-4 sm:w-1/3 sm:mb-0 sm:mr-4">
              {/* <FormLabel>Email</FormLabel> */}
              <Select onValueChange={field.onChange} defaultValue={field.value}>
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Subcategory" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  {category &&
                    tags?.subCategory[category].map((subCategory) => (
                      <SelectItem key={subCategory} value={subCategory}>
                        {subCategory}
                      </SelectItem>
                    ))}
                </SelectContent>
              </Select>
              {/* <FormDescription>
                You can manage email addresses in your{" "}
                <Link href="/examples/forms">email settings</Link>.
              </FormDescription> */}
              <FormMessage />
            </FormItem>
          )}
        />
        <div className="justify-self-start">
          <Button type="submit">Submit</Button>
        </div>
      </form>
    </Form>
  );
}
