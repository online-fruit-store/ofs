import { selectCategory, selectCategoryCount } from "@/daos";
import {
  CategoryGetResponse,
  CategoryGetSearchParams,
  PageSize,
} from "@/types";

export async function getCategory(
  sp: CategoryGetSearchParams,
): Promise<CategoryGetResponse> {
  const data = await selectCategory(sp);
  const count = parseInt((await selectCategoryCount(sp)).rows[0].count);
  return {
    ...data,
    count,
    page: sp.page || "1",
    pageCount: Math.ceil(count / parseInt(sp.limit || PageSize.DEFAULT)),
  };
}
