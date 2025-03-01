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
    <div>
      <a href={`/blog/${slug}`}>
        <div>
          <div>
            <img
              src={thumbnail}
              alt={title + " thumbnail"}
              className="rounded-tl-3xl"
            />
          </div>
          <div>
            <h3>{title}</h3>
            <p>{description}</p>
            <p>{publishDate}</p>
          </div>
        </div>
      </a>
      <div className="flex absolute">
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
    </div>
  );
}
