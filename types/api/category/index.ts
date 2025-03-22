import { PageSize } from "@/types";

export interface Category {
  id: string;
  name: string;
  description: string;
}

export interface CategoryGetSearchParams {
  query?: string;
  page?: string;
  limit?: `${PageSize}`;
  id?: string;
}

export interface CategoryGetResponse {
  rows: Category[];
  count: number;
  page: string;
  pageCount: number;
}
