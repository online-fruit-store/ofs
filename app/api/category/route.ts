import { NextRequest } from "next/server";
import { FetchError, groupByKey } from "@/lib";
import { getCategory } from "@/services";
import {
  CategoryGetSearchParams,
  DefaultErrorMessages,
  FetchErrorStatusCodes,
} from "@/types";

export async function GET(req: NextRequest) {
  try {
    const sp = req.nextUrl.searchParams;
    const spObj: CategoryGetSearchParams = groupByKey([...sp.entries()]);
    const data = await getCategory(spObj);
    return Response.json(data);
  } catch (error) {
    if (error instanceof FetchError) {
      return Response.json(
        { error: error.message },
        { status: error.status ?? FetchErrorStatusCodes.INTERNALSERVERERROR },
      );
    }
    return Response.json(
      { error: DefaultErrorMessages.INTERNALSERVERERROR },
      { status: FetchErrorStatusCodes.INTERNALSERVERERROR },
    );
  }
}
