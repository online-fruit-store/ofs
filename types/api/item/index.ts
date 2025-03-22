import { OrderBy, PageSize } from "@/types";

export interface Item {
  id: string;
  categoryId: string;
  name: string;
  description: string;
  price: number;
  weightLbs: number;
  count: number;
  imgSrc: string | null;
}

export interface ItemGetFilters {
  categoryId?: string[];
}

export interface ItemGetSearchParams extends ItemGetFilters {
  query?: string;
  page?: string;
  limit?: `${PageSize}`;
  id?: string;
  maxPrice?: string;
  minPrice?: string;
  maxWeight?: string;
  minWeight?: string;
  orderBy?: OrderBy;
}

export interface ItemGetResponse {
  rows: Item[];
  count: number;
  page: string;
  pageCount: number;
  filters: ItemGetFilters;
}
