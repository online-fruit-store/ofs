import { FetchError, groupByKey } from "@/lib";
import { getItem } from "@/services";
import {
  DefaultErrorMessages,
  FetchErrorStatusCodes,
  ItemGetSearchParams,
} from "@/types";
import { NextRequest } from "next/server";

export async function GET(req: NextRequest) {
  try {
    const sp = req.nextUrl.searchParams;
    const spObj: ItemGetSearchParams = groupByKey([...sp.entries()]);
    const data = await getItem(spObj);
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
