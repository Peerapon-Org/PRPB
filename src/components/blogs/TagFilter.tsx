"use client";

import { useState, useEffect } from "react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
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
  category: z.string().optional(),
  subcategory: z.string().optional(),
});

type Categories = string[];
type Subcategories = {
  [K in Categories[number]]: string[];
};

export type Tags = {
  category: Categories;
  subcategory: Subcategories;
};

export function TagFilter() {
  const [tags, setTags] = useState<Tags>();
  const [category, setCategory] = useState<Categories[number]>("");
  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      category: "",
      subcategory: "",
    },
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
      const { category, subcategory } = (await response.json()) as Tags;
      setTags({ category, subcategory });
    }
    fetchTags();
  }, []);

  useEffect(() => {
    const urlSearchParams = new URLSearchParams(window.location.search);
    const category = urlSearchParams.get("category") ?? "";
    const subcategory = urlSearchParams.get("subcategory") ?? "";
    const isValidCategory = (
      category: string
    ): category is Categories[number] => {
      return tags?.category.includes(category) ? true : false;
    };
    const isValidSubcategory = (
      subcategory: string
    ): subcategory is Subcategories[Categories[number]][number] => {
      return (tags?.subcategory[category] ?? []).includes(subcategory) ||
        (category && !subcategory)
        ? true
        : false;
    };

    if (isValidCategory(category)) {
      form.setValue("category", category);
      setCategory(category as Categories[number]);
    }
    if (isValidSubcategory(subcategory))
      form.setValue("subcategory", subcategory);

    if (isValidCategory(category)) form.handleSubmit(onSubmit)();
  }, [tags]);

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="w-full flex flex-col sm:flex-row justify-center items-center select-none"
      >
        <FormField
          control={form.control}
          name="category"
          render={({ field }) => (
            <FormItem className="w-5/6 mb-4 sm:w-1/3 sm:mb-0 sm:mr-4">
              <Select
                onValueChange={(value) => {
                  field.onChange(value);
                  setCategory(value);
                  form.resetField("subcategory");
                }}
                value={field.value}
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
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="subcategory"
          render={({ field }) => (
            <FormItem className="w-5/6 mb-4 sm:w-1/3 sm:mb-0 sm:mr-4 select-none">
              <Select
                onValueChange={field.onChange}
                value={field.value}
                disabled={category === ""}
              >
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Subcategory" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  {category !== "" &&
                    tags?.subcategory[category].map((subcategory) => (
                      <SelectItem key={subcategory} value={subcategory}>
                        {subcategory}
                      </SelectItem>
                    ))}
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />
        <div className="justify-self-start select-none">
          <Button type="submit" className="mr-12 sm:mr-4">
            Apply
          </Button>
          <Button
            type="reset"
            onClick={() => {
              form.reset();
              setCategory("");
            }}
          >
            Clear
          </Button>
        </div>
      </form>
    </Form>
  );
}
