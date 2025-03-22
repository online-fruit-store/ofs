import { db } from "@/lib";
import { CategoryGetSearchParams, PageSize } from "@/types";

function selectCategoryPredicateFactory(
  sp: CategoryGetSearchParams,
  query: string = "",
  qp: (string | string[])[] = [],
  wc: string[] = [],
) {
  if (sp.id) {
    qp.push(sp.id);
    wc.push(`id = $${qp.length}`);
  }
  if (sp.query) {
    qp.push(sp.query);
    wc.push(`name ILIKE %$${qp.length}%`);
  }
  if (wc.length > 0) query += " WHERE " + wc.join(" AND ");

  return { query, qp };
}

export async function selectCategory(sp: CategoryGetSearchParams) {
  const source = "SELECT * FROM category";
  const { query, qp } = selectCategoryPredicateFactory(sp, source);
  let q = query;

  // Limit and offset
  qp.push(sp.limit || PageSize.TEN, sp.page || "1");
  q += ` LIMIT $${qp.length - 1} OFFSET $${qp.length};`;

  const data = await db.query(q, qp);
  return data;
}

export async function selectCategoryCount(sp: CategoryGetSearchParams) {
  const source = "SELECT COUNT(*) FROM category";
  const { query, qp } = selectCategoryPredicateFactory(sp, source);

  const data = await db.query(query, qp);
  return data;
}
