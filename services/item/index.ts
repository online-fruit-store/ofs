import {
  selectItem,
  selectItemCount,
  selectItemFiltersCategoryId,
} from "@/daos";
import { ItemGetResponse, ItemGetSearchParams, PageSize } from "@/types";

export async function getItem(
  sp: ItemGetSearchParams,
): Promise<ItemGetResponse> {
  const data = await selectItem(sp);
  const count = parseInt((await selectItemCount(sp)).rows[0].count);
  const filtersCategoryId = (await selectItemFiltersCategoryId(sp)).rows.map(
    (row) => row.categoryId,
  );
  const filters = { categoryId: filtersCategoryId };
  return {
    ...data,
    count,
    filters,
    page: sp.page || "1",
    pageCount: Math.ceil(count / parseInt(sp.limit || PageSize.DEFAULT)),
  };
}
