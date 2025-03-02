import { Tag } from "./Tag";

export type BlogItemProps = {
  title: string;
  description?: string;
  publishDate: string;
  category: string;
  subcategory?: string;
  slug: string;
  thumbnail: string;
};

export function BlogItem({
  title,
  description,
  publishDate,
  category,
  subcategory,
  slug,
  thumbnail,
}: BlogItemProps) {
  return (
    <div className="relative">
      <div className="flex absolute top-0 left-2">
        <Tag key={slug + "category"} name={category} category={category} />
        {subcategory && (
          <Tag
            key={slug + "subcategory"}
            name={subcategory}
            category={category}
            subcategory={subcategory}
          />
        )}
      </div>
      <a href={`/blog/${slug}`}>
        <div>
          <div>
            <img
              src={thumbnail}
              alt={title + " thumbnail"}
              className="rounded-tl-3xl"
            />
          </div>
          <div className="px-2 py-2">
            <div className="text-md leading-snug mb-2">{title}</div>
            <div className="text-xs leading-tight mb-2 font-light">
              {description}
            </div>
            <div className="text-xs font-light">{publishDate}</div>
          </div>
        </div>
      </a>
    </div>
  );
}
