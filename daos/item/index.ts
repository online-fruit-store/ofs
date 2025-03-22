import { db } from "@/lib";
import { ItemGetSearchParams, OrderBy, PageSize } from "@/types";

function selectItemPredicateFactory(
  sp: ItemGetSearchParams,
  query: string = "",
  qp: (string | string[])[] = [],
  wc: string[] = [],
) {
  if (sp.id) {
    qp.push(sp.id);
    wc.push(`id = $${qp.length}`);
  }
  if (sp.categoryId) {
    qp.push(sp.categoryId);
    wc.push(`categoryId = ANY($${qp.length})`);
  }
  if (sp.query) {
    qp.push(sp.query);
    wc.push(`name ILIKE %$${qp.length}%`);
  }
  if (sp.maxWeight) {
    qp.push(sp.maxWeight);
    wc.push(`weightLbs <= $${qp.length}`);
  }
  if (sp.minWeight) {
    qp.push(sp.minWeight);
    wc.push(`weightLbs >= $${qp.length}`);
  }
  if (sp.maxPrice) {
    qp.push(sp.maxPrice);
    wc.push(`price <= $${qp.length}`);
  }
  if (sp.minPrice) {
    qp.push(sp.minPrice);
    wc.push(`price >= $${qp.length}`);
  }
  if (wc.length > 0) query += " WHERE " + wc.join(" AND ");

  return { query, qp };
}

export async function selectItem(sp: ItemGetSearchParams) {
  const source = "SELECT * FROM item";
  const { query, qp } = selectItemPredicateFactory(sp, source);
  let q = query;

  // Order by
  if (sp.orderBy === OrderBy.PRICEASCENDING) q += " ORDER BY price DESC";
  else if (sp.orderBy === OrderBy.PRICEDESCENDING) q += " ORDER BY price ASC";

  // Limit and offset
  qp.push(sp.limit || PageSize.DEFAULT, sp.page || "1");
  q += ` LIMIT $${qp.length - 1} OFFSET $${qp.length};`;

  const data = await db.query(q, qp);
  return data;
}

export async function selectItemCount(sp: ItemGetSearchParams) {
  const source = "SELECT COUNT(*) FROM item";
  const { query, qp } = selectItemPredicateFactory(sp, source);

  const data = await db.query(query, qp);
  return data;
}

export async function selectItemFiltersCategoryId(sp: ItemGetSearchParams) {
  const source = "SELECT DISTINCT categoryId FROM item";
  const { query, qp } = selectItemPredicateFactory(sp, source);

  const data = await db.query(query, qp);
  return data;
}
