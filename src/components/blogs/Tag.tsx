import { Button } from "../ui/button";

export type TagProps = {
  name: string;
  category: string;
  subcategory?: string;
};

export function Tag({ name, category, subcategory }: TagProps) {
  return (
    <a
      href={
        subcategory
          ? `/blogs?category=${category}&subcategory=${subcategory}`
          : `/blogs?category=${category}`
      }
      rel="noopener noreferrer nofollow"
    >
      <Button
        size="sm"
        variant="default"
        className="h-auto px-2 mx-1 text-sm sm:text-xs rounded-2xl"
      >
        {name}
      </Button>
    </a>
  );
}
