import { Tag } from "./Tag";
import { type BlogItemProps } from "./BlogList";

export function BlogItem({
  title,
  description,
  publishDate,
  category,
  subcategories,
  slug,
  thumbnail,
}: BlogItemProps) {
  return (
    <div className="relative">
      <div className="flex absolute top-0 left-2 mt-1">
        <div className="ml-1 mr-2">
          <Tag
            key={slug + "category"}
            name={category}
            category={category}
            themeLock
          />
        </div>
        {subcategories &&
          subcategories.map((subcategory) => (
            <div className="mr-2">
              <Tag
                key={slug + subcategory + "subcategory"}
                name={subcategory}
                category={category}
                subcategory={subcategory}
                themeLock
              />
            </div>
          ))}
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
